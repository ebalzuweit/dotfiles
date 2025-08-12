# ~/.config/zsh/scripts/telemetry_formatter.py
import sys
import re
import json
from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from rich.text import Text
from rich.columns import Columns
from rich.style import Style

def parse_time_output(data, os_type):
    """Parses the output of /usr/bin/time for macOS or Linux."""
    metrics = {}
    if os_type == "Darwin":  # macOS
        patterns = {
            "real_time": r"(\d+\.\d+)\s+real",
            "user_time": r"(\d+\.\d+)\s+user",
            "system_time": r"(\d+\.\d+)\s+sys",
            "memory_mb": r"(\d+)\s+maximum resident set size",
            "cpu_percent": r"(\d+)%\s+cpu",
        }
        for key, pattern in patterns.items():
            match = re.search(pattern, data)
            if match:
                value = float(match.group(1))
                if key == "memory_mb":
                    value /= 1_048_576  # Convert bytes to MB
                metrics[key] = f"{value:.2f}"
    else:  # Linux
        patterns = {
            "real_time": r"Elapsed \(wall clock\) time \(h:mm:ss or m:ss\): ([\d:\.]+)",
            "user_time": r"User time \(seconds\): ([\d\.]+)",
            "system_time": r"System time \(seconds\): ([\d\.]+)",
            "memory_mb": r"Maximum resident set size \(kbytes\): (\d+)",
            "cpu_percent": r"Percent of CPU this job got: (\d+)%",
        }
        for key, pattern in patterns.items():
            match = re.search(pattern, data)
            if match:
                value = match.group(1)
                if key == "memory_mb":
                    value = float(value) / 1024 # Convert KB to MB
                    metrics[key] = f"{value:.2f}"
                else:
                    metrics[key] = value

    return metrics

def parse_python_profile(data):
    """Parses the output of Python's cProfile."""
    lines = data.strip().split('\n')
    # Find the header line to start parsing from
    header_index = -1
    for i, line in enumerate(lines):
        if "ncalls" in line and "tottime" in line:
            header_index = i
            break
    if header_index == -1:
        return []

    # Get top 5 functions by total time (tottime)
    func_lines = lines[header_index + 1:]
    # Sort by the 'tottime' column (index 1)
    sorted_funcs = sorted(
        [line.split() for line in func_lines if len(line.split()) >= 5],
        key=lambda x: float(x[1]),
        reverse=True
    )
    return sorted_funcs[:5] # Return top 5

def display_report(language, command, time_metrics, profile_data):
    """Uses rich to display a beautiful, colorized report."""
    console = Console()

    # --- Header ---
    lang_styles = {
        "Python": Style(color="yellow", bold=True),
        "Go": Style(color="cyan", bold=True)
    }
    header_text = Text(f"{language} Run Telemetry", style=lang_styles.get(language, "bold white"))
    console.print(Panel(header_text, expand=False, border_style="dim"))
    console.print(f"[dim]Command:[/] [bold magenta]{command}[/]")
    console.print("-" * 40)

    # --- Core Metrics Panel ---
    real_time = time_metrics.get("real_time", "N/A")
    user_time = time_metrics.get("user_time", "N/A")
    memory_mb = time_metrics.get("memory_mb", "N/A")

    panel_content = (
        f"[bold green]Overall Time[/]: [bold yellow]{real_time}s[/]\n"
        f"[bold blue]CPU Time (User)[/]: [bold yellow]{user_time}s[/]\n"
        f"[bold red]Peak Memory[/]: [bold yellow]{memory_mb} MB[/]"
    )
    console.print(Panel(panel_content, title="Core Metrics", border_style="green"))

    # --- Function Profiling Table ---
    if profile_data:
        table = Table(title="Top 5 Hot Functions (by self time)", border_style="blue")
        if language == "Python":
            table.add_column("Total Time", justify="right", style="cyan")
            table.add_column("Per Call", justify="right", style="magenta")
            table.add_column("Cumulative", justify="right", style="green")
            table.add_column("Function Name", style="yellow")

            for ncalls, tottime, percall, cumtime, _, *filename_parts in profile_data:
                func_name = " ".join(filename_parts)
                table.add_row(tottime, percall, cumtime, func_name)
        console.print(table)

if __name__ == "__main__":
    log_file = sys.argv[1]
    os_type = sys.argv[2]
    language = sys.argv[3]
    command = sys.argv[4]

    with open(log_file, 'r') as f:
        content = f.read()

    # Split content into time data and profiler data
    time_data, profile_data_raw = content.split("---PROFILER DATA---", 1)

    time_metrics = parse_time_output(time_data, os_type)

    profile_data = None
    if language == "Python":
        profile_data = parse_python_profile(profile_data_raw)

    display_report(language, command, time_metrics, profile_data)
