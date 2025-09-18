# System Report: lsd-ReleaseCoffee

- Generated at (UTC): 2025-09-18 16:49:09Z
- Kernel: Linux 5.10.0-35-amd64
- Uptime: up 0 minutes

## Identity & Sessions

```bash
$ who
```
```bash
$ last -n 5
[command exited with 127]
```

## Load & Processes

```bash
$ uptime
 16:49:09 up 0 min,  0 users,  load average: 0.45, 0.56, 0.53
```
```bash
$ ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 10
    PID COMMAND         %CPU %MEM
     18 bash            42.8  0.1
      1 docker-init      5.3  0.0
      7 sleep            0.0  0.0
     33 ps               0.0  0.1
     34 head             0.0  0.0
```

## Storage

```bash
$ df -h
Filesystem          Size  Used Avail Use% Mounted on
overlay             8.0G  8.0K  8.0G   1% /
tmpfs                64M     0   64M   0% /dev
/dev/md1             12G  4.1G  6.8G  38% /usr/sbin/docker-init
[encfs-everyone]    746G  446G  301G  60% /everyone
[encfs-MUyYTdmZmM]  4.0G  200K  4.0G   1% /sec
[encfs-www]         746G  446G  301G  60% /onion
tmpfs               2.0G     0  2.0G   0% /tmp
tmpfs                63G  7.0M   63G   1% /config/guest
/dev/md2p2          746G  446G  301G  60% /sf/share
tmpfs               2.0G     0  2.0G   0% /dev/shm
/dev/mapper/sfluks  8.0G  239M  7.8G   3% /etc/hosts
tmpfs                63G     0   63G   0% /proc/acpi
tmpfs                63G     0   63G   0% /sys/firmware
```
```bash
$ du -sh /sec 2>/dev/null
192K	/sec
```

## Memory

```bash
$ free -h
               total        used        free      shared  buff/cache   available
Mem:           2.0Gi       2.2Mi       2.0Gi          0B          0B       2.0Gi
Swap:             0B          0B          0B
```

## Network

```bash
$ ip addr show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
318007: eth0@if318008: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1420 qdisc cake state UP group default qlen 1000
    link/ether 02:42:64:7e:e0:05 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 100.126.224.5/22 brd 100.126.227.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::42:64ff:fe7e:e005/64 scope link tentative 
       valid_lft forever preferred_lft forever
```
```bash
$ ss -tulpn
Netid State  Recv-Q Send-Q Local Address:Port  Peer Address:PortProcess
udp   UNCONN 0      0         127.0.0.11:54720      0.0.0.0:*          
tcp   LISTEN 0      4096      127.0.0.11:39963      0.0.0.0:*          
```

## Security Posture

```bash
$ sshd -T | grep -E '^(permitrootlogin|passwordauthentication|challengeresponseauthentication)'
permitrootlogin without-password
passwordauthentication yes
```
```bash
$ ss -tulpn | awk 'NR==1 {print; next} !/(127\.0\.0\.1|\[::1\])/ {print}'
Netid State  Recv-Q Send-Q Local Address:Port  Peer Address:PortProcess
```
```bash
$ nft list ruleset
[command exited with 1]
```

## Running Services

```bash
$ systemctl list-units --type=service --state=running
[command exited with 1]
```

## Recent Journal

```bash
$ journalctl -n 50 --no-pager
-- No entries --
```
