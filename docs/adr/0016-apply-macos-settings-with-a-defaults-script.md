---
status: accepted
date: 2026-08-21
---

# Apply macOS settings with a defaults script

## Context and Problem Statement

I mostly work on Mac. Certain settings make me feel at home. They can't be expressed in
preferences files that get stowed.

## Considered Options

- A shell script calling `defaults`
- [nix-darwin](https://github.com/LnL7/nix-darwin) (`system.defaults`)
- [Ansible](https://docs.ansible.com/) (`community.general.osx_defaults`)
- [mackup](https://github.com/lra/mackup)

## Decision

**Write the settings imperatively, with `defaults`, from a `bootstrap-macos.sh` at the
repo root that `bootstrap.sh` calls.**

Plain `defaults` needs no dependency, is greppable, and fails visibly.

nix-darwin has the better answer — typed, declarative, convergent, reversible — but wants
to absorb Homebrew and stow along with it, which is more than warranted here. Ansible buys
idempotency reporting, also more setup than warranted. mackup is disqualified: it symlinks
entire plists.

A separate script rather than inlining to keep OS-specific details partitioned. It is a
root-level file, not a directory, since top-level directories here are stow packages.
