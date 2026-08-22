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
