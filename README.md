# dotfiles

Personal machine configuration, version controlled.

## Getting started

```
git clone https://github.com/jeffsmohan/dotfiles.git
cd dotfiles
./bootstrap.sh
```

Over HTTPS, because SSH needs a key that does not exist yet. Re-run `bootstrap.sh` after a
`git pull` to apply changes.

Then set the values this repo deliberately does not carry. Once per machine:

```
git config --file ~/.config/git/config.local user.email <address>
```

One key per machine handles both jobs GitHub needs: signing commits and authenticating
over SSH. It never leaves the machine, so it has to be made there. In
[Secretive](https://github.com/maxgoedjen/secretive), create a key named `git` with
**Authentication not required when Mac unlocked**. The name becomes the key comment, which
is how the commands below pick it out once Secretive holds more than one key. Run them
from a new shell, where `SSH_AUTH_SOCK` points at the Secretive agent:

```
gh auth login
gh auth refresh -h github.com -s admin:ssh_signing_key -s admin:public_key
ssh-add -L | grep git@secretive > ~/.ssh/id_secretive_git.pub
gh ssh-key add --type signing ~/.ssh/id_secretive_git.pub
gh ssh-key add --type authentication ~/.ssh/id_secretive_git.pub
git config --file ~/.config/git/config.local user.signingkey ~/.ssh/id_secretive_git.pub
```

GitHub keeps signing and authentication keys in separate lists and consults each only for
its own purpose, so the same key is registered twice: once to verify commits, once to push
them.

With a key that can authenticate, the clone can move off HTTPS:

```
git remote set-url origin git@github.com:jeffsmohan/dotfiles.git
```

Do all of this before committing from the machine, not after: unsigned commits are marked
`Unverified` on GitHub.

## Principles

**Every top-level directory is a [stow](https://www.gnu.org/software/stow/) package**, and
a file's path inside a package is its path relative to `$HOME`. So
`git/.config/git/ignore` deploys to `~/.config/git/ignore`, and the layout of this repo is
the documentation for where things go. `bootstrap.sh` deploys all of them;
`stow <package>` deploys one.

**Anything non-obvious gets an ADR.** The files record _what_ is configured and
[`docs/adr/`](docs/adr/) records _why_ — including the options that were rejected and what
would justify revisiting. They are short on purpose; `template.md` carries the budgets.
Start at [0000](docs/adr/0000-record-architecture-decisions.md). Read the relevant record
before changing something; add one when the reasoning would otherwise be lost.

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
