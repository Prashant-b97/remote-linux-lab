# SSHD Baseline Playbook

The system report script can diff a remote `/etc/ssh/sshd_config` against a local baseline when the `SSHD_BASELINE` environment variable is set. Use this playbook to capture and sanitize that reference copy.

## 1. Export the Live Config

```bash
ssh releasecoffee 'sshd -T' | sort > /tmp/sshd-effective.conf
ssh releasecoffee 'cat /etc/ssh/sshd_config' > /tmp/sshd-raw.conf
```

- The `sshd -T` dump normalizes includes and defaults—great for comparison.
- Keep `/tmp/sshd-raw.conf` handy so you can track comments or Match blocks that do not appear in the generated view.

## 2. Sanitize and Trim

Open the raw file locally and remove values that change per host (e.g., `ListenAddress`, `HostKey` paths, custom banners). Align formatting with the sample in `examples/sshd_config.baseline` so diffs stay tidy.

```bash
cp /tmp/sshd-raw.conf examples/sshd_config.baseline
nano examples/sshd_config.baseline
```

Keep only the directives that matter for your policy. Comment anything informational so future you knows why it is present.

## 3. Store It Securely

- Commit the sanitized baseline if it contains no secrets.
- Otherwise, stash it in a password manager or encrypted vault and point `SSHD_BASELINE` at that path when running `collect-system-info.sh`.

## 4. Run the Drift Check

```bash
SSHD_BASELINE=examples/sshd_config.baseline ./scripts/collect-system-info.sh releasecoffee
```

The generated report will append an **SSHD Config Drift** section and embed a `diff -u` block when changes are detected.

## 5. Review & Act

- Investigate any unexpected loosened authentication controls (`PermitRootLogin`, `PasswordAuthentication`, etc.).
- Follow up on newly opened ports or included configuration snippets.

Rinse and repeat whenever you harden the remote host or refresh the Segfault instance.
