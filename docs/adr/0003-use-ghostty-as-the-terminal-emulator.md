---
status: accepted
date: 2026-08-15
---

# Use Ghostty as the terminal emulator

## Context and Problem Statement

iTerm2 is GUI-authoritative: the app owns `com.googlecode.iterm2.plist`, rewrites it on
quit, and version control gets a large XML blob where toggling one checkbox shows up as a
forty-line reshuffle mixed with window geometry. Every other terminal worth considering is
file-authoritative — the file is the source of truth and a diff shows the line that
changed. tmux already handles all window and pane management here, which deletes most of a
terminal's feature surface from the comparison and leaves a small question: text
rendering, SSH behaviour, and configurability from a file.

## Considered Options

- Stay on iTerm2
- Ghostty
- Alacritty
- kitty

## Decision

[Ghostty](https://ghostty.org/), configured from `~/.config/ghostty/config.ghostty` —
plain `key = value`, XDG-respecting, with an optional-include directive that matches the
machine-local overlay pattern this repo already uses.

**Alacritty was the near-miss, and it lost on distribution.** The most boring option and
the best-behaved over SSH. But its macOS install path is disappearing — Homebrew now
refuses casks that fail the Gatekeeper check, and the Alacritty cask carries
`disable! date: "2026-09-01"`. It is cask-only, upstream has declined notarization for
years as a matter of position, and the documented fallback is `make app`: install a Rust
toolchain, clone, compile.

**Governance was the tiebreak.** Ghostty is fiscally sponsored by a 501(c)(3) with paid
contributors and a structure designed to outlive its founder. Alacritty is a small
informal team with no funding; kitty is one person who also maintains calibre.

**SSH terminfo is where Ghostty is worse.** It sends `TERM=xterm-ghostty`, which no remote
host knows, so expect a garbled session on each new box. Shell integration can install the
entry remotely via `tic` and cache it per host, but this is off by default;
`SetEnv TERM=xterm-256color` in `~/.ssh/config` is the blunt fallback. Left at the default
for now — SSH out of this machine is rare, and shelling into ECS tasks goes through
Systems Manager rather than `ssh`, which the integration does not hook.

**kitty was rejected on its maintainer's position on multiplexers**, which has shipped
consequences: the graphics protocol does not work under tmux and coordination with the
tmux maintainer did not happen.

## More Information

Ghostty exposes its terminfo through `TERMINFO` rather than installing into the system
database, so `infocmp xterm-ghostty` fails in a shell Ghostty did not start. Expected, not
a broken install.
