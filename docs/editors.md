# Editing on Remote Hosts

Practicing with both `nano` and `vim` builds confidence when working in constrained environments.

## Nano Quickstart

```bash
nano /etc/motd
```

Shortcuts to remember:

- `Ctrl+O` save buffer to disk.
- `Ctrl+X` exit the editor.
- `Ctrl+W` search inside the file.

Use `nano -l` to show line numbers when editing configuration files.

## Vim Essentials

```bash
vim /sec/notes/journal.md
```

Key commands:

- `i` enter insert mode.
- `Esc` return to normal mode.
- `:wq` write and quit.
- `:q!` quit without saving.
- `/pattern` search forward, `n` to repeat.

Enable syntax highlighting for configuration files by placing them under `/sec` and adding lines to `~/.vimrc`:

```bash
cat >> ~/.vimrc <<'__EOF__'
set number
syntax on
set expandtab shiftwidth=4
__EOF__
```

## Remote Editing Tips

- Always back up critical files before editing (`cp file file.bak`).
- When editing services, reload or restart them and tail logs (`journalctl -f`).
- Combine with `tmux` so you can resume sessions after network hiccups.
