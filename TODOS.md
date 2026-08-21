# TODOs

Checklist of work not yet done. One line per item; a second only if the item is
meaningless without it. No rationale, no results, no history — those belong in an ADR or a
commit message. When an item is done, delete it rather than marking it done.

## Decisions owed an ADR

- fish as the login shell
- The local-overlay pattern itself, if it outgrows the README paragraph

## Packages to add

- **fish** — scrub secrets (API keys, work emails, internal URLs) into the overlay first
- **ghostty** — decide whether to pin `macos-option-as-alt`, and whether to bind
  `super+e=esc:e` rather than leave Cmd+E emergent
- **workmux** — decide whether any of it belongs here
- **claude** — global settings, `CLAUDE.md`, the statusline script, and the skills I
  wrote; leave the marketplace-installed ones out, and get the absolute path out of
  `statusLine`

## Tooling

- `fish_indent` pre-commit hook, once fish files exist
- Script of `defaults write` calls for key repeat and the Dock, run by `bootstrap.sh`
- Track `formula/tmux@3.6b.rb` and teach `bootstrap.sh` to build the pinned tmux from it,
  per ADR 0010
- Script that automates per-machine setup, rather than the README list of manual steps:
  prompt for `user.email`, guide creating the Secretive key, register it with `gh`, set
  `user.signingkey`

## Cleanup
