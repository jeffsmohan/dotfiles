---
status: accepted
date: 2026-08-20
---

# Use starship as the fish prompt

## Context and Problem Statement

For a while, I used `tide` via `fisher` to build my prompt. However, `tide` builds its
prompt by generating a bunch of variables and functions in `~/.config/fish/...` that don't
track and stow well in a dotfiles repo.

## Considered Options

- [tide](https://github.com/IlanCosman/tide) (via
  [fisher](https://github.com/jorgebucaran/fisher))
- [starship](https://starship.rs/)
- hand-written `fish_prompt`

## Decision

**Replace tide with starship.**

Starship's configuration is written as a single `starship.toml` file, which stows like
everything else in this repo.

A hand-written `fish_prompt` would also be a tracked file, but would mean owning git
parsing and other complexities best handled by a library.

The switch was taken as an opportunity to streamline, as well. (Right prompt, exit status,
command duration, host context, background jobs, six programming language versions, and
the timestamp were all dropped.)

That also dissolved most of the cost:

- Tide could render asynchronously where starship is only synchronous, so every prompt
  blocks (but only 19ms in a small repo, 29ms in a 3,400-file tree, and 4ms outside a
  repo.)
- Per-component path colouring is unsupported
- Hiding the right prompt in a narrow pane is unsupported
