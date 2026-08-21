# TODOs

Checklist of work not yet done. One line per item; a second only if the item is
meaningless without it. No rationale, no results, no history — those belong in an ADR or a
commit message. When an item is done, delete it rather than marking it done.

## Decisions owed an ADR

- fish as the login shell
- The local-overlay pattern itself, if it outgrows the README paragraph

## Packages to add

- **fish** — scrub secrets (API keys, work emails, internal URLs) into the overlay first
- **workmux** — decide whether any of it belongs here, including the skills it installs
  into `~/.claude/skills`
- **agents** — track the `~/.agents` skill inventory, and prune the ones I no longer use

## Tooling

- Script of `defaults write` calls for key repeat and the Dock, run by `bootstrap.sh`
- Track `formula/tmux@3.6b.rb` and teach `bootstrap.sh` to build the pinned tmux from it,
  per ADR 0010
- Script that automates per-machine setup, rather than the README list of manual steps:
  prompt for `user.email`, guide creating the Secretive key, register it with `gh`, set
  `user.signingkey`
- Add a lock-screen key to the keyboard layout
- Investigate `delta` display configuration options
- Investigate Nerd Font glyphs for more git statuses in the prompt line

## Cleanup

- Remove fisher, once `nvm.fish` is replaced or dropped
- Stale comment in the untracked `~/.config/fish/config.fish` still credits Tide for the
  vi mode indicator
