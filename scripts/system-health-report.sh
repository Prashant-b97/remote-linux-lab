#!/usr/bin/env bash
# Generate a local markdown snapshot of system health for CI artifacts or quick demos.
# Runs monitor.sh for recent metrics and captures key platform details.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_DIR="${REPORT_BASE:-$REPO_ROOT/logs}"
TIMESTAMP="$(date -u +'%Y-%m-%dT%H-%M-%SZ')"
REPORT_PATH="$LOG_DIR/system-health-report-$TIMESTAMP.md"
METRICS_PATH="$LOG_DIR/system-metrics-$TIMESTAMP.json"
REPORT_BASENAME="$(basename "$REPORT_PATH")"

mkdir -p "$LOG_DIR"

# Capture a short burst of metrics using the existing monitoring scaffold.
set +e
MONITOR_OUTPUT=$("$SCRIPT_DIR/monitor.sh" --format json --interval 2 --count 5 --output "$METRICS_PATH" 2>&1)
MONITOR_EXIT=$?
set -e
printf '%s\n' "$MONITOR_OUTPUT"

if (( MONITOR_EXIT == 0 )) && [[ -f "$METRICS_PATH" ]]; then
  METRICS_BASENAME="$(basename "$METRICS_PATH")"
  METRICS_VALUE="\`$METRICS_BASENAME\`"
  METRICS_DESC="The file \`$METRICS_BASENAME\` contains five samples captured via \`monitor.sh\`."
  QUICK_PEEK_SECTION=$(cat <<EOF
### Quick Peek

Run the following to inspect locally:

\`\`\`bash
jq '.' "$METRICS_PATH"
\`\`\`
EOF
)
else
  METRICS_BASENAME=""
  METRICS_VALUE="_Unavailable (monitor.sh exit $MONITOR_EXIT)_"
  METRICS_DESC="_Metrics capture failed in this environment (exit $MONITOR_EXIT); rerun locally to generate samples._"
  if [[ -n "$MONITOR_OUTPUT" ]]; then
    printf -v METRICS_DESC "%s\n\n\`\`\`\n%s\n\`\`\`\n" "$METRICS_DESC" "$MONITOR_OUTPUT"
  fi
  QUICK_PEEK_SECTION=$'### Quick Peek\n\n_Metrics capture unavailable in this environment; rerun locally to inspect JSON output._\n'
  METRICS_PATH=""
fi

HOSTNAME="$(hostname)"
KERNEL="$(uname -sr)"
OS_NAME="$(uname -s)"
UPTIME_OUTPUT="$(uptime || true)"
DISK_USAGE="$(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')"
if command -v free >/dev/null 2>&1; then
  MEMORY_SUMMARY="$(free -h 2>/dev/null | awk 'NR==2 {print $3 "/" $2}')"
else
  MEMORY_SUMMARY=""
fi
LOAD_AVG="$(uptime | awk -F 'load average: ' '{print $2}' 2>/dev/null)"

if command -v systemctl >/dev/null 2>&1; then
  SERVICE_HEADING="### Services snapshot (systemctl)"
  SERVICE_OUTPUT="$(systemctl list-units --type=service --state=running --no-pager | head -n 15 2>&1 || true)"
elif [[ "$OS_NAME" == "Linux" ]]; then
  SERVICE_HEADING="### Processes snapshot (ps)"
  SERVICE_OUTPUT="$(ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 15 2>&1 || true)"
else
  SERVICE_HEADING="### Processes snapshot"
  SERVICE_OUTPUT="Process snapshot unavailable on $OS_NAME without elevated permissions."
fi

if command -v ss >/dev/null 2>&1; then
  SOCKET_HEADING="### Listening sockets (ss)"
  SOCKET_OUTPUT="$(ss -tulpn 2>&1 | head -n 15 || true)"
elif [[ "$OS_NAME" == "Linux" ]] && command -v netstat >/dev/null 2>&1; then
  SOCKET_HEADING="### Listening sockets (netstat)"
  SOCKET_OUTPUT="$(netstat -tulpn 2>&1 | head -n 15 || true)"
else
  SOCKET_HEADING="### Listening sockets"
  SOCKET_OUTPUT="Listening socket snapshot unavailable on $OS_NAME without additional tooling."
fi

{
  cat <<EOF
# Local System Health Report

- Generated at (UTC): $(date -u +'%Y-%m-%d %H:%M:%SZ')
- Hostname: $HOSTNAME
- Kernel: $KERNEL
- Uptime: ${UPTIME_OUTPUT:-unavailable}
- Disk usage (/): $DISK_USAGE
- Memory usage: ${MEMORY_SUMMARY:-use the \`free -h\` command on this host}
- Load average: ${LOAD_AVG:-unavailable}
- Metrics sample: $METRICS_VALUE

## Recent Metrics (JSON)

$METRICS_DESC

$QUICK_PEEK_SECTION

## Service Checks

$SERVICE_HEADING

EOF

  printf '%s\n' "\`\`\`bash"
  printf '%s\n' "${SERVICE_OUTPUT:-Unavailable}"
  printf '%s\n\n' "\`\`\`"
  printf '%s\n\n' "$SOCKET_HEADING"
  printf '%s\n' "\`\`\`bash"
  printf '%s\n' "${SOCKET_OUTPUT:-Unavailable}"
  printf '%s\n\n' "\`\`\`"

  cat <<EOF
## Recommended Next Steps

1. Ship \`$REPORT_BASENAME\` as a CI artifact for portfolio evidence.
2. Compare load/memory snapshots over time to identify drift.
3. Extend this script with service checks relevant to your stack.
EOF
} >"$REPORT_PATH"

echo "Generated $REPORT_PATH"
echo "Captured metrics at $METRICS_PATH"
