We build the setup up one decision at a time. Before anything lands, make sure I
understand the why and the how. Do not run ahead of me. (Ok to parallelize via worktrees,
but always confirm with me before we land work.)

This repo is public. Never commit credentials or API keys — that one is a security
incident. Email addresses, paths, and anything else machine-specific stay out of tracked
files too, but as a portability bug rather than a leak: they are context, not preference,
and would be wrong on the next machine. Both belong in the gitignored local overlay.

Write ADRs for new tools or workflows adopted. Make obvious calls yourself; ask for input
on non-obvious decisions and personal taste. An ADR is `accepted` once you and I agree on
it; it's just to document our thinking.

Keep the README short: purpose, getting started, principles. Anything discoverable from
config files or ADRs is clutter.

`TODOS.md` is a checklist, not a notebook: one line per pending item, no rationale or
results. Finish an item by deleting it, not by writing down what happened. Report findings
to me instead.
