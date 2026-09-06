---
status: accepted
date: 2026-08-22
---

# Start neovim from kickstart.nvim

## Context and Problem Statement

Stock Neovim ships without a fuzzy finder, completion, or LSP servers wired up, so a
usable setup has to be assembled. The assembly can come preconfigured as a distro or be
written by hand.

## Considered Options

- Stock neovim
- kickstart.nvim
- A distro (LazyVim, NvChad, AstroNvim)

## Decision

[kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) — a single commented
`init.lua` written to be read, understood, and edited. It is copied into the `nvim` stow
package and owned from there, not tracked as a fork of upstream.

**A distro loses because it hides the decisions.** Tons of plugins I didn't choose, behind
a configuration layer that obscures neovim's own behaviour, doesn't empower ownership and
mastery of this key tool.

**Stock loses on time.** The gap between it and a working editor is real work that
kickstart has already done and documented.

## More Information

Plugins are managed by `vim.pack`, Neovim's built-in package manager and kickstart's own
choice. Its lockfile is stowed alongside `init.lua`, so `vim.pack` writes plugin revisions
straight into this repo. It records only `rev`, `src` and `version` — nothing
machine-specific — and pinning them means a new machine gets this editor rather than
whatever each plugin's HEAD happens to be that day. Updating plugins therefore dirties the
worktree, which is what a lockfile is for.

Stow cannot place the symlink if `~/.config/nvim/nvim-pack-lock.json` already exists as a
real file, which is what running Neovim before `bootstrap.sh` leaves behind. Delete it and
re-stow; the repo's copy is the authority.
