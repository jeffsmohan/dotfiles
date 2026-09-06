---
status: accepted
date: 2026-09-06
---

# Format on save only where project proactively defines formatting

## Context and Problem Statement

Format-on-save is applied to every filetype conform knows. In repos where some filetypes
have no enforced formatting, this can result in different devs thrashing on
format-on-save.

## Considered Options

- Format everything on save, as before
- Trim `formatters_by_ft` to the filetypes wanted everywhere
- Require a discoverable formatter config before formatting on save

## Decision

Require a discoverable config before formatting on save, for the filetypes where the
formatter has taste of its own: markdown, YAML, JSON and JSONC (prettier), TOML (taplo)
and Lua (StyLua). Everything else formats unconditionally.

The test is whether two people's editors would agree. Usually a config settles it, which
is why Python and web files come out clean in repos that never considered this editor. Two
formatters need no config to agree: `fish_indent` has neither a config nor a rival, and
ruff's defaults are black's. The gated ones are what is left, where the tool picks a side
by default: taplo consults no shared convention, not even `.editorconfig`, and StyLua
silently indents with tabs.

Formatting everything was the status quo and is what forced the decision. Trimming
`formatters_by_ft` is fewer moving parts, but it is a global answer to a per-repo
question: this repo would lose markdown and YAML formatting on save to spare unrelated
repos, and get it back from a pre-commit hook after the fact.
