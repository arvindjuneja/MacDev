#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.10"
# dependencies = [
#     "rich>=13.0",
# ]
# ///
"""Claude Code Monitor - Live dashboard for tracking Claude Code CLI instances."""

import argparse
import json
import os
import subprocess
import sys
from datetime import datetime, date
from pathlib import Path
from time import sleep

from rich.console import Console
from rich.live import Live
from rich.panel import Panel
from rich.table import Table
from rich.text import Text
from rich.columns import Columns
from rich import box

# Catppuccin Mocha palette
BLUE = "#89b4fa"
GREEN = "#a6e3a1"
PINK = "#f5c2e7"
PEACH = "#fab387"
TEXT = "#cdd6f4"
SUBTEXT = "#a6adc8"
SURFACE = "#313244"
OVERLAY = "#45475a"
MAUVE = "#cba6f7"
RED = "#f38ba8"
YELLOW = "#f9e2af"
TEAL = "#94e2d5"


class ClaudeData:
    """Reads all data sources for the dashboard."""

    STATS_PATH = Path.home() / ".claude" / "stats-cache.json"
    HISTORY_PATH = Path.home() / ".claude" / "history.jsonl"

    def get_processes(self) -> list[dict]:
        """Get running Claude Code CLI instances via ps + lsof."""
        try:
            result = subprocess.run(
                ["ps", "-eo", "pid,etime,pcpu,pmem,command"],
                capture_output=True, text=True, timeout=5
            )
        except (subprocess.TimeoutExpired, FileNotFoundError):
            return []

        instances = []
        for line in result.stdout.strip().split("\n"):
            line = line.strip()
            if not line.endswith("claude"):
                continue
            parts = line.split()
            if len(parts) < 5:
                continue
            pid = parts[0]
            etime = parts[1]
            cpu = parts[2].replace(",", ".")
            mem = parts[3]

            # Get working directory via lsof
            project = self._get_project(pid)

            instances.append({
                "pid": pid,
                "etime": self._format_etime(etime),
                "cpu": cpu,
                "mem": mem,
                "project": project,
            })

        # Sort by CPU descending
        instances.sort(key=lambda x: float(x["cpu"]), reverse=True)
        return instances

    def _get_project(self, pid: str) -> str:
        """Get project name from process working directory."""
        # On Linux, /proc/<pid>/cwd is a symlink to the working directory
        if sys.platform == "linux":
            try:
                cwd = os.readlink(f"/proc/{pid}/cwd")
                return Path(cwd).name
            except (OSError, ValueError):
                pass
            return "unknown"

        # On macOS, use lsof to find the working directory
        try:
            result = subprocess.run(
                ["lsof", "-p", pid],
                capture_output=True, text=True, timeout=5
            )
            for line in result.stdout.split("\n"):
                if "cwd" in line and "DIR" in line:
                    # Last field is the path
                    path = line.strip().rsplit(None, 1)[-1]
                    return Path(path).name
        except (subprocess.TimeoutExpired, FileNotFoundError):
            pass
        return "unknown"

    def _format_etime(self, etime: str) -> str:
        """Format ps elapsed time (DD-HH:MM:SS or HH:MM:SS or MM:SS) to compact form."""
        etime = etime.strip()
        days = 0
        if "-" in etime:
            day_part, time_part = etime.split("-", 1)
            days = int(day_part)
            etime = time_part

        parts = etime.split(":")
        if len(parts) == 3:
            hours = int(parts[0])
            minutes = int(parts[1])
        elif len(parts) == 2:
            hours = 0
            minutes = int(parts[0])
        else:
            return etime

        if days > 0:
            return f"{days}d {hours}h"
        elif hours > 0:
            return f"{hours}h {minutes}m"
        else:
            return f"{minutes}m"

    def get_stats_cache(self) -> dict | None:
        """Read stats-cache.json."""
        try:
            return json.loads(self.STATS_PATH.read_text())
        except (FileNotFoundError, json.JSONDecodeError):
            return None

    def get_today_stats(self) -> dict:
        """Parse history.jsonl for today's message and session counts."""
        today_str = date.today().isoformat()
        messages = 0
        sessions = set()

        try:
            # Read from end of file for efficiency
            with open(self.HISTORY_PATH, "rb") as f:
                # Seek to last 512KB (enough for a day's activity)
                try:
                    f.seek(-524288, 2)
                    f.readline()  # skip partial line
                except OSError:
                    f.seek(0)

                for line in f:
                    try:
                        entry = json.loads(line)
                    except json.JSONDecodeError:
                        continue
                    ts = entry.get("timestamp")
                    if ts is None:
                        continue
                    entry_date = datetime.fromtimestamp(ts / 1000).date().isoformat()
                    if entry_date == today_str:
                        messages += 1
                        sid = entry.get("sessionId")
                        if sid:
                            sessions.add(sid)
        except FileNotFoundError:
            pass

        return {"messages": messages, "sessions": len(sessions)}

    def get_recent_activity(self, count: int = 5) -> list[dict]:
        """Get last N entries from history.jsonl."""
        entries = []
        try:
            with open(self.HISTORY_PATH, "rb") as f:
                # Seek to last 64KB
                try:
                    f.seek(-65536, 2)
                    f.readline()  # skip partial line
                except OSError:
                    f.seek(0)

                for line in f:
                    try:
                        entry = json.loads(line)
                        entries.append(entry)
                    except json.JSONDecodeError:
                        continue
        except FileNotFoundError:
            pass

        return entries[-count:]

    def get_lifetime_stats(self) -> dict:
        """Compute lifetime stats from history.jsonl (fallback when stats-cache.json missing)."""
        messages = 0
        sessions = set()
        first_ts = None
        daily = {}

        try:
            with open(self.HISTORY_PATH, "r") as f:
                for line in f:
                    try:
                        entry = json.loads(line)
                    except json.JSONDecodeError:
                        continue
                    ts = entry.get("timestamp")
                    if ts is None:
                        continue
                    messages += 1
                    if first_ts is None or ts < first_ts:
                        first_ts = ts
                    sid = entry.get("sessionId")
                    if sid:
                        sessions.add(sid)
                    day = datetime.fromtimestamp(ts / 1000).date().isoformat()
                    daily[day] = daily.get(day, 0) + 1
        except FileNotFoundError:
            pass

        first_date = ""
        if first_ts:
            first_date = datetime.fromtimestamp(first_ts / 1000).strftime("%b %-d, %Y")

        return {
            "totalMessages": messages,
            "totalSessions": len(sessions),
            "firstDate": first_date,
            "activeDays": len(daily),
        }

    def get_token_totals(self, stats: dict | None) -> dict[str, int]:
        """Aggregate tokens per model from stats-cache modelUsage."""
        totals = {}
        if not stats or "modelUsage" not in stats:
            return totals

        for model, usage in stats["modelUsage"].items():
            total = (
                usage.get("inputTokens", 0)
                + usage.get("outputTokens", 0)
                + usage.get("cacheReadInputTokens", 0)
                + usage.get("cacheCreationInputTokens", 0)
            )
            # Simplify model name
            name = model.replace("claude-", "").split("-2025")[0].split("-2024")[0]
            totals[name] = totals.get(name, 0) + total

        # Sort by token count descending
        return dict(sorted(totals.items(), key=lambda x: x[1], reverse=True))


