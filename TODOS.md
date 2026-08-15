# TODOs

Checklist of work not yet done. One line per item; a second only if the item is
meaningless without it. No rationale, no results, no history — those belong in an ADR or a
commit message. When an item is done, delete it rather than marking it done.

## Decisions owed an ADR

- Commit signing: GPG vs SSH signing, and how private keys reach a new machine
- `bootstrap.sh`: what it does, and how much it is allowed to assume
- Brewfile: curated by hand vs `brew bundle dump`, pinned vs not
- fish as the login shell
- QMK firmware in its own repo
- The local-overlay pattern itself, if it outgrows the README paragraph

## Packages to add

- **fish** — scrub secrets (API keys, work emails, internal URLs) into the overlay first
- **ghostty** — decide whether to pin `macos-option-as-alt`, and whether to bind
  `super+e=esc:e` rather than leave Cmd+E emergent
- **tmux** — `~/.config/tmux/tmux.conf` is live and untracked; Ghostty depends on its
  `extended-keys` block
- **workmux** — decide whether any of it belongs here

## Tooling

- Brewfile — so far `stow`, `pre-commit`, `git-lfs`, `gpg`, `tmux`, `--cask ghostty`
- Nerd Fonts — decide between `font-fira-mono-nerd-font` and `font-hack-nerd-font`, then
  pin in the Brewfile; the Ghostty config depends on one
- `shellcheck`, `shfmt`, `fish_indent` pre-commit hooks, once shell files exist
- Codespaces `install.sh` — decide whether it is wanted at all
- Investigate if https://github.com/dandavison/delta (or similar) is worth using

## Cleanup

- Remove Hammerspoon
- Uninstall iTerm2 once Ghostty has proven itself over a few weeks
- Rip out oh-my-fish, vestigial alongside fisher?
- Delete the empty `fish_variables*` and `fishd.tmp.*` files in `~/.config/fish`
- `~/.config/git/config.local` is mode 644; decide whether that matters
