# dotfiles

Personal machine configuration, version controlled.

## Getting started

```
git clone git@github.com:jeffsmohan/dotfiles.git
cd dotfiles
brew install stow
pre-commit install     # git hooks are not version controlled; re-run per clone
stow -n -v <package>   # dry run first — it will refuse to clobber existing files
stow <package>
```

## Principles

**Every top-level directory is a [stow](https://www.gnu.org/software/stow/) package**, and
a file's path inside a package is its path relative to `$HOME`. So
`git/.config/git/ignore` deploys to `~/.config/git/ignore`, and the layout of this repo is
the documentation for where things go. Deploy packages one at a time; nothing requires
taking all of them.

**Anything non-obvious gets an ADR.** The files record _what_ is configured and
[`docs/adr/`](docs/adr/) records _why_ — including the options that were rejected, and
what would justify changing course. Start at
[0000](docs/adr/0000-record-architecture-decisions.md). Read the relevant record before
changing something; add one when the reasoning would otherwise be lost.

**This repo is public.** `local/` and `*.local` are gitignored. Credentials, work-specific
settings, and per-machine paths live there and are sourced by tracked files if present —
never committed.

**Formatting has one authority.** Editors, agents, and hand edits all disagree; pre-commit
settles it on the way in.
