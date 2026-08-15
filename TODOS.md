# TODOs

Scratch list of deferred work. Not meant to be long-lived — items graduate into ADRs and
packages, or get dropped.

## Decisions owed an ADR

- Commit signing: GPG vs SSH signing, and how private keys reach a new machine
- `bootstrap.sh`: what it does, and how much it is allowed to assume
- Brewfile: curated by hand vs `brew bundle dump`, pinned vs not
- fish as the login shell
- QMK firmware in its own repo
- The local-overlay pattern itself, if it outgrows the README paragraph

## Packages to add

- **fish** — scrub secrets (API keys, work emails, internal URLs) into the overlay first;
  consider rotating them
- **ghostty** — nothing to migrate, written from scratch (ADR 0003). `macos-option-as-alt`
  is deliberately left unpinned; its default is true only because the layout is U.S.
- **tmux** — `~/.config/tmux/tmux.conf` is live and untracked, and the Ghostty setup now
  depends on its `extended-keys` block
- **workmux** — driven by the tmux bindings above; `.workmux.yaml` is already in the
  global gitignore. Decide whether any of it belongs here. Note that Cmd+E reaching the
  dashboard is emergent, not configured: tmux's `extended-keys` makes Ghostty forward
  Cmd+E as `ESC[101;9u`, which tmux decodes as `M-e`. Bind `super+e=esc:e` in Ghostty to
  make it explicit

## Tooling

- Brewfile. Known dependencies so far: `stow`, `pre-commit`, `git-lfs`, `gpg`, `tmux`,
  `--cask ghostty`
- Nerd Fonts. `font-fira-mono-nerd-font` and `font-hack-nerd-font` are already installed
  as casks; decide whether both are wanted, then pin them in the Brewfile. The Ghostty
  config names a font that a fresh machine will not have, so this is a real bootstrap
  dependency, not a nicety
- `shellcheck`, `shfmt`, `fish_indent` pre-commit hooks, once shell files exist
- gitleaks scan over full history — this repo is already public
- Codespaces `install.sh` — opt-in, so decide whether it is wanted at all
- Investigate if https://github.com/dandavison/delta (or similar) is worth using

## Cleanup

- Remove Hammerspoon — not wanted, and `~/.hammerspoon/init.lua` is empty anyway
- Uninstall iTerm2 once Ghostty has proven itself over a few weeks
- oh-my-fish is vestigial alongside fisher — rip out?
- ~21 empty `fish_variables*` and ~5 `fishd.tmp.*` files in `~/.config/fish`
- `~/.config/git/config.local` is mode 644; decide whether that matters
