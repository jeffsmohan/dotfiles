---
name: create-pr
description:
  Push the branch and open a GitHub PR in the browser. Use whenever the user asks for a
  PR, even in passing ("ship it as a PR").
---

# Create PR

## 1. Working tree

Uncommitted changes → stop and ask the user how to handle them. Do not commit on your own.

## 2. Branch name

The convention, if any, lives in this clone's pre-push hook. Read
`$(git rev-parse --git-common-dir)/hooks/pre-push` (or `core.hooksPath`, if set) and every
script it calls. No hook, or no naming rule in it → keep the current name.

Names are often picked before the work, so a passing name can still be wrong. If the rule
encodes a type (`feat`, `fix`, `exp`, …), reassess it against the finished diff: `exp`
that shipped a fix is `fix`.

If the name fails the rule or the type is wrong, pick a conforming name from the change
itself and rename without asking:

- Not yet pushed → `git branch -m <new>`, or `workmux rename <handle> -b <new>` if this is
  a workmux worktree.
- Already on the remote → ask first; renaming means deleting the remote branch.

On the default branch → create a conforming branch for the commits instead.

## 3. Title and body

- Find the PR template: `.github/PULL_REQUEST_TEMPLATE.md`,
  `.github/pull_request_template.md`, `PULL_REQUEST_TEMPLATE.md`, `docs/`, or
  `.github/PULL_REQUEST_TEMPLATE/`. Fill in its sections from the diff against the base
  branch; keep its headings and checkboxes.
- Match the title style of the repo's recent PRs (`gh pr list --state merged --limit 10`).
- If the change resolves a GitHub issue (named in conversation, branch, or commits), add
  `Resolves #<n>`. Confirm the issue exists with `gh issue view <n>` first; a number in a
  branch name may not be an issue.
- Write the body to a temp file with the Write tool, not a heredoc.

## 4. Push and open

Run each as its own simple Bash command: no `&&`, `cd`, pipes, or `$(...)`. The sandbox
only exempts `gh` and `git push` when the command is just that.

```bash
git push -u origin HEAD
gh pr create --web --title "<title>" --body-file <tmpfile>
```

Always pass `--web` so the user reviews the PR in the browser before it exists. Drop it
only if the user explicitly asks to create the PR directly.

A PR already exists for the branch → `gh pr view --web` instead, and say so.
