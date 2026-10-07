---
name: address-pr-comments
description:
  Work through review comments on a GitHub PR one at a time with the user, in a dedicated
  workmux worktree.
disable-model-invocation: true
---

# Address PR comments

Arguments: `$ARGUMENTS` — `[<pr-number|url>] [notes...]`

No PR given → use the current branch's PR. If the current branch is the PR's
`headRefName`, use **Worker mode**; otherwise **Dispatcher mode**.

## Dispatcher mode

You are a thin dispatcher. Do not read code or comments.

- Prompt: `/address-pr-comments <n>` plus the user's notes, verbatim.
- PR in a different repo → ask for its local path; run from there with
  `--parent-session <repo-basename>`.
- A worktree already has the head branch → if its tmux window is closed,
  `workmux open <handle> -p "<prompt>"`; if open, stop and tell the user.
- Otherwise → `workmux add --pr <n> -p "<prompt>"`.

Then stop.

## Worker mode

### Get bearings

1. Sync with `origin/<head>`: fast-forward if behind and clean; stop and tell the user if
   dirty, ahead, or diverged.
2. Read the PR, the full diff, every changed file in full, and all comments.
3. Use judgment about which comments need discussion; list anything skipped.
4. Overview: reviewer(s), review state, minimap, skipped items, cross-comment links. Then
   go straight into comment 1.

Order: chronological. Grouping closely related comments is fine.

### Each comment

1. Minimap.
2. The comment quoted verbatim, with author and `file:line`.
3. Context, explanation, or code sketch, when it helps.
4. Your recommendation, with the change as a code sketch. Wait for the user.

Once decided, implement, run targeted tests and lint, then move on.

### Minimap

```
✓ 1  Drop LocationSelectionSection
✗ 2  Use update_fields on save
→ 3  Case subject wording
· 4  Test naming
```

`✓` changed · `✗` declined · `–` other · `→` current · `·` pending. Topics ≤5 words. Add
`@author` only with multiple reviewers. Past ~10 comments, collapse completed rows
(`✓✓✗✓ (4 done)`).

### Wrap up

Run the full lint and unit suite. End with the final minimap and deferred follow-ups.

Never post to GitHub, resolve threads, or draft replies — the user writes them.
