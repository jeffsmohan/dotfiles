---
status: accepted
date: 2026-09-06
---

# Merge Claude Code settings in at bootstrap

## Context and Problem Statement

ADR 0013 tracked `~/.claude/settings.json` as a stow package file. However, Claude Code
owns that file and rewrites all of it whenever a setting changes in its UI, including for
changing model or effort level. Stowed, every one of those writes lands in the working
tree of a public repo.

## Considered Options

- Keep stowing `settings.json`
- Stop tracking it
- Deploy it as managed settings, or pass it with `--settings`
- Merge a tracked base into it at bootstrap

## Decision

**Stop stowing `settings.json`. Track `claude/settings-base.json` instead, and have
`bootstrap.sh` merge it into the live file.**

The file divides on whether Claude Code has a UI for a key. The base carries the half it
does not — `hooks`, `statusLine`, `permissions`, the `disable*` and `*Enabled` flags — and
omits everything `/config`, `/model` and `/effort` write, which stays per-machine or
per-session.

Not tracking the file at all would be simpler, of course. But a number of my Claude
settings would be easy to forget to sync or bring along between machines and deserve to be
tracked.

Managed settings outrank every user file and the app never writes them, but their
directory is root-owned, so stow cannot place it; `--settings` would have to be passed on
every launch, which workmux and the IDE extension bypass.
