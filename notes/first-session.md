# First Segfault Server Session (ReleaseCoffee)

## Commands Run

```bash
ssh root@segfault.net
# password: segfault

cat /config/self/limits
whoami && hostname && uptime
id
df -h
du -sh /sec
ls -la /sec
nano myfile.txt
vi myfile.txt
```

## Learnings

- Connected to a remote Linux server as root
- Discovered limits (CPU, RAM, storage, network)
- Understood difference between `/` (ephemeral) and `/sec` (persistent encrypted storage)
- Practiced using `nano` and `vim` editors
- Learned to copy files back to the local machine using `scp`
