---
status: accepted
date: 2026-08-20
---

# Manage node versions with fnm

## Context and Problem Statement

Automatic switching of node versions based on repo-specific `.nvmrc` files is a core
capability. I previously had three overlapping managers: Homebrew `node`, Homebrew `nvm`,
and the `nvm.fish` plugin. None was wired into the shell, so node resolved to whatever
Homebrew had installed last. It was a mess.

## Considered Options

- [fnm](https://github.com/Schniz/fnm)
- [nvm.fish](https://github.com/jorgebucaran/nvm.fish) (via
  [fisher](https://github.com/jorgebucaran/fisher))
- Homebrew `node` alone
- [mise](https://mise.jdx.dev/)
- [Volta](https://volta.sh/)

## Decision

**Use fnm, and remove every other node manager.**

fnm is a single Homebrew binary driven by one tracked `conf.d` file, so it stows like
everything else and needs no plugin manager. It switches on `cd` and reads `.nvmrc`,
`.node-version`, and `engines.node`.

Homebrew `node` alone cannot satisfy conflicting pins. nvm.fish would have kept a plugin
manager installed to serve one plugin. Volta pins through a `volta` field in
`package.json`, meaning commits to repos I do not own. mise was the near-miss: it would
manage python, java, php, go, and ruby here too, but that is a much larger bet to consider
another day.

## More Information

`fnm env` costs ~10ms per shell.
