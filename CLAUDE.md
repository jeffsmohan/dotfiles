We build the setup up one decision at a time. Before anything lands, make sure I
understand the why and the how. Do not run ahead of me. (Ok to parallelize via worktrees,
but always confirm with me before we land work.)

This repo is public. No credentials, API keys, email addresses of any kind. Anything
machine-specific or private goes to the gitignored local overlay, never a tracked file.

Write ADRs for new tools or workflows adopted. Make obvious calls yourself; ask for input
on non-obvious decisions and personal taste. An ADR is `accepted` once you and I agree on
it; it's just to document our thinking.

Keep the README short: purpose, getting started, principles. Anything discoverable from
config files or ADRs is clutter.

`TODOS.md` is a checklist, not a notebook: one line per pending item, no rationale or
results. Finish an item by deleting it, not by writing down what happened. Report findings
to me instead.
