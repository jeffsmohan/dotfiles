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

Then set the values this repo deliberately does not carry. Once per machine, after stowing
`git`:

```
git config --file ~/.config/git/config.local user.email <address>
```

## Principles

**Every top-level directory is a [stow](https://www.gnu.org/software/stow/) package**, and
a file's path inside a package is its path relative to `$HOME`. So
`git/.config/git/ignore` deploys to `~/.config/git/ignore`, and the layout of this repo is
the documentation for where things go. Deploy packages one at a time; nothing requires
taking all of them. The exceptions are [`docs/`](docs/) and [`keyboard/`](keyboard/),
which deploy nothing and are not packages.

**Anything non-obvious gets an ADR.** The files record _what_ is configured and
[`docs/adr/`](docs/adr/) records _why_ — including the options that were rejected, and
what would justify changing course. Start at
[0000](docs/adr/0000-record-architecture-decisions.md). Read the relevant record before
changing something; add one when the reasoning would otherwise be lost.

**Preferences, not context.** These are the settings that should follow me to every
machine, work or personal. Anything that belongs to one employer, one project, or one
laptop — an email address, a credential, a path that only exists here — is layered on
locally on that machine and does not live in this repo.

**This repo is public.** That layering is what keeps it safe to be: tracked files pull in
a machine-local counterpart if one exists and carry on without it if not, so nothing
private ever has to be committed to make the setup work.

**The `Brewfile` installs this repo's dependencies, not the machine's.** It lists only
what tracked config here needs. Whatever else you install with `brew` is untouched.

**Formatting has one authority.** Editors, agents, and hand edits all disagree; pre-commit
settles it on the way in.
