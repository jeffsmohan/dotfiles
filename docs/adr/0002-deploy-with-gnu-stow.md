---
status: accepted
date: 2026-08-15
---

# Deploy dotfiles with GNU Stow

## Context and Problem Statement

The files in this repo are useless where they sit. Every one of them has a place in
`$HOME` that some program looks for — `~/.gitconfig`, `~/.config/fish/config.fish` — and
something has to get it there, on a new machine or after every edit.

The mechanism chosen here is load-bearing: it determines the repo's directory layout, what
"install this on a new machine" means, and how much friction sits between editing a config
and the change taking effect.

## Considered Options

- GNU Stow
- chezmoi
- A bare git repository with `$HOME` as the work tree
- A hand-rolled symlink script
- Copying files by hand

## Decision

[GNU Stow](https://www.gnu.org/software/stow/), one package per tool.

Each top-level directory in this repo is a package, and a path inside a package is that
file's path relative to `$HOME`:

```
git/.gitconfig                  ->  ~/.gitconfig
git/.config/git/ignore          ->  ~/.config/git/ignore
fish/.config/fish/config.fish   ->  ~/.config/fish/config.fish
```

`stow git` creates those symlinks; `stow -D git` removes them. Adding a package is `mkdir`
— there is no manifest to keep in sync, which is the property that makes the repo's layout
self-describing.

Stow won over a hand-rolled script for the obvious reason: it is a small, stable,
thirty-year-old tool that already handles edge cases — conflict detection, dry runs, clean
removal, relative link targets. A script ends up as a worse Stow.

Symlinks rather than copies means editing a file in the repo takes effect immediately, and
editing the deployed file _is_ editing the repo. There is no apply step to forget and no
way for the two copies to drift.

Packages are per tool rather than one package for the whole repo so deployment can be
selective. A Linux box or a Codespace should be able to take `git` and `fish` and ignore
`hammerspoon`. The single-package layout would also have forced a `.stow-local-ignore` to
hide `README.md`, `docs/`, and the lint config — and see below for why that file is worth
avoiding.

Two defaults are committed in a `.stowrc` at the repo root, which Stow reads from the
current directory:

```
--target=~
--no-folding
```

`--target=~` is required because Stow defaults its target to the _parent_ of the stow
directory, which is only correct if the repo is cloned directly into `$HOME`. Naming the
target explicitly makes the clone path irrelevant: this repo should work the same wherever
it is checked out, on any machine. Putting it in a committed `.stowrc` rather than in
every command means the invocation is plain `stow git` everywhere, with nothing to
remember and no path recorded anywhere in the repo.

`--no-folding` disables **tree folding**, and it is the most important line in this repo's
Stow setup. By default, if a target directory does not already exist, Stow does not create
it and link the files inside — it symlinks the whole directory. Stowing a package
containing `.config/fish/config.fish` into a home directory with no `~/.config` produces:

```
~/.config -> <this repo>/fish/.config
```

The entire `~/.config` tree is now inside the git repo, so every unrelated program that
writes there writes into the working tree. Worse, this depends on machine state: the same
command on a machine that already has `~/.config` descends and links individual files
instead. `--no-folding` always creates real directories and links leaf files, so the
result is the same everywhere.

**chezmoi** was the serious alternative and is deferred, not rejected. It solves a problem
Stow structurally cannot: templating files per machine, and pulling secrets from a
password manager at apply time. It costs a source-state translation layer (files are
stored under mangled names) and an explicit `chezmoi apply` between editing and effect.
Machine-local and private values are handled here by the gitignored `local/` overlay
instead — configs source a local file if it exists. Revisit if a second machine needs
values that differ inside a file rather than in a file the overlay can supply, or when
secrets need to be deployed rather than merely kept out.

**A bare repository with `$HOME` as the work tree** was rejected. It removes the symlink
layer entirely, but makes every file in the home directory an untracked file in a
permanently dirty repo, and puts a stray `git checkout` in a position to overwrite things
that were never dotfiles.

**`--dotfiles` mode**, which lets files be named `dot-gitconfig` in the repo and deploys
them as `.gitconfig`, was rejected. Files inside a package directory are not hidden from
`ls` anyway, so it buys nothing and adds a name translation between what is in the repo
and what is on disk.

## Consequences

- Good, because deployment is one small command per tool, with `stow -n -v` to see exactly
  what it would do first.
- Good, because there is no apply step. The deployed file and the tracked file are the
  same file.
- Good, because Stow refuses to overwrite a real file. It reports the conflict, aborts the
  whole package, and exits non-zero, so a botched migration cannot silently destroy an
  existing config.
- Good, because the repo layout _is_ the documentation. A path in a package says where the
  file goes.
- Bad, because everything is a symlink, and that is visible to programs. Anything that
  saves by replacing a file rather than writing through it breaks the link and silently
  stops tracking. Configs owned by GUI apps are a poor fit and may need a different
  approach per app.
- Bad, because Stow cannot vary a file's contents by machine. Anything that differs has to
  be factored out into the `local/` overlay, which every config file has to explicitly opt
  into by sourcing it.
- Bad, because it is another dependency to install before the dotfiles work — including on
  a Linux box or Codespace, where the bootstrap has to install Stow before it can deploy
  anything.
- Bad, because deleting a file from a package leaves its symlink behind in `$HOME` until
  the package is restowed with `-R`. Nothing prompts this.
- Bad, because unstowing leaves the empty directories it created behind.
- Bad, because a `.stow-local-ignore` file _replaces_ Stow's built-in default ignore list
  rather than extending it — the defaults include `.git`, `.gitignore`, `README.*`, and
  `LICENSE.*`. Any package that ever needs one must re-declare those. The package-per-tool
  layout avoids needing one at all, and it should stay that way.

## More Information

Verified against GNU Stow 2.4.1. Migrating an existing config into a package is the
conflict case above: move the original aside first, or use `--adopt`, which moves the
existing file into the package and overwrites the repo's copy. `--adopt` is only safe from
a clean working tree, where `git diff` afterwards shows exactly what it swallowed.