def format_tokens(n: int) -> str:
    """Format token count to human-readable form."""
    if n >= 1_000_000_000:
        return f"{n / 1_000_000_000:.2f}B"
    elif n >= 1_000_000:
        return f"{n / 1_000_000:.0f}M"
    elif n >= 1_000:
        return f"{n / 1_000:.0f}K"
    return str(n)


def make_bar(value: int, max_val: int, width: int = 15) -> Text:
    """Create a text-based progress bar."""
    if max_val <= 0:
        filled = 0
    else:
        filled = min(int((value / max_val) * width), width)
    empty = width - filled
    bar = Text()
    bar.append("█" * filled, style=BLUE)
    bar.append("░" * empty, style=OVERLAY)
    return bar


def build_compact_dashboard(data: ClaudeData) -> Panel:
    """Build a compact dashboard optimized for small panes (~10 lines)."""
    processes = data.get_processes()
    stats = data.get_stats_cache()
    today = data.get_today_stats()
    tokens = data.get_token_totals(stats)
    recent = data.get_recent_activity(5)

    from rich.console import Group
    parts = []

    # === Instances: single line ===
    if processes:
        line = Text("● ", style=GREEN)
        items = []
        for p in processes:
            proj = p["project"][:12]
            cpu_val = float(p["cpu"])
            cpu_style = RED if cpu_val > 50 else PEACH if cpu_val > 10 else SUBTEXT
            item = Text(proj, style=PINK)
            item.append(f" {p['cpu']}%", style=cpu_style)
            item.append(f" {p['etime']}", style=SUBTEXT)
            items.append(item)
        for i, item in enumerate(items):
            line.append_text(item)
            if i < len(items) - 1:
                line.append("  ", style=SUBTEXT)
        parts.append(line)
    else:
        parts.append(Text("○ No active instances", style=SUBTEXT))

    # === TODAY: inline with bars ===
    today_date = date.today().strftime("%b %-d")
    msg_line = Text(f"TODAY {today_date}  ", style=f"bold {BLUE}")
    msg_line.append("Msgs ")
    msg_line.append_text(make_bar(today["messages"], max(today["messages"], 200), width=8))
    msg_line.append(f" {today['messages']:,}", style=TEXT)
    msg_line.append("  Sess ")
    msg_line.append_text(make_bar(today["sessions"], max(today["sessions"], 10), width=6))
    msg_line.append(f" {today['sessions']}", style=TEXT)
    parts.append(msg_line)

    # === TOKENS: one line ===
    if tokens:
        line = Text("TOKENS ", style=f"bold {MAUVE}")
        token_parts = []
        for m, c in tokens.items():
            token_parts.append(f"{m} {format_tokens(c)}")
        line.append(" · ".join(token_parts), style=TEXT)
        parts.append(line)

    # === RECENT: compact list ===
    if recent:
        parts.append(Text("RECENT", style=f"bold {TEAL}"))
        for entry in reversed(recent):
            ts = entry.get("timestamp", 0)
            time_str = datetime.fromtimestamp(ts / 1000).strftime("%H:%M")
            project = Path(entry.get("project", "")).name or "?"
            if len(project) > 10:
                project = project[:9] + "…"
            display = entry.get("display", "")
            max_msg = 35
            if len(display) > max_msg:
                display = display[:max_msg - 1] + "…"
            line = Text(f"{time_str} ", style=SUBTEXT)
            line.append(f"{project:<10} ", style=PINK)
            line.append(display, style=TEXT)
            parts.append(line)

    # === LIFETIME: from stats-cache or computed from history ===
    if stats:
        total_s = stats.get("totalSessions", 0)
        total_m = stats.get("totalMessages", 0)
        parts.append(Text(
            f"LIFETIME  {total_s} sessions · {total_m:,} msgs",
            style=f"bold {YELLOW}"
        ))
    else:
        lifetime = data.get_lifetime_stats()
        if lifetime["totalMessages"] > 0:
            parts.append(Text(
                f"LIFETIME  {lifetime['totalSessions']} sessions · "
                f"{lifetime['totalMessages']:,} msgs · {lifetime['activeDays']} days",
                style=f"bold {YELLOW}"
            ))

    content = Group(*parts)
    now = datetime.now().strftime("%H:%M:%S")
    title = Text("CLAUDE CODE MONITOR", style=f"bold {BLUE}")
    subtitle = Text(f"↻ {now}", style=SUBTEXT)

    return Panel(
        content,
        title=title,
        subtitle=subtitle,
        border_style=SURFACE,
        box=box.ROUNDED,
        expand=True,
        padding=(0, 1),
    )


