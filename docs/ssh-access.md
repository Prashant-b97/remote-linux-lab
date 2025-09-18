# SSH Access Playbook

This guide keeps SSH setup clear enough for newcomers while staying precise for anyone reviewing the workflow. The goal: reach a Segfault lab host quickly, safely, and with minimal surprises.

## 1. Prepare the Local Environment

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
```

- `mkdir -p` creates the SSH directory if it does not exist; the `-p` flag prevents errors when the folder is already there.
- `chmod 700` ensures only your user can read or modify the directory, which is a common security expectation on Linux and macOS.

## 2. Store the Segfault Private Key

```bash
cat > ~/.ssh/id_sf-lsd-segfault-net <<'__KEY__'
-----BEGIN OPENSSH PRIVATE KEY-----
...
-----END OPENSSH PRIVATE KEY-----
__KEY__
chmod 600 ~/.ssh/id_sf-lsd-segfault-net
```

- The here-document (`<<'__KEY__'`) captures the key without risking clipboard leaks.
- `chmod 600` locks the file down to “read/write for me only,” which OpenSSH enforces.

## 3. Create a Friendly Host Alias

```bash
cat >> ~/.ssh/config <<'__CONF__'
Host releasecoffee
    HostName segfault.net
    User root
    IdentityFile ~/.ssh/id_sf-lsd-segfault-net
    IdentitiesOnly yes
__CONF__
chmod 600 ~/.ssh/config
```

- Aliases such as `releasecoffee` reduce typing and remove the need to remember passwords.
- `IdentitiesOnly yes` tells SSH to use the key you specify instead of guessing through every key on disk.
- Reset the file permissions to 600 so OpenSSH accepts the config file.

## 4. Connect and Confirm Where You Landed

```bash
ssh releasecoffee
whoami
hostname
id
```

- `whoami`, `hostname`, and `id` form a quick identity check—vital when juggling multiple shells.
- Include `uptime` if you want to confirm whether the host rebooted between sessions.

## 5. Keep the Workflow Hardened

- Guard your private key; never commit it to Git or share screenshots that include it.
- Turn off StrictHostKeyChecking only for short-lived hosts. Otherwise, leave host keys in place to detect man-in-the-middle attempts.
- Rotate the key promptly if Segfault issues a new download or you suspect exposure.
- Update the alias whenever Segfault renames the environment—the convenience only helps if the entry stays fresh.

## 6. Troubleshoot with Confidence

- Use `ssh -vv releasecoffee` to watch the handshake when authentication fails.
- Remove stale fingerprints with `ssh-keygen -R segfault.net` if the host was rebuilt.
- Confirm your local firewall allows outbound TCP/22 (or the port you set) when the connection hangs.
- If latency is high, add `ControlMaster auto` and `ControlPersist 5m` blocks to `~/.ssh/config` so future sessions reuse the first connection.
