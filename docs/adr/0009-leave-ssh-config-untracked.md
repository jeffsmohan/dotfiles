---
status: proposed
date: 2026-08-19
---

# Leave ~/.ssh/config untracked

## Context and Problem Statement

Every other live config in `$HOME` is tracked here or queued to be, so the absence of an
`ssh` package reads as an oversight. It is not. `~/.ssh/config` is a file that installed
tools write to as a matter of course — colima, Docker, 1Password all append to it.

## Considered Options

- Track it, machine-specific hosts in `~/.ssh/config.local`
- Leave it untracked

## Decision

**Leave it untracked, and own no part of it.**

Nothing in the file should follow me to the next machine. Tracking it would put the repo
and every tool that appends to `~/.ssh/config` in contention over one file: colima's first
`start` writes an absolute path into a public repo, and the next `--restow` reverts it.
Suppressing that takes a colima-specific flag, which is one employer's setup landing in a
repo meant to outlive it.

## More Information

Revisit when a genuine ssh _preference_ appears. The shape then is the inverse of the
rejected option: track `ssh/.ssh/config.d/*.conf` and have the machine's untracked
`~/.ssh/config` include it last.
