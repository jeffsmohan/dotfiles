---
status: accepted
date: 2026-08-17
---

# Keep keyboard layout in Oryx, and archive it to git

## Context and Problem Statement

My keyboard layout is edited about once every three years and lives in
[Oryx](https://configure.zsa.io), ZSA's web configurator. It works and has kept working,
but the layout is a row in someone else's database. The
[fork of qmk_firmware](https://github.com/jeffsmohan/qmk_firmware) that used to hold it is
text I own and control, and it rotted.

## Considered Options

- Oryx alone
- Oryx as the editor, with its exported source committed to git
- An [external QMK userspace](https://docs.qmk.fm/newbs_external_userspace) repository

## Decision

**Oryx stays authoritative, and its export is committed here under `keyboard/` as dated
snapshots, each one the unmodified "Download source" zip.**

Editing stays where it demonstrably works. Keeping a layout building across QMK's breaking
changes is continuous work.

**The snapshots are about custody, not workflow.** If Oryx disappeared or started
charging, I have a snapshot of my keyboard layouts to bring elsewhere.

**Snapshots accumulate rather than being overwritten**, in directories named for the date
of the revision. Refreshing is manual — scripting the download is more code than a
one-every-few-years process is worth. It lives in this repository rather than one of its
own because it is a handful of files of the same kind this repo already holds.

**A source-controlled build is the real alternative, and it loses on cost.** An external
userspace is the right shape for maintaining QMK keymaps in source: no fork, no upstream
merge, CI publishing firmware on push. But the cost of maintaining the fork is meaningful,
and those costs buy features I don't use (combos, Caps Word, per-key tapping terms and
real macros).
