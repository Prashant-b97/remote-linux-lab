# DevOps Fundamentals Checklist

Segfault practice is more than running commands—it is about building repeatable habits. These sections outline the routines I follow, phrased simply enough for onboarding notebooks yet detailed enough to satisfy audits.

## Infrastructure Hygiene

- Track every SSH alias and config snippet in version control, but keep private keys out of Git. A short README entry or `docs/ssh-access.md` update prevents drift.
- Store hostnames, passwords, and expiry dates in a password manager so you can reset the lab quickly.
- Capture a fresh snapshot with `./scripts/collect-system-info.sh` whenever you finish a session. The Markdown report becomes a time capsule of the environment.

## Configuration Management

- Pull critical configs (for example `/etc/ssh/sshd_config`) down with `scp` before editing. Work locally, then push changes back once reviewed.
- Run `git diff` on your scratch copies to highlight what changed and add context in commit messages or notes.
- Turn one-off fixes into idempotent shell snippets. Re-running them should bring the host into the desired state without surprises.

## Observability

- Set a cadence: inspect `journalctl`, `tail -F /var/log/syslog`, or application logs before and after a change.
- Learn lightweight tools like `vmstat`, `iostat`, and `ss`; they provide quick answers even on minimal installations.
- Document anomalies in `notes/` so patterns emerge across sessions.

## Automation

- Grow the `scripts/` directory with helpers for backups, log collection, or service restarts—small, well-commented scripts save time later.
- When a task recurs, schedule it: use `cron` on simple boxes or `systemd` timers when they are available.
- Add graceful error handling so automation fails loudly and leaves clues for future troubleshooting.

## Collaboration & Documentation

- Summarise each lab in Markdown: what problem you tackled, what commands you ran, and what you learned.
- Link to supporting playbooks inside `docs/` so future readers can dive deeper without searching elsewhere.
- Share sanitized snippets or diagrams with teammates. Teaching the workflow reinforces your own understanding and surfaces blind spots.

