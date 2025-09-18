# File Transfer Recipes

Segfault labs are ideal for practising safe file movement. Each section explains the intent of the command so a reviewer can follow the reasoning and a beginner can replicate the steps without guesswork.

## Copy from Local to Remote

```bash
scp ./examples/hello.py releasecoffee:/sec/hello.py
```

- `/sec` is the encrypted volume that survives reboots; store anything important there instead of `/root`.
- Add `-P 2222` (or the assigned port) when Segfault exposes SSH on a non-standard port.
- Large uploads benefit from compression: `scp -C bigfile.tgz releasecoffee:/sec/`.

## Copy from Remote to Local

```bash
scp releasecoffee:/sec/hello.py ./backups/hello.py
```

- Keep a `backups/` directory on your laptop or in the repo so downloaded artifacts stay organised.
- Append `-r` for directories (`scp -r releasecoffee:/sec/scripts ./backups/`).
- Use `-C` to squeeze log files or text-heavy data while downloading.

## Synchronise Larger Trees

```bash
rsync -avz releasecoffee:/sec/ ./segfault-sec-backup/
```

- `-a` preserves timestamps, permissions, and symbolic links; `-z` compresses the data stream.
- Start with `--dry-run` to preview changes, then rerun without it to apply.
- Pair with `--delete` once you trust the command so the backup mirrors the remote state.

## Interactive SFTP Sessions

```bash
sftp releasecoffee
sftp> lpwd                     # show local working directory
sftp> pwd                      # show remote working directory
sftp> put README.md /sec/      # upload a file
sftp> get /sec/notes.log ./downloads/
sftp> bye
```

- SFTP is useful when you prefer tab completion or need to inspect directories before transferring.
- Use `lcd` and `cd` inside the session to switch local and remote locations.
- `progress` toggles a transfer progress bar if your client supports it.

## Verification Ideas

- Compute checksums before and after (`sha256sum file`) to guarantee integrity.
- Confirm ownership and permissions using `ls -l` so services keep working after deployment.
- Keep sensitive data out of Git: stash secrets in `/sec`, an encrypted vault, or a password manager.
- For entire directories, `tar czf - dir | ssh releasecoffee 'tar xzf - -C /sec/'` avoids intermediate files on either side.

