# TODOs

Checklist of work not yet done. One line per item; a second only if the item is
meaningless without it. No rationale, no results, no history — those belong in an ADR or a
commit message. When an item is done, delete it rather than marking it done.

## Decisions owed an ADR

- The local-overlay pattern itself, if it outgrows the README paragraph

## Tooling

- Track `formula/tmux@3.6b.rb` and teach `bootstrap.sh` to build the pinned tmux from it,
  per ADR 0010
- Script that automates per-machine setup, rather than the README list of manual steps:
  prompt for `user.email`, guide creating the Secretive key, register it with `gh`, set
  `user.signingkey`
- Decide whether to own and customise the skills `workmux setup` installs into
  `~/.claude/skills`, per the open question in ADR 0017
- Investigate `delta` display configuration options
- Redesign the tmux status bar and window list against the chosen palette
- Investigate `vim-tmux-navigator` for unified pane/split movement across nvim and tmux

## Neovim

- Tinker with the status line
- Set up linting in nvim, and decide between mypy, pyright, and ruff for Python
  diagnostics
