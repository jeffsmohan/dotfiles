---
status: accepted
date: 2026-08-22
---

# Orchestrate git worktrees with workmux

## Context and Problem Statement

Running several AI agents means one git worktree each. Creating a worktree, naming it,
opening a tmux window, starting an agent in it, and tearing the whole thing down again is
repetitive.

## Considered Options

- [workmux](https://workmux.raine.dev/)
- [claude-squad](https://smtg-ai.github.io/claude-squad/)
- Claude Code's built-in [worktree tools](https://code.claude.com/docs/en/worktrees)
- Shell functions over `git worktree` and tmux

## Decision

**workmux, as a stow package.** It is the thinnest candidate that still answers both
halves: it drives tmux rather than replacing it, and `dashboard` and `sidebar` span every
tmux session, so agents in every repo are visible at once.

The AI tooling layer evolves fast, arguing for as minimal an AI layer as possible
(workmux), built on stable foundational tooling (tmux, git worktrees). Keeps it relatively
easy to change or replace as the AI landscape moves.

claude-squad loses on exactly that. It owns the terminal behind its own TUI. Claude Code's
own `EnterWorktree` isolates sessions to a worktree, but doesn't layer tmux orchestration
or dashobard tracking. Shell functions would mean rebuilding the dashboard, which is the
hard bit.

Key risk: One maintainer wrote nearly every workmux commit and the version is `0.1.x`.
Acceptable because the exit cost is low.

## More Information

`**/.workmux.yaml` is ignored globally, making project config a local overlay by default
and `git add -f` the exception for repos where it is genuinely shared.
