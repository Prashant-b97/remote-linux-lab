#!/usr/bin/env bash
# Generate a timestamped Markdown report of key system diagnostics from a remote Segfault host.
set -euo pipefail

REMOTE_HOST="${1:-releasecoffee}"
REPORT_DIR="${REPORT_BASE:-notes/reports}"
TIMESTAMP="$(date -u +'%Y-%m-%dT%H-%M-%SZ')"
REPORT_PATH="$REPORT_DIR/system-report-${REMOTE_HOST}-${TIMESTAMP}.md"

mkdir -p "$REPORT_DIR"

ssh "$REMOTE_HOST" 'bash -s' <<'REMOTE' >"$REPORT_PATH"
set -euo pipefail

section() {
  printf '\n## %s\n\n' "$1"
}

run_cmd() {
  local cmd="$1"
  echo '```bash'
  echo "\$ $cmd"
  set +e
  eval "$cmd"
  local status=$?
  set -e
  if [[ $status -ne 0 ]]; then
    printf '[command exited with %s]\n' "$status"
  fi
  echo '```'
}

printf '# System Report: %s\n\n' "$(hostname)"
printf '- Generated at (UTC): %s\n' "$(date -u +'%Y-%m-%d %H:%M:%SZ')"
printf '- Kernel: %s\n' "$(uname -sr)"
if uptime -p >/dev/null 2>&1; then
  printf '- Uptime: %s\n' "$(uptime -p)"
else
  printf '- Uptime: %s\n' "$(uptime)"
fi

section "Identity & Sessions"
run_cmd "who"
run_cmd "last -n 5"

section "Load & Processes"
run_cmd "uptime"
run_cmd "ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 10"

section "Storage"
run_cmd "df -h"
run_cmd "du -sh /sec 2>/dev/null"

if command -v free >/dev/null 2>&1; then
  section "Memory"
  run_cmd "free -h"
fi

section "Network"
if command -v ip >/dev/null 2>&1; then
  run_cmd "ip addr show"
else
  run_cmd "ifconfig -a"
fi
if command -v ss >/dev/null 2>&1; then
  run_cmd "ss -tulpn"
elif command -v netstat >/dev/null 2>&1; then
  run_cmd "netstat -tulpn"
fi

if command -v systemctl >/dev/null 2>&1; then
  section "Running Services"
  run_cmd "systemctl list-units --type=service --state=running"
fi

if command -v journalctl >/dev/null 2>&1; then
  section "Recent Journal"
  run_cmd "journalctl -n 50 --no-pager"
else
  section "Recent Logs"
  if [[ -f /var/log/syslog ]]; then
    run_cmd "tail -n 100 /var/log/syslog"
  elif [[ -f /var/log/messages ]]; then
    run_cmd "tail -n 100 /var/log/messages"
  else
    echo '```bash'
    echo '# No syslog-style log file found.'
    echo '```'
  fi
fi
REMOTE

echo "Saved report to $REPORT_PATH"
