# dotfiles

Personal machine configuration, version controlled.

## Layout

```
docs/adr/    Architecture Decision Records — why the setup is the way it is
```

## Decisions

Anything non-obvious in this repo should have a corresponding record in
[`docs/adr/`](docs/adr/). Start with
[0000](docs/adr/0000-record-architecture-decisions.md), which explains the practice
and the conventions.

To add one: `cp docs/adr/template.md docs/adr/NNNN-short-slug.md`, then fill it in.

## Machine-local values

`local/` and `*.local` are gitignored. Anything machine-specific or private —
credentials, work-specific settings, per-machine paths — belongs there, never in a
tracked file. This repo is public.
