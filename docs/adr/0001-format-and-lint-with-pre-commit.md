---
status: accepted
date: 2026-08-15
---

# Format and lint with pre-commit, prettier, and taplo

## Context and Problem Statement

This repo is mostly prose and small config files, edited from an editor with
format-on-save, by coding agents, and by hand in a terminal. Each has an opinion about
line width, list markers, and emphasis syntax. Consistency here is readability, and it
keeps those three from fighting each other.

## Considered Options

- prettier + taplo, run by pre-commit
- dprint
- Editor format-on-save only, no repo-level enforcement

## Decision

[pre-commit](https://pre-commit.com/), configured in `.pre-commit-config.yaml`: prettier
for Markdown/YAML/JSON, taplo for TOML, `pre-commit-hooks` for whitespace and syntax
hygiene, and `typos` for spelling. The same `pre-commit run --all-files` runs in GitHub
Actions. Tool versions are pinned by git revision, so local and CI match.

pre-commit installs each tool in its own environment, so nothing lands on `$PATH` and the
repo stays free of `package.json` and `node_modules`.

`.editorconfig` carries the same baseline for editors, so files are written correctly
rather than rewritten a second later. Prettier reads it too, with `.prettierrc.json`
taking precedence, so the two cannot disagree about line length.

**dprint** was the close alternative: one binary covering all four formats, rejected
because it fetches plugins over the network at runtime, which sits badly inside
pre-commit's sandboxed environments. **markdownlint** was rejected because its rules
either overlap prettier or argue with the author about how to write.
