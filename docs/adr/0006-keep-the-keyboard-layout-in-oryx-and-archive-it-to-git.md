---
status: proposed
date: 2026-08-17
---

# Keep the keyboard layout in Oryx, and archive it to git

## Context and Problem Statement

My keyboard layout has existed since 2016 and is edited about once every three years. It
currently lives in [Oryx](https://configure.zsa.io), ZSA's web configurator, where it has
been since 2020. A [fork of qmk_firmware](https://github.com/jeffsmohan/qmk_firmware) also
existed but is dead.

Both places are unsatisfying for opposite reasons. The fork is text I own and control, but
it rotted. Oryx works and has kept working, but the layout is a row in someone else's
database.

## Considered Options

- A fork of `qmk_firmware`, as now
- An [external QMK userspace](https://docs.qmk.fm/newbs_external_userspace) repository
- Oryx alone
- Oryx as the editor, with its exported source committed to git

## Decision

**Oryx stays authoritative, and its export is committed here under `keyboard/` as dated
snapshots, each one the unmodified "Download source" zip.**

Editing stays where it demonstrably works. Keeping a layout building across QMK's breaking
changes is continuous work.

**The snapshots are about custody, not workflow.** If Oryx disappeared or started
charging, I have a snapshot of my keyboard layouts to bring elsewhere.

**Snapshots accumulate rather than being overwritten**, in directories named for the date
the revision was made.

**Refreshing it is manual, by design.** I considered scripting the download, but it was
more messy code than worth it for a one-every-few-years process.

**It lives in this repository** rather than one of its own: it is a handful of files, it
is the same kind of thing this repo already holds, and the decision record is here anyway.

**A source-controlled build is the real alternative, and it loses on cost against a
capability I do not use.** An external userspace is the right shape for maintaining QMK
keymaps in source: no fork, no upstream merge, CI publishing firmware on push. It also
needs an ARM toolchain whose macOS install requires `sudo`, puts mainline QMK's breaking
changes on my maintenance schedule at roughly my editing cadence — so most edits would
begin by fixing a build — and trades one-click WebUSB flashing for a reset button and a
cable. Those costs buy combos, Caps Word, per-key tapping terms and real macros, none of
which appear anywhere in ten years of this layout. Re-forking `qmk_firmware` is the same
trade, minus the parts of it that are any good.
