#!/usr/bin/env bash
# Light-weight SSH hardening review. Runs sshd -T remotely and flags risky defaults.
# Helps beginners explain security trade-offs to reviewers while still sounding professional.
set -euo pipefail

REMOTE_HOST="${1:-releasecoffee}"
AUDIT_DIR="${AUDIT_BASE:-notes/reports}"
TIMESTAMP="$(date -u +'%Y-%m-%dT%H-%M-%SZ')"
AUDIT_PATH="$AUDIT_DIR/audit-${REMOTE_HOST}-${TIMESTAMP}.md"

mkdir -p "$AUDIT_DIR"

collect_sshd_dump() {
  local dump
  # Prefer sshd -T because it shows the active configuration after includes.
  if dump=$(ssh "$REMOTE_HOST" 'sshd -T' 2>/dev/null); then
    printf '%s\n' "$dump"
    return 0
  fi
  # Fallback: read raw config; may require sudo on hardened hosts.
  if dump=$(ssh "$REMOTE_HOST" 'cat /etc/ssh/sshd_config' 2>/dev/null); then
    printf '%s\n' "$dump"
    return 0
  fi
  return 1
}

sshd_dump="$(collect_sshd_dump)" || {
  echo "Failed to gather sshd configuration from $REMOTE_HOST" >&2
  exit 1
}

analyse_flag() {
  local key="$1"
  local expected="$2"
  local severity="$3"
  local rationale="$4"
  local actual
  actual=$(echo "$sshd_dump" | awk -v key="$key" '$1==key {print $2; exit}')
  if [[ -z "$actual" ]]; then
    printf "| \`%s\` | not set | info | Inherits vendor default; verify manually. |\\n" "$key"
    return
  fi
  if [[ "$actual" == "$expected" ]]; then
    printf "| \`%s\` | %s | pass | Matches guardrail. |\\n" "$key" "$actual"
  else
    printf "| \`%s\` | %s | %s | %s |\\n" "$key" "$actual" "$severity" "$rationale"
  fi
}

weak_kex() {
  echo "$sshd_dump" | awk '$1=="kexalgorithms" {print $2}'
}

{
  echo "# SSH Audit: $REMOTE_HOST"
  echo
  echo "- Generated at (UTC): $(date -u +'%Y-%m-%d %H:%M:%SZ')"
  echo "- Command: ./scripts/ssh-audit.sh $REMOTE_HOST"
  echo
  echo "## Configuration Flags"
  echo
  echo '| Setting | Value | Status | Notes |'
  echo '| --- | --- | --- | --- |'
  analyse_flag permitrootlogin no warn 'Root login should be disabled or forced to prohibit-password.'
  analyse_flag passwordauthentication no warn 'Prefer key-based auth only; rotate keys in docs/ssh-access.md.'
  analyse_flag challengeresponseauthentication no warn 'Disable legacy challenge-response auth unless MFA is in use.'
  analyse_flag maxauthtries 6 info 'Values >6 increase brute-force exposure; tighten if possible.'
  analyse_flag allowagentforwarding no info 'Agent forwarding should be disabled unless jump hosts require it.'
  echo
  echo "## Key Exchange Review"
  echo
  kex="$(weak_kex)"
  if [[ -z "$kex" ]]; then
    echo "_No custom key exchange list detected; host relies on defaults._"
  elif echo "$kex" | grep -qi 'diffie-hellman-group1-sha1'; then
    echo "⚠️ Weak algorithm detected (\`diffie-hellman-group1-sha1\`). Rotate to modern curves (e.g., curve25519)."
  else
    echo "Configured algorithms:"
    printf '%s\n' "$kex"
  fi
  echo
  echo "## Remediation Checklist"
  echo
  echo "- Update \`examples/sshd_config.baseline\` with approved values."
  echo "- Re-run \`collect-system-info.sh\` with \`SSHD_BASELINE\` to capture before/after diffs."
  echo "- Document any accepted risks in \`notes/\` with justification for auditors."
} >"$AUDIT_PATH"

echo "Saved audit to $AUDIT_PATH"
