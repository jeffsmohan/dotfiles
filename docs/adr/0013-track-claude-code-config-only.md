---
status: accepted
date: 2026-08-21
---

# Track Claude Code config only

## Context and Problem Statement

`~/.claude` holds settings that should follow me to every machine _and_ runtime state that
should never leave a given machine, in a single directory that Claude Code writes into
continuously. Session transcripts, caches, and job records are almost all of its bulk.

## Considered Options

- Track the tree with an ignore list
- Track named files

## Decision

**Track only key paths — `settings.json`, `CLAUDE.md`, `statusline-command.sh`, and any
`skills/` I write and use generally.** `--no-folding`, already set for the reasons in ADR
0002, creates real directories and links only leaf files, so tracked config and runtime
state share `~/.claude` without interfering.

**An ignore list loses because it inverts the default.** The state is tens of megabytes of
transcripts that grow every session, so a forgotten entry publishes them from a public
repo.

**Skills are tracked when no installer claims them.** Any skills set up automatically
(`npx skills add` or `workmux setup`) need not be tracked here, though their installation
may end up in `bootstrap.sh` or other automated setup.

## More Information

`settings.json` is strict JSON and cannot use comments. Non-obvious settings choices:

**`permissions.defaultMode: "auto"`** matches how I work. A workmux worktree and its agent
start together and the agent should get straight to work. It has to live in user settings,
since Claude Code ignores an `auto` default coming from project settings.

**Several features are off deliberately** — `disableArtifact`, `disableBundledSkills`,
`disableRemoteControl`, `disableWorkflows`, `autoMemoryEnabled`, `awaySummaryEnabled`, and
`voiceEnabled` as toggles; `AskUserQuestion`, `EnterPlanMode`, and `ExitPlanMode` through
`permissions.deny`. Automatic memory, away summaries, and the question UI are distracting.
The rest are not distracting, just unused, and loading them costs tokens.
