# System Report: lsd-ReleaseCoffee

- Generated at (UTC): 2025-09-18 16:45:11Z
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
 16:45:11 up 0 min,  0 users,  load average: 0.81, 0.70, 0.56
```
```bash
$ ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 10
    PID COMMAND         %CPU %MEM
     26 bash            57.1  0.1
      1 docker-init      0.1  0.0
      7 sleep            0.0  0.0
     41 ps               0.0  0.1
     42 head             0.0  0.0
```

## Storage

```bash
$ df -h
Filesystem          Size  Used Avail Use% Mounted on
overlay             8.0G  8.0K  8.0G   1% /
tmpfs                64M     0   64M   0% /dev
/dev/md1             12G  4.1G  6.8G  38% /usr/sbin/docker-init
[encfs-MUyYTdmZmM]  4.0G  200K  4.0G   1% /sec
[encfs-everyone]    746G  446G  301G  60% /everyone
[encfs-www]         746G  446G  301G  60% /onion
tmpfs               2.0G     0  2.0G   0% /tmp
tmpfs                63G  7.1M   63G   1% /config/self
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
Mem:           2.0Gi       2.3Mi       2.0Gi          0B          0B       2.0Gi
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
317995: eth0@if317996: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1420 qdisc cake state UP group default qlen 1000
    link/ether 02:42:64:7e:e0:20 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 100.126.224.32/22 brd 100.126.227.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::42:64ff:fe7e:e020/64 scope link 
       valid_lft forever preferred_lft forever
```
```bash
$ ss -tulpn
Netid State  Recv-Q Send-Q Local Address:Port  Peer Address:PortProcess
udp   UNCONN 0      0         127.0.0.11:35013      0.0.0.0:*          
tcp   LISTEN 0      4096      127.0.0.11:36105      0.0.0.0:*          
```

## Security Posture

```bash
$ sshd -T | grep -E '^(permitrootlogin|passwordauthentication|challengeresponseauthentication)'
permitrootlogin without-password
passwordauthentication yes
```
