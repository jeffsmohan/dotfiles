---
status: accepted
date: 2026-10-07
---

# Run Claude Code's commands in bash, not zsh

## Context and Problem Statement

Claude Code's Bash tool only runs bash or zsh. With fish as the login shell (ADR 0015) it
falls back to `/bin/zsh`, but agents write bash. The divergence costs retries: zsh aborts
on a glob that matches nothing, so `grep --include=*.py` fails, etc.

## Considered Options

- Set `NO_NOMATCH` for agent shells in `~/.zshenv`
- Point `CLAUDE_CODE_SHELL` at Homebrew bash

## Decision

**Set `CLAUDE_CODE_SHELL` to Homebrew bash in `claude/settings-base.json`, and add `bash`
to the Brewfile.**

Running agents in the shell they write for removes the whole class of mismatch, not the
one instance we happened to hit. Homebrew bash rather than `/bin/bash`, because macOS
ships 3.2, which lacks `mapfile`, associative arrays and `globstar` that agents reach for.

`NO_NOMATCH` was the near-miss: one line, no new dependency, and exactly bash's behaviour
for this case. But it patches zsh one option at a time, and the next divergence would be
another round of the same debugging.
