---
status: accepted
date: 2026-08-15
---

# Record configuration decisions as ADRs

## Context and Problem Statement

A dotfiles repo is a pile of settings whose reasoning evaporates. The files record _what_
is configured; nothing records _why_.

## Decision

Keep an ADR per non-obvious decision in `docs/adr/`, copied by hand from `template.md`.

Comments in config files still carry local detail — why _this_ line exists — and should.
ADRs carry the decisions that span files or that rejected a real alternative.

Conventions:

- Filenames are `NNNN-kebab-case-slug.md`.
- Status is a field in the frontmatter. Supersede by setting `status: superseded by 0007`
  in the old record and writing a new one.
- Number `0000` is this record, so the directory explains itself.
- No tooling. `cp template.md 0007-some-decision.md` is the entire workflow.
- Keep them short. `template.md` carries the budgets.
