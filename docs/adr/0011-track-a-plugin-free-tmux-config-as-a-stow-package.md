---
status: accepted
date: 2026-08-20
---

# Track a plugin-free tmux config as a stow package

## Context and Problem Statement

tmux is where a working session lives: a session is a repo, a window is a worktree, and
panes are roles within it. We want to track those as settings.

## Considered Options

- tmux, driven by workmux
- Ghostty's own tabs and splits

## Decision

**Tracked as `tmux/.config/tmux/tmux.conf`.**

Ghostty's native tabs and splits lose because worktrees are ephemeral: one appears, earns
a window, and is gone. Automating that churn is workmux's job, and workmux drives tmux.

**No plugins and no tpm.** Each candidate either hid details or duplicated something tmux
or workmux already does.

## More Information

Colours are the terminal's sixteen palette slots, named rather than hex, so the chrome
follows whatever theme Ghostty is set to.

This config owns _navigation_; workmux owns session and window _creation_. Whether workmux
itself belongs in this repo is still open.

Revisit the plugin decision for hint-based copy (tmux-thumbs, extrakto) and for
vim-tmux-navigator once neovim replaces VS Code — the two real capability gaps.
