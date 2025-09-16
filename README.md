# 🐧 Remote Linux Lab (Segfault.net Playground)

Hands-on practice with remote Linux servers using [Segfault.net](https://thc.org/segfault).  
The goal: build **DevOps & SysAdmin fundamentals** by actually working as **root** on ephemeral cloud servers—covering SSH access, live system monitoring, file transfers, and comfort with terminal editors.

---

## 🚀 Skills Learned

- **SSH & Secure Access**
  - Connected to remote servers via `ssh root@segfault.net`
  - Configured `~/.ssh/config` with identity files and secrets
  - Managed private keys with correct permissions
- **System Administration Basics**
  - Explored system resources with `whoami`, `id`, `df -h`, `uptime`
  - Learned about ephemeral root vs persistent encrypted storage (`/sec`)
- **File Management**
  - Created and edited files using `nano` and `vim`
  - Practiced file transfer via `scp` and `sftp` between Mac ↔ remote server
- **Process & Session Management**
  - Understood background jobs using `nohup`
  - Explored persistent sessions with `tmux`

---

## 🖥️ Demo Steps

1. **Connect to the server**
   ```bash
   ssh root@segfault.net
   # password: segfault
   ```
2. **Save SSH access keys and config**
   ```bash
   cat > ~/.ssh/id_sf-lsd-segfault-net <<'__EOF__'
   -----BEGIN OPENSSH PRIVATE KEY-----
   ...
   -----END OPENSSH PRIVATE KEY-----
   __EOF__
   ```
3. **Use shortcut for easier login**
   ```bash
   ssh releasecoffee
   ```
4. **Explore system resources**
   ```bash
   cat /config/self/limits
   df -h
   du -sh /sec
   ```
5. **Edit files on the server**
   ```bash
   nano myfile.txt
   vi myfile.txt
   ```
6. **Transfer files to the local machine**
   ```bash
   scp releasecoffee:/sec/hello.py ~/Downloads/
   ```

---

## 📚 Learnings Recap

- Difference between ephemeral disks and persistent storage
- Secure server access with SSH keys and configs
- Editing configs in real-time using `nano` and `vim`
- Copying data between local and remote machines using `scp`/`sftp`
- Core Linux admin commands for monitoring & managing resources

---

## 🔗 Why This Project?

I wanted a safe playground to practice real DevOps/SRE workflows:

- Managing servers over SSH
- Exploring Linux commands
- Handling keys, secrets, and file transfers
- Building confidence with command-line editors

This repo serves as both my study notes and a portfolio project showcasing practical server management skills.

---

## 📂 Project Structure

```
remote-linux-lab/
│
├── README.md                # Project documentation (this file)
├── hello.py                 # Demo Python script
├── scripts/
│   └── collect-system-info.sh  # Collects remote diagnostics into Markdown reports
└── notes/
    ├── first-session.md     # Commands & learnings from first session
    └── reports/             # Generated system diagnostic reports
```

---

## 🛠️ Automation Reports

Use the `collect-system-info.sh` helper to capture a snapshot of the remote host after each practice run:

1. Ensure your SSH shortcut (e.g., `releasecoffee`) works without prompts.
2. Run `./scripts/collect-system-info.sh` to gather uptime, resource usage, running services, and recent logs.
3. Find the timestamped Markdown report under `notes/reports/`—perfect for diffing across sessions or sharing highlights.

Pass a different SSH host alias or `user@host` as the first argument when you want to target another Segfault instance.

---

## 📘 Guides & Playbooks

Deep dives that capture the core skills I'm practicing:

- [SSH Access Playbook](docs/ssh-access.md) — shortcuts, key management, troubleshooting.
- [System Monitoring Cheatsheet](docs/system-monitoring.md) — commands for CPU, memory, storage, network, services.
- [File Transfer Recipes](docs/file-transfers.md) — `scp`, `rsync`, and `sftp` workflows.
- [Editing on Remote Hosts](docs/editors.md) — nano/vim fundamentals and safety tips.
- [DevOps Fundamentals Checklist](docs/devops-basics.md) — hygiene, automation, and documentation habits.

---

## 🏷️ Topics

`linux` · `ssh` · `devops` · `sysadmin` · `cloud` · `vim` · `nano` · `scp` · `learning-project` · `portfolio`
