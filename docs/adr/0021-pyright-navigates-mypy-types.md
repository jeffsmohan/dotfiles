---
status: accepted
date: 2026-09-06
---

# Pyright as fallback for type-checking

## Context and Problem Statement

Python's type checkers are not interchangeable. Much of the ecosystem — Django, pydantic,
SQLAlchemy — types itself through mypy plugins, which pyright cannot load, so in a project
built on them pyright reports useless errors.

## Considered Options

- Pyright `typeCheckingMode = "basic"` everywhere
- Pyright `typeCheckingMode = "off"` everywhere
- Per-project `pyrightconfig.json`
- Pyright off only where the project configures a checker

## Decision

Detect, in `on_init`, whether the project root configures a type checker of its own — mypy
or ty, by config file or `pyproject.toml` section — and set `typeCheckingMode = "off"`
when it does. Where a project has an answer, pyright defers to it and keeps only
navigation, completion, hover, and rename. Where it has none, pyright checks as it always
did.

**Off everywhere loses type-checking on non-mypy projects.** On a plain file it drops
wrong argument counts, argument types, assignments, and attribute access.

**`basic` is not a middle ground.** It relaxes pyright's default `standard` a rung, but it
still reports spurious warnings in mypy-checked codebases.

**`pyrightconfig.json` is the wrong direction.** This would require each repo to adopt a
config file for a tool it doesn't use.

## More Information

Type diagnostics in checker-configured projects are left to a separate decision about
running mypy from the editor; until then those projects have ruff lint only.
