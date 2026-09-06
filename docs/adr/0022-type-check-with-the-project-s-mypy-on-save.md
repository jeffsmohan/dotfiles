---
status: accepted
date: 2026-09-06
---

# Type-check Python with the project's own mypy, on save

## Context and Problem Statement

ADR 0021 stands pyright down wherever a project configures its own type checker. Something
has to run mypy, and it has to be the project's own mypy, since plugins load from the
environment mypy runs in.

## Considered Options

- `pylsp-mypy` as a second language server
- `nvim-lint` driving `dmypy`
- `nvim-lint` driving mypy on save
- Nothing in-editor, leaning on `mypy` run manually in a terminal

## Decision

`nvim-lint`, running the root's `.venv/bin/mypy` on `BufWritePost`, gated on the same
`configures_type_checker` predicate that stood pyright down. The root comes from the
attached pyright client rather than a second root-detection heuristic.

**`pylsp-mypy` cannot be installed anywhere useful.** Cannot coexist peacefully with
projects' mypy installations.

**The daemon buys speed it cannot keep.** Warm `dmypy` answers in 0.18s against 1.5s, but
holds 1.7 GB resident per root, and a monorepo of forty independently-rooted packages
makes that a per-package cost. Worse, its only mechanism for unsaved buffers,
`--shadow-file`, reads the shadow once and then serves stale diagnostics until a flag
change forces a 23s restart.

## More Information

Type checking as you type is slow/tricky at any reasonable scale. Revisit if
[ty](https://github.com/astral-sh/ty) hits a stable release and gets adopted.
