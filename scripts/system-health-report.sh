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

mkdir -p "$LOG_DIR"

# Capture a short burst of metrics using the existing monitoring scaffold.
"$SCRIPT_DIR/monitor.sh" --format json --interval 2 --count 5 --output "$METRICS_PATH"

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
- Metrics sample: \`$(basename "$METRICS_PATH")\`

## Recent Metrics (JSON)

The file \`$(basename "$METRICS_PATH")\` contains five samples captured via \`monitor.sh\`.

### Quick Peek

Run the following to inspect locally:

\`\`\`bash
jq '.' "$METRICS_PATH"
\`\`\`

## Service Checks

$SERVICE_HEADING

EOF

  printf '```bash\n%s\n```\n\n' "${SERVICE_OUTPUT:-Unavailable}" 2>/dev/null
  printf '%s\n\n' "$SOCKET_HEADING"
  printf '```bash\n%s\n```\n\n' "${SOCKET_OUTPUT:-Unavailable}" 2>/dev/null

  cat <<EOF
## Recommended Next Steps

1. Ship \`$(basename "$REPORT_PATH")\` as a CI artifact for portfolio evidence.
2. Compare load/memory snapshots over time to identify drift.
3. Extend this script with service checks relevant to your stack.
EOF
} >"$REPORT_PATH"

echo "Generated $REPORT_PATH"
echo "Captured metrics at $METRICS_PATH"
