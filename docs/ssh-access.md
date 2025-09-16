# SSH Access Playbook

## Overview

Segfault.net issues ephemeral root access, so fast and secure SSH setup matters. This guide captures the steps I follow each time I spin up a lab server.

## Configure Local Shortcuts

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Store the private key provided by Segfault
cat > ~/.ssh/id_sf-lsd-segfault-net <<'__KEY__'
-----BEGIN OPENSSH PRIVATE KEY-----
...
-----END OPENSSH PRIVATE KEY-----
__KEY__
chmod 600 ~/.ssh/id_sf-lsd-segfault-net

# Create a shortcut alias for faster logins
cat >> ~/.ssh/config <<'__CONF__'
Host releasecoffee
    HostName segfault.net
    User root
    IdentityFile ~/.ssh/id_sf-lsd-segfault-net
    IdentitiesOnly yes
__CONF__
chmod 600 ~/.ssh/config
```

## Connect and Verify Identity

```bash
ssh releasecoffee
whoami
hostname
id
```

## Hardening Tips

- Restrict private key permissions (`chmod 600`).
- Disable host key checking only if the environment is fully disposable.
- Rotate keys when the Segfault lab hands out replacements.
- Keep the shortcut current—hostname aliases change as new boxes are launched.

## Troubleshooting

- `ssh -vv releasecoffee` reveals handshake problems.
- Remove stale host fingerprints from `~/.ssh/known_hosts` if the box is rebuilt.
- Ensure your local firewall permits outbound TCP/22.
