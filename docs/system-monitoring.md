# System Monitoring Cheatsheet

Hands-on monitoring is about reading the room—understanding what the system is doing right now and noticing when it drifts from normal behaviour. The commands below use plain language explanations so newcomers and reviewers stay aligned.

## Quick Inventory

```bash
uname -a                  # kernel version and architecture
uptime -p                 # how long the box has been alive
cat /config/self/limits   # Segfault-specific CPU, RAM, and process quotas
```

- Start every session with these three commands to frame the environment you are debugging.
- The limits file is unique to Segfault; it mirrors the guardrails enforced by the platform.

## CPU & Load

```bash
uptime                                        # quick view of 1/5/15 minute load averages
grep -c '^processor' /proc/cpuinfo            # count logical cores
ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head # top CPU consumers
```

- Compare load averages to the CPU count; a load near or above the number of cores suggests saturation.
- The `ps` snippet points at runaway processes without opening an interactive `top` session.

## Memory

```bash
free -h                # human-readable snapshot of RAM usage
vmstat 5 5             # rolling view of memory, swap, and context switches
```

- On small Segfault hosts, swap is often disabled—confirm that assumption before tuning workloads.
- Watch the `vmstat` output for sustained `si/so` (swap in/out) values; that's a classic sign the instance needs more memory or tighter limits.

## Disk & Storage

```bash
df -h                  # file system utilisation
lsblk                  # block devices and mount hierarchy
du -sh /sec            # encrypted persistent storage footprint
```

- `df -h` highlights when overlay storage is close to full; in Segfault, that usually resets on reboot.
- `/sec` is the safe place for notes and configs you want to keep—track its size so you never hit the 4 GB ceiling mid-task.

## Processes & Services

```bash
top -b -n1 | head -n 20                       # grab a non-interactive top snapshot
systemctl list-units --type=service --state=running
journalctl -n 50 --no-pager
```

- Batch mode `top` is friendly for logging—same data as the interactive tool, none of the keybindings.
- Some Segfault boxes run without `systemd`; wrap calls in `command -v systemctl` when writing scripts.
- `journalctl` pairs well with `collect-system-info.sh`; the script already captures the last 50 lines for time-travel debugging.

## Networking

```bash
ip addr show         # IPs per interface, including IPv6
ss -tulpn | head     # listening sockets with owning processes
```

- Use `ss -tulpn | grep -v 127.0.0.1` to surface network services facing outward.
- For quick latency checks, add `ping -c 4 segfault.net` or `mtr` if the package is available.

## Automate Snapshots

`./scripts/collect-system-info.sh` consolidates everything above into a single Markdown report. Drop those files into version control or a shared folder so teammates can review what you saw without recreating the session from scratch.
