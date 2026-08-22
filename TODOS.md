# TODOs

Checklist of work not yet done. One line per item; a second only if the item is
meaningless without it. No rationale, no results, no history — those belong in an ADR or a
commit message. When an item is done, delete it rather than marking it done.

## Decisions owed an ADR

- The local-overlay pattern itself, if it outgrows the README paragraph

## Packages to add

- **workmux** — decide whether any of it belongs here, including the skills it installs
  into `~/.claude/skills`
- **agents** — track the `~/.agents` skill inventory, and prune the ones I no longer use

## Tooling

- Track `formula/tmux@3.6b.rb` and teach `bootstrap.sh` to build the pinned tmux from it,
  per ADR 0010
- Script that automates per-machine setup, rather than the README list of manual steps:
  prompt for `user.email`, guide creating the Secretive key, register it with `gh`, set
  `user.signingkey`
- Investigate `delta` display configuration options
- Evaluate direnv for per-repo environments, replacing the machine-wide credential exports
  in the fish overlay
- Re-evaluate Gruvbox Dark Hard as the palette across Ghostty, starship, and fish
