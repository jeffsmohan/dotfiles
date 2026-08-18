---
status: accepted
date: 2026-08-16
---

# Install this repo's dependencies from a hand-curated Brewfile

## Context and Problem Statement

The tracked config in this repo depends on tools it does not install (e.g. delta as the
pager for git), `stow` cannot deploy itself, and the Ghostty config names a font that has
to exist first.

The mechanism is obvious on a Mac. The real question is **what belongs on the list**,
because a Brewfile can mean two incompatible things: the dependencies of a repo, or an
inventory of a machine.

## Considered Options

- A hand-curated Brewfile, scoped to this repo's dependencies
- `brew bundle dump` — a snapshot of everything installed on the machine
- No Brewfile; keep install steps as README prose
- `brew install` lines inside `bootstrap.sh`

## Decision

A hand-curated `Brewfile` at the repo root holding **only core dependencies**.

Every config and setup in this repo that would break without a given install must list it
in the Brewfile. We may also include broadly useful tools that we'd want access to on
every machine. But we'll stop short of trying to capture every brew install on a given
machine.

**`brew bundle cleanup` is never run.** Cleanup uninstalls everything not listed, so a
file safe to clean up against is by definition a complete machine manifest — the dump
model. Choosing curation forecloses cleanup.

**A `Brewfile.local` escape hatch is rejected as unnecessary.** Nothing is being fenced
off: this file only ever installs additively, so the machine's owner keeps layering on
packages with plain `brew install`.

### Two kinds of dependency, one file

There is a real distinction inside the list. Five entries are what a machine needs for the
_deployed_ config to work. `pre-commit` is different in kind: it is the toolchain for
_working in_ this repo, nothing deployed references it, and it is the only entry justified
by a file that is not inside a stow package.

**They still share one file, because on this repo's model they cannot have different
audiences.** Stow deploys by symlink (ADR 0002), so the clone stays on disk forever and
editing a deployed dotfile _is_ editing this working tree. Every machine with these
dotfiles is a machine that commits to this repo; there is no read-only consumer to protect
from a build tool.

### Version pinning

Nothing is pinned and no lockfile is kept — Homebrew 6 no longer generates
`Brewfile.lock.json` at all. Two separate things get conflated here:

- **Brewfile syntax has no version field.** The only way to name a version is a formula
  whose maintainers shipped a versioned variant (`node@22`), and most do not.
- **`brew pin` is real but weak.** It is machine-local, not recorded in the Brewfile, and
  pins to whatever is _currently installed_ rather than a version you name — so it can
  freeze a version but never reproduce one.
