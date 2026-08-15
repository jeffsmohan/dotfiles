---
status: accepted
date: 2026-08-15
---

# Record configuration decisions as ADRs

## Context and Problem Statement

A dotfiles repo is a pile of settings whose reasoning evaporates. The files record _what_
is configured; nothing records _why_.

## Considered Options

- Architecture Decision Records — one immutable file per decision
- Comments in the config files themselves
- A single running `NOTES.md`
- Nothing; rely on commit messages

## Decision

Keep an ADR per non-obvious decision in `docs/adr/`, using the
[MADR](https://adr.github.io/madr/) format, copied by hand from `template.md`.

Comments in config files still carry local detail — why _this_ line exists — and should.
ADRs carry the decisions that span files or that rejected a real alternative. Commit
messages are searchable but not readable as a set: nobody greps a reflog to learn why the
repo is shaped the way it is.

Conventions:

- Filenames are `NNNN-kebab-case-slug.md`, numbers zero-padded to four digits.
- Status is a field in the frontmatter, not a filesystem operation. Supersede by setting
  `status: superseded by 0007` in the old record and writing a new one. Never delete or
  rewrite an ADR that was accepted — a decision that was reversed is more informative than
  one that vanished.
- Number `0000` is this record, so the directory explains itself to anyone who opens it.
- No tooling. `cp template.md 0003-some-decision.md` is the entire workflow.

## Consequences

- Good, because a decision and its rejected alternatives survive as a unit, which is what
  makes it safe to change the config later.
- Good, because the format is plain files in git — readable on GitHub, in an editor, or
  from a terminal on a machine that has nothing installed yet.
- Bad, because it is manual discipline. Decisions made in a hurry will not get recorded,
  and an ADR directory that is half the story is worse than one that is obviously empty.
- Bad, because there is no index and no cross-reference checking. Superseding is a
  convention that nothing enforces.
- Bad, because writing prose for a decision that turns out to be trivial is wasted effort.
  Not every setting warrants a record; only ones where a future reader would otherwise
  reach for the wrong answer.
