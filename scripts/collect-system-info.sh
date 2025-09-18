#!/usr/bin/env bash
# Generate a timestamped Markdown report of key system diagnostics from a remote Segfault host.
set -euo pipefail

TMP_SSHD_CONFIG=""

cleanup() {
  if [[ -n "$TMP_SSHD_CONFIG" && -f "$TMP_SSHD_CONFIG" ]]; then
    rm -f "$TMP_SSHD_CONFIG"
  fi
}

trap cleanup EXIT

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
printf -- '- Generated at (UTC): %s\n' "$(date -u +'%Y-%m-%d %H:%M:%SZ')"
printf -- '- Kernel: %s\n' "$(uname -sr)"
if uptime -p >/dev/null 2>&1; then
  printf -- '- Uptime: %s\n' "$(uptime -p)"
else
  printf -- '- Uptime: %s\n' "$(uptime)"
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

section "Security Posture"
if command -v sshd >/dev/null 2>&1; then
  run_cmd "sshd -T | grep -E '^(permitrootlogin|passwordauthentication|challengeresponseauthentication)'"
else
  run_cmd "grep -Ei '^(PermitRootLogin|PasswordAuthentication|ChallengeResponseAuthentication)' /etc/ssh/sshd_config"
fi
if command -v ss >/dev/null 2>&1; then
  run_cmd "ss -tulpn | awk 'NR==1 {print; next} !/(127\\.0\\.0\\.1|\\[::1\\])/ {print}'"
fi
if command -v ufw >/dev/null 2>&1; then
  run_cmd "ufw status verbose"
elif command -v firewall-cmd >/dev/null 2>&1; then
  run_cmd "firewall-cmd --state"
  run_cmd "firewall-cmd --list-all"
elif command -v nft >/dev/null 2>&1; then
  run_cmd "nft list ruleset 2>/dev/null || nft list tables 2>/dev/null || echo '# nft: unable to read ruleset'"
elif command -v iptables >/dev/null 2>&1; then
  run_cmd "iptables -S 2>/dev/null || echo '# iptables: unable to read ruleset'"
fi
if command -v fail2ban-client >/dev/null 2>&1; then
  run_cmd "fail2ban-client status"
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

if [[ -n "${SSHD_BASELINE:-}" ]]; then
  if [[ -f "$SSHD_BASELINE" ]]; then
    TMP_SSHD_CONFIG="$(mktemp)"
    if ssh "$REMOTE_HOST" 'cat /etc/ssh/sshd_config' >"$TMP_SSHD_CONFIG" 2>/dev/null; then
      diff_output="$(diff -u "$SSHD_BASELINE" "$TMP_SSHD_CONFIG" || true)"
      {
        echo
        echo '## SSHD Config Drift'
        echo
        if [[ -n "$diff_output" ]]; then
          echo '```diff'
          printf '%s\n' "$diff_output"
          echo '```'
        else
          echo '_No differences versus baseline._'
        fi
      } >>"$REPORT_PATH"
    else
      echo "Unable to read /etc/ssh/sshd_config from $REMOTE_HOST" >&2
    fi
  else
    echo "SSHD_BASELINE path '$SSHD_BASELINE' not found; skipping diff" >&2
  fi
fi

echo "Saved report to $REPORT_PATH"
