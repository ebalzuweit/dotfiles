
# ~/.config/zsh/scripts/telemetry_formatter.py
import sys, os, subprocess

def _yes_no(prompt: str, default: bool = True) -> bool:
    if not sys.stdin.isatty():
        return default
    suffix = " [Y/n] " if default else " [y/N] "
    while True:
        ans = input(prompt + suffix).strip().lower()
        if not ans:
            return default
        if ans in ("y", "yes"):
            return True
        if ans in ("n", "no"):
            return False
        print("Please answer 'y' or 'n'.")

def _run(cmd):
    env = os.environ.copy()
    env.setdefault("PIP_DISABLE_PIP_VERSION_CHECK", "1")
    # Don't inherit corporate index/certs if we explicitly set index later
    return subprocess.run(cmd, text=True, capture_output=True, env=env)

def _has_cert_error(proc: subprocess.CompletedProcess) -> bool:
    out = (proc.stderr or "") + "\n" + (proc.stdout or "")
    needles = (
        "CERTIFICATE_VERIFY_FAILED",
        "SSLError",
        "self signed certificate",
        "certificate verify failed",
    )
    return any(s.lower() in out.lower() for s in needles)

def _ensure_rich():
    in_venv = bool(os.getenv("VIRTUAL_ENV"))
    install_scope = "(this venv)" if in_venv else "(user install)"

    print("⚠️  Python package 'rich' not found.", file=sys.stderr)
    if not _yes_no(f"Do you want to install 'rich' now {install_scope}?", default=True):
        print("Aborting. Please install 'rich' and re-run.", file=sys.stderr)
        sys.exit(1)

    # 1) Try a normal, secure install first
    cmd = [sys.executable, "-m", "pip", "install", "rich"]
    if not in_venv:
        cmd.insert(4, "--user")
    proc = _run(cmd)
    if proc.returncode == 0:
        print("✅ 'rich' installed successfully.", file=sys.stderr)
        return

    # 2) If it failed with a cert error, offer insecure fallback
    if _has_cert_error(proc):
        print("\n❌ Secure install failed due to an SSL/cert error.", file=sys.stderr)
        print(proc.stderr.strip() or proc.stdout.strip(), file=sys.stderr)
        if _yes_no(
            "Install insecurely via HTTP PyPI mirror (NOT recommended)?", default=False
        ):
            # Mirrors your requested command, but isolated from corp config, and venv-aware
            insecure_cmd = [
                sys.executable, "-m", "pip", "install",
                "--isolated",
                "--trusted-host", "pypi.org",
                "--trusted-host", "files.pythonhosted.org",
                "--index-url", "http://pypi.org/simple",
                "rich",
            ]
            if not in_venv:
                insecure_cmd.insert(4, "--user")
            proc2 = _run(insecure_cmd)
            if proc2.returncode == 0:
                print("✅ 'rich' installed (insecure path).", file=sys.stderr)
                return
            else:
                print("\n❌ Insecure install also failed.", file=sys.stderr)
                print(proc2.stderr.strip() or proc2.stdout.strip(), file=sys.stderr)
        else:
            print("Skipped insecure install at your request.", file=sys.stderr)
    else:
        # Non-cert failure, show why
        print("\n❌ Failed to install 'rich':", file=sys.stderr)
        print(proc.stderr.strip() or proc.stdout.strip(), file=sys.stderr)

    sys.exit(1)

# --- Dependency Auto-Installer (prompt-based, venv-aware) ---
try:
    from rich.console import Console
    from rich.table import Table
    from rich.panel import Panel
    from rich.text import Text
    from rich.style import Style
except ImportError:
    _ensure_rich()
    # Try import again after install
    from rich.console import Console
    from rich.table import Table
    from rich.panel import Panel
    from rich.text import Text
    from rich.style import Style

