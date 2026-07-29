"""Review recent activity on remote-tracking Git branches."""

from __future__ import annotations

import argparse
import datetime as dt
import subprocess
import sys
from dataclasses import dataclass


class GitError(RuntimeError):
    pass


@dataclass(frozen=True)
class Commit:
    hash: str
    timestamp: int
    author: str
    subject: str
    additions: int
    deletions: int

    @property
    def date(self) -> str:
        value = dt.datetime.fromtimestamp(self.timestamp).astimezone()
        return value.strftime("%Y-%m-%d %H:%M")


def git(*args: str) -> str:
    result = subprocess.run(
        ["git", *args],
        text=True,
        capture_output=True,
        check=False,
    )
    if result.returncode:
        message = result.stderr.strip() or "git command failed"
        raise GitError(message)
    return result.stdout


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Review recent commits and line changes on remote branches."
    )
    parser.add_argument(
        "--date",
        type=parse_date,
        metavar="YYYY-MM-DD",
        help="show commits whose local date is YYYY-MM-DD; overrides --days",
    )
    parser.add_argument(
        "--author",
        metavar="SUBSTRING",
        help="show commits whose Git author name contains SUBSTRING",
    )
    parser.add_argument(
        "--days",
        type=int,
        default=14,
        metavar="N",
        help="include commits from the last N days (default: 14)",
    )
    args = parser.parse_args()
    if args.days < 0:
        parser.error("--days must be zero or greater")
    return args


def parse_date(value: str) -> dt.date:
    try:
        return dt.date.fromisoformat(value)
    except ValueError as error:
        raise argparse.ArgumentTypeError(
            "date must use ISO8601 format YYYY-MM-DD"
        ) from error


def remote_branches() -> list[str]:
    refs = git(
        "for-each-ref",
        "refs/remotes",
        "--format=%(refname:short)",
        "--sort=-committerdate",
    )
    return [ref for ref in refs.splitlines() if ref and not ref.endswith("/HEAD")]


def recent_commits(
    branch: str, date: dt.date | None, since: int, author_filter: str | None
) -> list[tuple[str, int, str, str]]:
    arguments = ["log", branch]
    if date is None:
        arguments.append(f"--since=@{since}")
    else:
        arguments.extend(
            [
                f"--since={date.isoformat()}T00:00:00",
                f"--until={(date + dt.timedelta(days=1)).isoformat()}T00:00:00",
            ]
        )
    arguments.append("--format=%H%x1f%ct%x1f%an%x1f%s%x1e")
    output = git(*arguments)
    commits = []
    for record in output.split("\x1e"):
        record = record.strip()
        if not record:
            continue
        fields = record.split("\x1f")
        if len(fields) != 4:
            raise GitError(f"could not parse git log output for {branch}")
        if author_filter is None or author_filter.casefold() in fields[2].casefold():
            commits.append((fields[0], int(fields[1]), fields[2], fields[3]))
    return commits


def diff_stats(commit_hash: str) -> tuple[int, int]:
    additions = 0
    deletions = 0
    output = git("show", "--format=", "--numstat", "--no-renames", commit_hash)
    for line in output.splitlines():
        fields = line.split("\t", 2)
        if len(fields) != 3:
            continue
        added, deleted = fields[:2]
        if added.isdigit():
            additions += int(added)
        if deleted.isdigit():
            deletions += int(deleted)
    return additions, deletions


def make_commit(raw: tuple[str, int, str, str], cache: dict[str, Commit]) -> Commit:
    commit_hash, timestamp, author, subject = raw
    if commit_hash not in cache:
        additions, deletions = diff_stats(commit_hash)
        cache[commit_hash] = Commit(
            commit_hash,
            timestamp,
            author,
            subject,
            additions,
            deletions,
        )
    return cache[commit_hash]


def print_report(branch_commits: dict[str, list[Commit]]) -> None:
    active = [items for items in branch_commits.items() if items[1]]
    active.sort(key=lambda item: item[1][0].timestamp, reverse=True)

    if not active:
        print("No remote branch activity in the selected period.")
        return

    unique_commits = {
        commit.hash: commit
        for _, commits in active
        for commit in commits
    }
    total_commits = len(unique_commits)
    total_additions = sum(commit.additions for commit in unique_commits.values())
    total_deletions = sum(commit.deletions for commit in unique_commits.values())
    print(
        "Recent remote branch activity "
        f"({len(active)} branches, {total_commits} commits, "
        f"+{total_additions}/-{total_deletions})"
    )
    print("=" * 72)
    for branch, commits in active:
        additions = sum(commit.additions for commit in commits)
        deletions = sum(commit.deletions for commit in commits)
        print()
        print(f"{branch}  ({len(commits)} commits, +{additions}/-{deletions})")
        print("-" * len(branch))
        for commit in commits:
            print(
                f"{commit.date}  {commit.hash[:10]}  "
                f"{commit.author}  +{commit.additions}/-{commit.deletions}  "
                f"{commit.subject}"
            )


def main() -> int:
    args = parse_args()
    try:
        git("rev-parse", "--show-toplevel")
        git("fetch", "--all", "--prune")
        since = int(dt.datetime.now().timestamp()) - args.days * 24 * 60 * 60
        cache: dict[str, Commit] = {}
        activity = {
            branch: [
                make_commit(raw, cache)
                for raw in recent_commits(branch, args.date, since, args.author)
            ]
            for branch in remote_branches()
        }
        print_report(activity)
    except GitError as error:
        print(f"git-activity: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
