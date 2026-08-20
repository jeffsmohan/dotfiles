---
status: accepted
date: 2026-08-19
---

# Pin tmux 3.6b with a tap that bootstrap rebuilds

## Context and Problem Statement

tmux 3.7 introduced a redraw regression: with synchronized updates enabled it fails to
mark the scroll region dirty, so scrolled cells are never re-emitted. tmux's own grid
stays correct while the terminal shows stale text, which makes Claude Code's TUI overlap
itself ([tmux#5330](https://github.com/tmux/tmux/issues/5330)). Downgrading is not
something Homebrew offers: homebrew-core carries no versioned tmux formula, and modern
Homebrew refuses to install a formula that is not in a tap.

## Considered Options

- No pin — repair the display with `prefix R` when it corrupts
- Track the formula here; `bootstrap.sh` creates a local tap and installs from it
- Publish the tap as its own GitHub repository

## Decision

Keep `formula/tmux@3.6b.rb` in this repo. `bootstrap.sh` creates the `jeff/local` tap,
copies the formula in, builds it, and links it over homebrew-core's tmux.

**A published tap would be the tidier `brew bundle` story**, and the wrong shape for
something meant to be thrown away: a second repository to own, whose only content is a
file that should stop existing. It also cannot keep the `jeff/local` name, which resolves
to a GitHub account that is not mine.

## More Information

The formula is homebrew-core's tmux at commit `efd484f71aa7`, the last one carrying 3.6b,
with the class renamed to match the filename. The old bottle 404s on ghcr, so it builds
from source in about fifteen seconds.

**Revisit when a tmux release contains commit `d33d5b7`**, the upstream fix — not on any
particular version number. 3.7b and 3.7c both shipped without it while it sat in `master`.
Then unlink the pin, relink core's tmux, untap, and delete this record along with the
formula.

Two things bite when scripting this: `brew tap-new` makes a commit, which fails under
`commit.gpgsign` unless the script overrides it, and the running tmux server survives the
install unreachable, so it has to be killed.
