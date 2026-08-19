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
- **tmux** — `~/.config/tmux/tmux.conf` is live and untracked; Ghostty depends on its
  `extended-keys` block
- **workmux** — decide whether any of it belongs here
- **ssh** — track `~/.ssh/config`; drop the `IdentityFile` and `AddKeysToAgent` lines left
  over from `id_ed25519`

## Tooling

- `fish_indent` pre-commit hook, once fish files exist
- Script that automates per-machine setup, rather than the README list of manual steps:
  prompt for `user.email`, guide creating the Secretive key, register it with `gh`, set
  `user.signingkey`
- Codespaces `install.sh` — decide whether it is wanted at all

## Cleanup

- Remove Hammerspoon
- Uninstall iTerm2 once Ghostty has proven itself over a few weeks
- Rip out oh-my-fish, vestigial alongside fisher?
- Delete the empty `fish_variables*` and `fishd.tmp.*` files in `~/.config/fish`
