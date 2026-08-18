---
status: accepted
date: 2026-08-16
---

# Install this repo's dependencies from a hand-curated Brewfile

## Context and Problem Statement

The tracked config here depends on tools it does not install — git's pager is delta, the
Ghostty config names a font that has to exist first — and `stow` cannot deploy itself. The
mechanism is obvious on a Mac. The real question is **what belongs on the list**, because
a Brewfile can mean two incompatible things: the dependencies of a repo, or an inventory
of a machine.

## Considered Options

- A hand-curated Brewfile, scoped to this repo's dependencies
- `brew bundle dump` — a snapshot of everything installed on the machine
- `brew install` lines inside `bootstrap.sh`

## Decision

A hand-curated `Brewfile` at the repo root holding only core dependencies. Anything in
this repo that would break without a given install must be listed. Broadly useful tools we
want on every machine may be listed too. We stop well short of capturing every
`brew install` on a machine.

**`brew bundle cleanup` is therefore never run.** Cleanup uninstalls everything not
listed, so a file safe to clean against is by definition a complete machine manifest — the
dump model. Choosing curation forecloses cleanup.

Nothing is pinned and no lockfile is kept. Brewfile syntax has no version field, Homebrew
6 no longer generates `Brewfile.lock.json`, and `brew pin` is machine-local and pins to
whatever is currently installed rather than a version you name — so it can freeze a
version but never reproduce one.
