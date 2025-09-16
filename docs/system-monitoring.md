# System Monitoring Cheatsheet

Hands-on monitoring is about observing live resource usage and spotting anomalies.

## Quick Inventory

```bash
uname -a
uptime -p
cat /config/self/limits
```

## CPU & Load

```bash
uptime
cat /proc/cpuinfo | grep '^processor'
ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head
```

## Memory

```bash
free -h
vmstat 5 5
```

## Disk & Storage

```bash
df -h
lsblk
du -sh /sec
```

## Processes & Services

```bash
top -b -n1 | head -n 20
systemctl list-units --type=service --state=running
journalctl -n 50 --no-pager
```

## Networking

```bash
ip addr show
ss -tulpn | head
```

## Automate Snapshots

Use `./scripts/collect-system-info.sh` after each session. Reports land in `notes/reports/` and show exactly what changed between labs.
