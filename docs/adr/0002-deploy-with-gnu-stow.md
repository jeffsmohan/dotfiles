---
status: accepted
date: 2026-08-15
---

# Deploy dotfiles with GNU Stow

## Context and Problem Statement

The files in this repo are useless where they sit. Every one has a place in `$HOME` that
some program looks for, and something has to get it there on a new machine and after every
edit.

## Considered Options

- GNU Stow
- chezmoi
- A bare git repository with `$HOME` as the work tree
- A hand-rolled symlink script

## Decision

[GNU Stow](https://www.gnu.org/software/stow/), one package per tool. Each top-level
directory is a package, and a path inside it is that file's path relative to `$HOME`:

```
git/.gitconfig                  ->  ~/.gitconfig
fish/.config/fish/config.fish   ->  ~/.config/fish/config.fish
```

Adding a package is adding a directory — there is no manifest to keep in sync. Symlinks
rather than copies means there is no apply step to forget and no way for the two copies to
drift.

Two defaults live in a committed `.stowrc`, so the invocation is plain `stow git`
everywhere:

- `--target=~`, because Stow otherwise targets the _parent_ of the stow directory, which
  is only correct if the repo is cloned into `$HOME`. Naming it makes the clone path
  irrelevant.
- `--no-folding`, which is the most important line here. By default, if a target directory
  does not exist, Stow symlinks the whole directory rather than creating it and linking
  the files inside — so stowing `.config/fish/config.fish` onto a machine with no
  `~/.config` puts the entire `~/.config` tree inside this git repo. Whether that happens
  depends on machine state. `--no-folding` always creates real directories and links leaf
  files.

**chezmoi** is rejected. It solves what Stow structurally cannot — templating files per
machine, and pulling secrets from a password manager at apply time — at the cost of a
source-state translation layer and an explicit apply step. The gitignored `local/` overlay
covers today's need.

**A bare repository** was rejected: it makes every file in `$HOME` an untracked file in a
permanently dirty repo, and puts a stray `git checkout` in a position to overwrite things
that were never dotfiles. **`--dotfiles` mode** was rejected because it adds a name
translation between the repo and disk for no benefit.