def build_dashboard(data: ClaudeData, compact: bool = False) -> Panel:
    """Build the complete dashboard as a rich Panel."""
    if compact:
        return build_compact_dashboard(data)

    processes = data.get_processes()
    stats = data.get_stats_cache()
    today = data.get_today_stats()
    recent = data.get_recent_activity(5)
    tokens = data.get_token_totals(stats)

    parts = []

    # === Active Instances ===
    instance_count = len(processes)
    if instance_count > 0:
        color = GREEN
        status = f"● {instance_count} active instance{'s' if instance_count != 1 else ''}"
    else:
        color = SUBTEXT
        status = "○ No active instances"

    header = Text(f"  {status}", style=color)
    parts.append(header)

    if processes:
        proc_table = Table(
            show_header=False, box=None, padding=(0, 1),
            expand=True, pad_edge=False
        )
        proc_table.add_column("project", style=PINK, max_width=14, no_wrap=True)
        proc_table.add_column("pid", style=SUBTEXT, max_width=8, justify="right")
        proc_table.add_column("cpu", style=PEACH, max_width=8, justify="right")
        proc_table.add_column("time", style=SUBTEXT, max_width=8, justify="right")

        for p in processes:
            proj = p["project"]
            if len(proj) > 12:
                proj = proj[:11] + "…"
            cpu_val = float(p["cpu"])
            cpu_style = RED if cpu_val > 50 else PEACH if cpu_val > 10 else SUBTEXT
            proc_table.add_row(
                proj,
                f"PID {p['pid']}",
                Text(f"CPU {p['cpu']}%", style=cpu_style),
                p["etime"],
            )
        parts.append(proc_table)
    parts.append(Text(""))

    # === Today Stats ===
    today_date = date.today().strftime("%b %-d")
    parts.append(Text(f"  TODAY  {today_date}", style=f"bold {BLUE}"))

    msg_max = max(today["messages"], 200)
    msg_bar = Text("  Messages ")
    msg_bar.append_text(make_bar(today["messages"], msg_max))
    msg_bar.append(f"  {today['messages']:,}", style=TEXT)
    parts.append(msg_bar)

    sess_max = max(today["sessions"], 10)
    sess_bar = Text("  Sessions ")
    sess_bar.append_text(make_bar(today["sessions"], sess_max))
    sess_bar.append(f"  {today['sessions']}", style=TEXT)
    parts.append(sess_bar)

    parts.append(Text(""))

    # === Token Totals ===
    if tokens:
        parts.append(Text("  TOKENS (lifetime)", style=f"bold {MAUVE}"))
        for model, count in tokens.items():
            parts.append(Text(f"  {model:<18} {format_tokens(count)} tokens", style=TEXT))
        parts.append(Text(""))

    # === Recent Activity ===
    if recent:
        parts.append(Text("  RECENT", style=f"bold {TEAL}"))
        for entry in reversed(recent):
            ts = entry.get("timestamp", 0)
            time_str = datetime.fromtimestamp(ts / 1000).strftime("%H:%M")
            project = Path(entry.get("project", "")).name or "?"
            if len(project) > 10:
                project = project[:9] + "…"
            display = entry.get("display", "")
            # Truncate message to fit
            max_msg = 30
            if len(display) > max_msg:
                display = display[:max_msg - 2] + "…"

            line = Text(f"  {time_str} ", style=SUBTEXT)
            line.append(f"{project:<10} ", style=PINK)
            line.append(display, style=TEXT)
            parts.append(line)
        parts.append(Text(""))

    # === Lifetime Summary ===
    if stats:
        total_sessions = stats.get("totalSessions", 0)
        total_messages = stats.get("totalMessages", 0)
        first_date = stats.get("firstSessionDate", "")
        if first_date:
            try:
                since = datetime.fromisoformat(first_date.replace("Z", "+00:00")).strftime("%b %-d, %Y")
            except (ValueError, AttributeError):
                since = "?"
        else:
            since = "?"
        parts.append(Text(
            f"  LIFETIME  {total_sessions} sessions · {total_messages:,} msgs",
            style=f"bold {YELLOW}"
        ))
        parts.append(Text(f"  Since {since}", style=SUBTEXT))
    else:
        lifetime = data.get_lifetime_stats()
        if lifetime["totalMessages"] > 0:
            parts.append(Text(
                f"  LIFETIME  {lifetime['totalSessions']} sessions · "
                f"{lifetime['totalMessages']:,} msgs · {lifetime['activeDays']} active days",
                style=f"bold {YELLOW}"
            ))
            if lifetime["firstDate"]:
                parts.append(Text(f"  Since {lifetime['firstDate']}", style=SUBTEXT))
            parts.append(Text(
                "  ℹ Token data requires ~/.claude/stats-cache.json",
                style=SUBTEXT
            ))

    # Assemble into panel
    from rich.console import Group
    content = Group(*parts)

    now = datetime.now().strftime("%H:%M:%S")
    title = Text("CLAUDE CODE MONITOR", style=f"bold {BLUE}")
    subtitle = Text(f"↻ {now}", style=SUBTEXT)

    return Panel(
        content,
        title=title,
        subtitle=subtitle,
        border_style=SURFACE,
        box=box.ROUNDED,
        expand=True,
        padding=(1, 1),
    )


def main():
    parser = argparse.ArgumentParser(description="Claude Code Monitor")
    parser.add_argument("--interval", "-i", type=int, default=5,
                        help="Refresh interval in seconds (default: 5)")
    parser.add_argument("--once", action="store_true",
                        help="Print a single frame and exit")
    parser.add_argument("--compact", action="store_true",
                        help="Compact mode (fewer recent entries)")
    args = parser.parse_args()

    console = Console()
    data = ClaudeData()

    if args.once:
        console.print(build_dashboard(data, compact=args.compact))
        return

    try:
        with Live(
            build_dashboard(data, compact=args.compact),
            console=console,
            refresh_per_second=1,
            screen=True,
        ) as live:
            while True:
                sleep(args.interval)
                live.update(build_dashboard(data, compact=args.compact))
    except KeyboardInterrupt:
        pass


if __name__ == "__main__":
    main()
