---
status: accepted
date: 2026-08-22
---

# Use neovim as the editor

## Context and Problem Statement

VSCode has been my daily driver for years (SublimeText before that). However, I've never
loved it (settings are arcane, extensions break, terminals are wonky, etc.) and now
parallel agent workflows throw a new wrench into it: I mix up which worktree each VSCode
window is editing. Yes, it's in the title bar, but too many times I've edited code in the
wrong worktree and caused havoc. I want an editor that can live in a tmux window alongside
the agent session, so the two are coupled.

## Considered Options

- VSCode with a vim extension
- vim 9
- helix
- neovim

## Decision

[Neovim](https://neovim.io/) — Lua configuration, a built-in LSP client and treesitter,
and the place new plugin work ships first.

**GUI editors lose on the tmux constraint, not on features.** VSCode, Cursor, and Zed all
have credible vim modes; none of them can be a pane.

**Helix is a near-miss.** Batteries included, zero configuration, LSP and treesitter
shipped. Selection-first grammar is a great idea, but feels too unproven to build my
muscle memory around it.

**vim 9 loses on ecosystem.** Vim9script is fast, but plugins are written against neovim's
Lua API now, and vim has no built-in LSP client or treesitter.
