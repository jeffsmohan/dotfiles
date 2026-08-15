---
status: accepted
date: 2026-08-15
---

# Use Ghostty as the terminal emulator

## Context and Problem Statement

iTerm2 has been my terminal for over a decade, and it works. What forced a re-evaluation
was this repo: iTerm2 makes managing settings awkward.

iTerm2 is **GUI-authoritative**. The application owns `com.googlecode.iterm2.plist`,
rewrites it on quit, and version control gets whatever it produces — a large XML blob
where toggling one checkbox shows up as a forty-line reshuffle mixed with window geometry
and ephemeral state. Pointing `PrefsCustomFolder` at a dotfiles directory makes this work,
grudgingly, but the app is still the author and the file is still an export. Every other
terminal worth considering is **file-authoritative**: the file is the source of truth,
nothing writes to it behind your back, and a diff shows the line that changed.

The second thing that made this cheap to reconsider: tmux already does all window and pane
management here. Tabs, splits, session persistence, and detach/reattach are tmux's job.
That deletes most of a terminal emulator's feature surface from the comparison and leaves
a much smaller question — how well does it render text, how does it behave over SSH, and
can it be configured from a file.

## Considered Options

- Stay on iTerm2
- Ghostty
- Alacritty
- kitty
- WezTerm

## Decision

