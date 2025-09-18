# Editing on Remote Hosts

Segfault sessions are a chance to stay fluent in both simple and modal editors. The tips below describe what each command does so you can explain the workflow to teammates or follow it as a newcomer.

## Nano: Quick Edits with Familiar Shortcuts

```bash
nano -l /etc/motd
```

- `-l` shows line numbers—a lifesaver when copying instructions from documentation.
- `Ctrl+O` writes the current buffer, `Ctrl+X` exits, and `Ctrl+W` searches inside the file.
- Use `Ctrl+K`/`Ctrl+U` to cut and uncut lines while refactoring configuration blocks.
- Save interim copies such as `/etc/motd.bak` before large edits so you can roll back instantly.

## Vim: Comfortable Once You Practise

```bash
vim /sec/notes/journal.md
```

- `i` enters Insert mode, `Esc` returns to Normal mode.
- `:w` saves your changes, `:q!` quits without saving, and `:wq` does both.
- Search forward with `/pattern`, repeat with `n`, and go backwards with `N`.
- Visual mode (`v`) lets you highlight blocks before copying or indentation adjustments.

### Personalising Vim Quickly

```bash
cat >> ~/.vimrc <<'__EOF__'
set number                    " show line numbers
syntax on                     " highlight config keywords
set expandtab shiftwidth=4    " convert tabs to spaces for consistency
set fileencodings=utf-8
__EOF__
```

- Appending to `~/.vimrc` makes every Segfault session feel more familiar without touching system files.
- Keep the file under `/sec` if you want the settings to persist.

## Shared Good Practices

- Back up configuration files (`cp file file.bak`) before editing; if something breaks, restore quickly with `mv file.bak file`.
- When changing service configs, restart or reload, then watch logs with `journalctl -f` or `tail -F` so you catch errors immediately.
- Run editors inside `tmux` or `screen` sessions to survive flaky network connections.
- Document tricky edits in `notes/` with the reasoning behind them—future you will thank present you.

