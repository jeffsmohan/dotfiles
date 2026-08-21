---
name: review
description:
  Ambitious code review for a GitHub PR or local branch diff. Use when the user asks to
  review a PR, review the current branch, or review their changes against main.
---

# Review

Review the code under review with an ambitious eye. Don't just assess _how_ the change was
made — assess whether the change should happen at all, and whether a fundamentally
different approach would be simpler or more maintainable.

## What to review

Parse the argument:

- No argument → diff `HEAD` against `main`
- All digits (e.g. `1234`) → review PR #1234. Pull `gh pr view 1234 --comments` (title,
  description, discussion) and `gh pr diff 1234`
- Contains `..` (e.g. `main..feature`) → use that git diff range
- Anything else → treat as a branch name and diff `main..<branch>`
- Optional second positional arg or `--base <ref>` overrides the base

## If you wrote the code under review

If you authored or substantially edited the code under review **in this conversation**, do
not review it yourself — your context is biased toward the decisions you already made.
Dispatch a subagent (`general-purpose`) and give it:

- The PR title and description (PR mode), or a short PR-description-style summary you
  write yourself (branch mode) — what changed and why, no implementation hints, no chat
  history
- The PR number or base/head refs
- An instruction to read this file (`~/.claude/skills/review/SKILL.md`) and follow it

Then relay the subagent's review verbatim. Don't filter or editorialize.

If this is a fresh session reviewing someone else's PR, review inline.

## How to review

Read every file the diff touches in full — not just the hunks. Read files imported by
changed code when the change's logic depends on them. Don't crawl further unless something
specific demands it.

Before writing the review, privately list every potential concern, then walk through each
one to confirm it holds — check surrounding code, look for existing patterns, consider why
the author might have chosen this approach. Drop concerns that don't survive. Do not
stream half-thoughts or mid-review retractions.

For each surviving finding, apply this test: _"Would I actually open this as a comment if
a colleague's name were on this PR?"_ If no, drop it.

Be ambitious. Beyond line-level issues, ask:

- Should this change happen at all?
- Is there a fundamentally simpler approach?
- Does this duplicate something that already exists in the codebase?
- Does it introduce abstraction the codebase doesn't need yet?

## Output

Print the review to the terminal — never post to GitHub. Always use this structure, in
this order:

## Bigger picture

One concern about whether the change should happen at all, or whether a fundamentally
different approach is warranted — 1-3 sentences. If you have no such concern (the common
case), write exactly **Looks good.** here.

## Findings

A bullet list, one finding per bullet, each ending with `(file:line)`. Put critical
findings first, prefixed `CRITICAL:` (reserve for bugs, security, or behavior-breakers);
minor findings after, unprefixed. If there are none, write "None."

Every finding must be actionable — phrased as a change the author could make. No praise,
and don't narrate what the PR does well, even to justify _not_ raising a concern: a
non-objection is silence, not a bullet. No status updates ("tests pass", "I ran mypy") —
if a check produced a finding, fold it in; if it passed, it's silent. Quality bar, not
volume bar: include every legitimate small point (even a typo), but don't reach for
filler.