[Ghostty](https://ghostty.org/), configured from `~/.config/ghostty/config.ghostty`.

Plain `key = value`, XDG-respecting, with a `config-file` directive for splitting or
including files and a `?` prefix for optional ones — which is exactly the shape the
machine-local overlay pattern in this repo already assumes.

**Alacritty was the near-miss, and it lost on distribution.** It was the front-runner
going in: the most boring option, the one that duplicates nothing tmux already does, and
the best-behaved over SSH. What ruled it out is that its macOS install path is
disappearing. Homebrew now refuses to ship casks that fail the macOS Gatekeeper check, and
the Alacritty cask carries
`disable! date: "2026-09-01", because: :fails_gatekeeper_check`. There is no formula to
fall back to — Alacritty is cask-only. Upstream is not treating this as a bug to fix:
notarization has been requested since issue #4673, again in #3448, and the issue opened
specifically about this deadline (#8749) sat unanswered, unlabelled, and unassigned. The
maintainers' long-standing position is that they are not interested in Apple's signing
process.

That leaves upstream's documented macOS install, which is `make app` — install a Rust
toolchain, clone the repo, compile. That is a perfectly reasonable thing for a person to
do and a bad thing for a dotfiles repo to depend on. A Brewfile cannot express it, and
`bootstrap.sh` would grow a rustup dependency in order to install a terminal. A terminal
emulator is the first thing a new machine needs and the worst place to put a build step.

**Governance.** Ghostty has been fiscally sponsored by Hack Club, a 501(c)(3), since
December 2025, with names, marks, and IP transferred to the non-profit, finances
transparent to the transaction, and paid contributors. Hashimoto remains the final
decision-maker, but the structure is explicitly designed to outlive him. Alacritty is a
small informal team with no funding structure; kitty is one person who also maintains
calibre. For something this load-bearing, the strongest structure is the right bet.

**SSH terminfo is the one place Ghostty is worse, and it is bounded.** Ghostty sends
`TERM=xterm-ghostty`. Upstream ncurses added an entry in December 2024 but named it
`ghostty`, so even a current Linux box fails over SSH; the `xterm-` prefix is deliberate,
because too much software sniffs `$TERM` for the substring. Alacritty sends `alacritty`,
which has been in ncurses for years and falls back to `xterm-256color` cleanly — genuinely
quieter. Against that, Ghostty's shell integration can install the entry on the remote via
`tic` on first connect and cache it per host, making the problem one-time per box rather
than permanent — but this is **off by default**. `shell-integration-features` ships as
`cursor,no-sudo,title,no-ssh-env,no-ssh-terminfo,path`, so both SSH features have to be
opted into explicitly, and `ghostty +ssh-cache` manages the cache once they are. Until
then, `SetEnv TERM=xterm-256color` in `~/.ssh/config` is the blunt fallback. The fuller
`+ssh` wrapper, which works in scripts and cron and ships its own compiled terminfo, is
not in 1.3.x and lands in 1.4.0.

This is deliberately left at the default for now. SSH to hosts outside this machine is
rare here, and the nearest thing to it — shelling into ECS tasks — goes through
`aws ecs execute-command` and Systems Manager rather than `ssh`, which Ghostty's
integration does not hook at all. Turning the feature on before the failure has been seen
would mean guessing at whether the fix addresses the symptom.

**kitty was rejected on its maintainer's position on multiplexers**, which is not a
personality footnote but something with shipped consequences. Goyal has argued publicly
and repeatedly that multiplexers are an anti-pattern, and the position is in the FAQ.
Concretely: kitty's graphics protocol does not work under tmux, an attempt to coordinate
with the tmux maintainer did not happen, and so the feature simply does not exist for tmux
users. Adopting kitty means adopting a tool whose sole maintainer considers this setup's
core workflow architecturally wrong, and betting that no future feature request lands on
that boundary.

**WezTerm was rejected** despite the most powerful configuration story of the lot — a real
Lua program, able to branch on hostname or environment. Its built-in multiplexer
duplicates tmux rather than complementing it, its stable releases are irregular, and its
maintenance status is unclear enough to be a risk in a tool this central.

**Ligatures and desktop notifications were not significant considerations.** Both are
Ghostty advantages over Alacritty, but neither is functionality I prefer to use.

## Consequences

- Good, because the configuration is a plain text file this repo owns outright. No export
  step, no GUI author, and a diff shows the line that changed.
- Good, because installation stays `brew install --cask ghostty`. The cask passes
  Gatekeeper and auto-updates, so the bootstrap story on a new Mac is one line.
- Good, because Shift+Enter for a newline works in Claude Code with no terminal-side
  configuration at all, where Alacritty needs an explicit binding. This machine's tmux
  config already sets `terminal-features "xterm*:extkeys"`, and `xterm-ghostty` matches
  that pattern where `alacritty` would not have.
- Good, because the project has a governance structure and funding rather than a single
  maintainer, which is the property most likely to matter in five years.
- Bad, because `TERM=xterm-ghostty` is unknown to remote hosts. Expect a garbled session
  on each new box, and note that the terminfo auto-install that fixes it is opt-in rather
  than automatic, so the first encounter will be a surprise rather than a self-healing
  annoyance.
- Bad, because it drops iTerm2's tmux `-CC` control mode, and its triggers and
  coprocesses. None are in use here.
- Neutral on the two features that looked like losses and are not. Secure Keyboard Entry
  exists as `macos-auto-secure-input`, on by default, enabled heuristically at password
  prompts and available manually from the menu — though the detection explicitly does not
  work over SSH. Window state restore exists as `window-save-state`, which is weaker than
  iTerm2's, restoring window layout rather than scrollback contents.
- Bad, because Ghostty ships tabs and splits that duplicate tmux. Nothing forces their
  use, and a config that says nothing about them behaves like a terminal that lacks them,
  but the keybindings exist and can be hit by accident.
- Bad, because Ghostty is young — 1.3.x, roughly six-month release cadence — against
  iTerm2's twenty years. Ghostty 1.3.0 fixed CVE-2026-26982, where control characters in
  pasted or dropped text could execute commands in some shells, which is the kind of bug a
  young terminal still has ahead of it. Install current; do not run a stale cask.

## More Information

Verified against Ghostty 1.3.1 (Homebrew cask, August 2026). 1.4.0 is planned for
September 2026 and brings the `+ssh` wrapper.

Ghostty bundles its terminfo at `/Applications/Ghostty.app/Contents/Resources/terminfo`
and exposes it through `TERMINFO` rather than installing into the system database, so
`infocmp xterm-ghostty` fails in a shell that Ghostty did not start. That is expected and
not a broken install.

Switching cost is low in both directions — a `brew install` and one file — so this is a
decision worth revisiting from experience rather than defending. Revisit if the SSH
terminfo friction proves to be a daily tax rather than a per-host annoyance, in which case
Alacritty built from source becomes worth its bootstrap cost.
