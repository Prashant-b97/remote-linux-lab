# File Transfer Recipes

Segfault labs are great for practicing how files move between local and remote systems.

## Copy From Local to Remote

```bash
scp ./hello.py releasecoffee:/sec/hello.py
```

- `/sec` is the persistent encrypted storage; files in `/root` vanish after rebuilds.
- Use `-P` if Segfault assigns a non-default port.

## Copy From Remote to Local

```bash
scp releasecoffee:/sec/hello.py ./backups/hello.py
```

- Create a `backups/` directory locally to organize artifacts.
- Add `-r` to transfer directories.

## Sync Large Trees

```bash
rsync -avz releasecoffee:/sec/. ./segfault-sec-backup/
```

- `rsync` handles deltas and preserves permissions.
- Add `--dry-run` to preview changes.

## SFTP Interactive Sessions

```bash
sftp releasecoffee
sftp> lpwd
sftp> pwd
sftp> put README.md /sec/
sftp> get /sec/notes.log ./downloads/
sftp> bye
```

## Verification

- Use checksums before/after (`sha256sum file`).
- Confirm ownership and permissions with `ls -l`.
- Keep sensitive data out of the repo; stash secrets in `/sec` or your password manager.
