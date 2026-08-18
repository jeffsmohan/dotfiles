---
status: accepted
date: 2026-08-15
---

# Use delta as the git pager

## Context and Problem Statement

Git's default diff renderer is a whole-line diff: a changed line is printed twice, wholly
red and wholly green, and working out what changed inside it is left to the reader. Fine
for a one-word edit, but not as helpful as it could be.

## Considered Options

- Plain git config only — `diff.algorithm`, `diff.colorMoved`, `merge.conflictStyle`
- [delta](https://github.com/dandavison/delta)
- [difftastic](https://github.com/Wilfred/difftastic)
- [diff-so-fancy](https://github.com/so-fancy/diff-so-fancy)

## Decision

delta, installed as `git-delta`, set as `core.pager` and `interactive.diffFilter`, with
`navigate`, `line-numbers`, `hyperlinks`, and `syntax-theme = gruvbox-dark`.

**The built-in baseline was the option to beat.** `diff.algorithm = histogram` and
`merge.conflictStyle = zdiff3` cost nothing and are adopted here on their own merits. What
they cannot do is show a change _within_ a line. Git's answer is `--word-diff`: a
per-invocation flag that highlights whole tokens rather than characters, collapses both
versions into one line, and discards the `+`/`-` structure. Delta highlights the changed
characters while leaving the line intact and syntax-highlighted.

**difftastic was the interesting rejection.** It compares syntax trees rather than lines,
so a commit that only rewraps a signature shows as a few token additions and no deletions
— a genuinely different capability that could coexist with delta. Not useful enough to
adopt today. **diff-so-fancy is delta with less in it**: tidier headers, but no syntax
highlighting, line numbers, or blame improvement.
