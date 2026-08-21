---
status: accepted
date: 2026-08-21
---

# Use fish as the login shell

## Context and Problem Statement

macOS ships zsh as the default login shell, but I've preferred fish. The rest of this
dotfiles setup is built around fish as the default shell. `bootstrap.sh` did none of the
switching, so a fresh machine following the README landed in zsh.

## Considered Options

- fish as the login shell
- zsh as the login shell, with `exec fish` from `.zshrc`
- zsh as the login shell, fish started by hand

## Decision

**Make fish the login shell, and have `bootstrap.sh` do it.**

Bootstrap adds fish to `/etc/shells` and points the user record at it with `chsh`, each
guarded by a check so a re-run escalates only when something is actually missing.

`exec fish` from `.zshrc` is the usual way to avoid touching the user record, and it is
worse: `$SHELL` still reports zsh, so every tool that reads `$SHELL` to decide which
syntax to emit guesses wrong, and each terminal pays for two shell startups. Starting fish
by hand carries the same `$SHELL` problem and adds a manual step.
