#!/usr/bin/env bash
# Review a local sshd_config for common hardening guardrails.
# Defaults to /etc/ssh/sshd_config but accepts an override.
set -euo pipefail

CONFIG_PATH="/etc/ssh/sshd_config"
SHOW_HELP=false

usage() {
  cat <<'EOF'
Usage: check-ssh-hardening.sh [--config PATH]

Flags:
  --config PATH   Path to sshd_config to inspect (default: /etc/ssh/sshd_config)
  --help          Show this help text
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --config)
      [[ $# -lt 2 ]] && { echo "--config requires a path" >&2; exit 1; }
      CONFIG_PATH="$2"
      shift 2
      ;;
    --help|-h)
      SHOW_HELP=true
      shift
      ;;
    *)
      echo "Unknown flag: $1" >&2
      exit 1
      ;;
  esac
done

if $SHOW_HELP; then
  usage
  exit 0
fi

if [[ ! -f "$CONFIG_PATH" ]]; then
  echo "Config file not found: $CONFIG_PATH" >&2
  exit 1
fi

normalise() {
  # Strip comments, trim whitespace, collapse multiple spaces.
  sed -e 's/#.*$//' -e 's/[\t ][\t ]*/ /g' -e 's/^ *//;s/ *$//' "$1"
}

get_value() {
  local key="$1"
  normalise "$CONFIG_PATH" | awk -v key="$key" 'tolower($1) == tolower(key) {val=$2} END {if (length(val) > 0) print val}'
}

print_row() {
  printf '| %-28s | %-7s | %-6s | %s |\n' "$1" "$2" "$3" "$4"
}

failures=0

check_setting() {
  local key="$1"; shift
  local desired="$1"; shift
  local severity="$1"; shift
  local rationale="$1"; shift

  local actual
  actual="$(get_value "$key")"

  if [[ -z "$actual" ]]; then
    print_row "$key" "unset" "info" "Inherits vendor default; confirm manually."
    return
  fi

  if [[ "$actual" =~ ^[Yy][Ee][Ss]$ ]]; then
    actual="yes"
  elif [[ "$actual" =~ ^[Nn][Oo]$ ]]; then
    actual="no"
  fi

  if [[ "$actual" == "$desired" ]]; then
    print_row "$key" "$actual" "pass" "Matches guardrail."
  else
    print_row "$key" "$actual" "$severity" "$rationale"
    ((failures++))
  fi
}

weak_macs() {
  normalise "$CONFIG_PATH" | awk 'tolower($1)=="macs" {print tolower($2)}'
}

legacy_kex() {
  normalise "$CONFIG_PATH" | awk 'tolower($1)=="kexalgorithms" {print tolower($2)}'
}

print_header() {
  echo "# SSH Hardening Review"
  echo
  echo "- Inspected file: $CONFIG_PATH"
  echo "- Generated at (UTC): $(date -u +'%Y-%m-%d %H:%M:%SZ')"
  echo
  echo '| Setting                      | Value   | Status | Notes |'
  echo '| --------------------------- | ------- | ------ | ----- |'
}

print_summary() {
  echo
  if (( failures == 0 )); then
    echo "All tracked hardening checks passed."
  else
    echo "$failures guardrail(s) need attention."
  fi
}

print_header
check_setting PermitRootLogin no warn "Disable remote root login or restrict to prohibit-password."
check_setting PasswordAuthentication no warn "Prefer SSH keys instead of passwords."
check_setting ChallengeResponseAuthentication no warn "Legacy challenge-response methods should be disabled unless MFA requires them."
check_setting MaxAuthTries 6 info "Values >6 increase brute-force exposure; tighten if possible."
check_setting AllowAgentForwarding no info "Agent forwarding should only be enabled on trusted jump hosts."

macs="$(weak_macs)"
if [[ -n "$macs" && "$macs" =~ (hmac-md5|hmac-sha1) ]]; then
  echo
  echo "WARNING: Weak MAC detected (\`hmac-md5\`/\`hmac-sha1\`). Prefer modern algorithms such as \`hmac-sha2-256\`."
  ((failures++))
fi

kex="$(legacy_kex)"
if [[ -n "$kex" && "$kex" =~ (diffie-hellman-group1-sha1|diffie-hellman-group14-sha1) ]]; then
  echo
  echo "WARNING: Legacy key exchange detected. Rotate to \`curve25519-sha256\` or stronger ecdh variants."
  ((failures++))
fi

print_summary

exit $(( failures > 0 ? 2 : 0 ))
