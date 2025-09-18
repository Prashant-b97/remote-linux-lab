# 🐧 Remote Linux Lab (Segfault.net Playground)

Hands-on practice with remote Linux servers using [Segfault.net](https://thc.org/segfault).  
The aim is to build everyday **DevOps and system administration fundamentals** by spending time on real hosts as `root`. Each exercise keeps the language approachable while still sounding professional, so new learners and experienced reviewers can follow along comfortably.

---

## 🚀 Skills in Focus

- **SSH Hygiene** — logging in securely, managing identity files, and using friendly host aliases.
- **System Awareness** — checking quotas, uptime, and hardware limits so surprises are caught early.
- **File Operations** — editing configuration files in `nano` and `vim`, and moving artifacts with `scp` or `sftp`.
- **Session Reliability** — keeping work alive with `tmux` and understanding background execution with `nohup`.

---

## 🖥️ Walkthrough at a Glance

1. **Connect to the sandbox** — `ssh root@segfault.net` (password: `segfault`).
2. **Capture your key material** — store the provided OpenSSH key under `~/.ssh/` with strict permissions.
3. **Create a shortcut** — add a host alias like `releasecoffee` in `~/.ssh/config` so future logins are one command.
4. **Check system health** — run `cat /config/self/limits`, `df -h`, and `du -sh /sec` to understand resource limits and storage types.
5. **Edit safely** — practise in `nano` and `vim` so you can handle quick fixes as well as modal editing sessions.
6. **Move files around** — copy artifacts back home with `scp releasecoffee:/sec/hello.py ~/Downloads/` to verify transfer workflows end-to-end.

---

## 📚 What Each Session Reinforced

- Ephemeral disks reset on each boot, while `/sec` is encrypted storage that survives restarts—store important notes there.
- Solid SSH hygiene (keys, configs, permissions) pays off when rotating hosts or sharing access reviews.
- Comfort with both `nano` and `vim` prevents emergencies when only one editor is available on a stripped-down server.
- Transfers via `scp`/`sftp` close the loop between remote experiments and local documentation.
- Lightweight monitoring commands (`uptime`, `who`, `ps`, `df`) give a quick pulse check without needing a full observability stack.

---

## 🔗 Why This Project?

I wanted a safe playground to practice real DevOps/SRE workflows:

- Managing servers over SSH
- Exploring Linux commands
- Handling keys, secrets, and file transfers
- Building confidence with command-line editors

This repo doubles as study notes and a portfolio artifact so peers can trace the reasoning, not just the commands.

---

## 📂 Project Structure

```
remote-linux-lab/
│
├── README.md                # Project documentation (this file)
├── examples/
│   ├── hello.py             # Demo Python script used for transfer exercises
│   └── sshd_config.baseline # Sanitized SSH baseline for drift detection
├── scripts/
│   └── collect-system-info.sh  # Collects remote diagnostics into Markdown reports
└── notes/
    ├── first-session.md     # Narrative recap of the initial sandbox session
    ├── 2025-09-18.md        # Security-focused session notes with baseline guidance
    └── reports/             # Generated system diagnostic reports
```

---

## 🛠️ Automation Reports

Use the `collect-system-info.sh` helper to capture a snapshot of the remote host after each practice run:

1. Ensure your SSH shortcut (e.g., `releasecoffee`) works without prompts.
2. Run `./scripts/collect-system-info.sh` to gather uptime, resource usage, running services, and recent logs.
3. Review the timestamped Markdown report under `notes/reports/`—each file captures the exact state of the box.
4. Focus on the **Security Posture** section to see SSH authentication policy, firewall state, Fail2ban activity, and any listening sockets that expose the host beyond `localhost`.

Optional extras:

- Set `SSHD_BASELINE=/path/to/sshd_config` before running the script to append a config diff at the end of the report.
- Override the output directory with `REPORT_BASE=custom/dir ./scripts/collect-system-info.sh` when you want to stash reports elsewhere.
- Use the [SSHD Baseline Playbook](docs/ssh-baseline.md) to capture a hardened reference config and keep drift visible.

Pass a different SSH host alias or `user@host` as the first argument when you want to target another Segfault instance.

---

## 📘 Guides & Playbooks

Deep dives that capture the core skills I'm practicing:

- [SSH Access Playbook](docs/ssh-access.md) — shortcuts, key management, troubleshooting.
- [System Monitoring Cheatsheet](docs/system-monitoring.md) — commands for CPU, memory, storage, network, services.
- [File Transfer Recipes](docs/file-transfers.md) — `scp`, `rsync`, and `sftp` workflows.
- [Editing on Remote Hosts](docs/editors.md) — nano/vim fundamentals and safety tips.
- [DevOps Fundamentals Checklist](docs/devops-basics.md) — hygiene, automation, and documentation habits.
- [SSHD Baseline Playbook](docs/ssh-baseline.md) — capture and maintain configs for drift detection.

---

## 🏷️ Topics

`linux` · `ssh` · `devops` · `sysadmin` · `cloud` · `vim` · `nano` · `scp` · `learning-project` · `portfolio`
