# DevOps Fundamentals Checklist

This sandbox ties remote Linux practice into broader DevOps habits.

## Infrastructure Hygiene

- Maintain SSH keys, configs, and aliases under version control (but never the private key itself).
- Document hostnames, credentials, and expiry dates in a secure manager.
- Capture system state with `./scripts/collect-system-info.sh`.

## Configuration Management

- Keep `/etc` edits in the repo via scratch copies (`scp root@segfault.net:/etc/ssh/sshd_config docs/examples/`).
- Track diffs with `git diff` before applying changes.
- Practice idempotent shell snippets for repeated setups (e.g., user creation, package installs).

## Observability

- Standardize log reviews using `journalctl`, `tail -F`, and targeted filters.
- Watch metrics over time with `sar` or `vmstat` if installed.
- Record findings in `notes/` after each session for future reference.

## Automation

- Extend `scripts/` with repeatable tasks (backups, service restarts, log rotation).
- Use cron or `systemd` timers on the remote host to schedule recurring maintenance in `/sec`.

## Collaboration & Documentation

- Summarize each lab in Markdown—including problem statements, hypotheses, and resolutions.
- Link to relevant guides within `docs/` so future sessions build on past knowledge.
- Share sanitized snippets in blog posts or internal wikis to reinforce learning.
