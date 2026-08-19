---
status: accepted
date: 2026-08-18
---

# Bootstrap a machine with `bootstrap.sh`

## Context and Problem Statement

Setting up a machine from this repo is a sequence — install Homebrew, `brew bundle`, stow
every package, install the git hooks — and a README checklist is the version of that which
drifts. Applying a `git pull` is the same sequence, minus the judgement about which steps
a given change requires.

## Considered Options

- A `bootstrap.sh` at the repo root
- A `Makefile` with a target per step
- Ansible, or `chezmoi apply`

## Decision

**A single `bootstrap.sh` at the repo root, run with no arguments.** It is how a new
machine is set up and how a pull is applied. It is bash, not fish: fish is something this
repo installs, so it cannot also be something the installer requires. A `Makefile` was
rejected because no step is a file target — every rule would be `.PHONY`, and Make would
contribute nothing but syntax. Ansible and `chezmoi apply` are large dependencies for
problems this repo does not have.

**Stow is invoked once with every package**, because Stow plans the whole operation before
touching the filesystem and a conflict anywhere aborts all of it. The failure mode is a
machine left untouched and a message naming the file, never one half-configured. The verb
is `--restow`, so deleting a file from a package no longer leaves its symlink behind.

**Every top-level directory is a package, and the exceptions declare themselves.** `docs/`
and `keyboard/` each carry a `.stow-local-ignore` matching their whole contents, so
stowing them does nothing.

**Homebrew gets a prompt, not an instruction.** The answer is `curl | bash` of an unpinned
script at a GitHub HEAD — the same command [brew.sh](https://brew.sh) tells you to paste.
The prompt adds no trust the manual path lacked, but it is worth a beat to notice.

## More Information

The script does not install the Xcode Command Line Tools: the Homebrew installer already
does, and the `git clone` that puts this file on disk triggers the dialog anyway, since
`/usr/bin/git` is the `xcode-select` stub.
