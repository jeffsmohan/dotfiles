---
status: accepted
date: 2026-08-15
---

# Use delta as the git pager

## Context and Problem Statement

Git's default diff renderer is a whole-line diff: a changed line is printed twice,
entirely red and entirely green, and working out what actually changed inside it is left
to the reader. That is fine for a one-word edit but not as helpful as it could be.

## Considered Options

- Plain git config only — `diff.algorithm`, `diff.colorMoved`, `merge.conflictStyle`
- [delta](https://github.com/dandavison/delta)
- [diff-so-fancy](https://github.com/so-fancy/diff-so-fancy)
- [difftastic](https://github.com/Wilfred/difftastic)
- [git-split-diffs](https://github.com/banga/git-split-diffs)

## Decision

delta, installed from Homebrew as `git-delta`, wired up in eight settings:

```gitconfig
[core]
	pager = delta

[interactive]
	diffFilter = delta --color-only

[delta]
	navigate = true
	line-numbers = true
	hyperlinks = true
	syntax-theme = gruvbox-dark

[diff]
	algorithm = histogram

[merge]
	conflictStyle = zdiff3
```

**The built-in baseline was the option to beat, and it lost on one specific thing.**
`diff.algorithm = histogram` and `merge.conflictStyle = zdiff3` cost nothing, need no
binary, and are adopted here on their own merits — they would be worth setting even if
delta were rejected. What they cannot do is show a change _within_ a line. Git's answer to
that is `--word-diff`, and it is a poor one: it is a per-invocation flag rather than a
setting, it highlights whole whitespace-delimited tokens rather than characters, it
collapses both versions of the line into one, and it discards the `+`/`-` structure. Delta
highlights the changed characters against a brighter background while leaving the line
intact and syntax-highlighted. That is the difference between reading a diff and decoding
one, and it is the reason a binary earns its place here.

**`git blame` is an even bigger win.** Delta prints the sha, author, and date once per
block rather than once per line, uses relative dates, syntax-highlights the source, and
stripes alternating backgrounds per commit. No combination of git settings produces any of
that.

**Merge conflicts get a third improvement, on the `git diff` side only.** Delta parses
conflict markers out of a combined diff and renders each side under a labelled header
naming the branch, rather than leaving `<<<<<<<` / `=======` / `>>>>>>>` inline. This does
not touch the conflicted file itself — that is git's output and an editor's problem. The
`zdiff3` setting above is what improves the file, by keeping the common ancestor visible.

**`syntax-theme = gruvbox-dark`.** Delta's default is Monokai Extended. One line swaps it
for the Gruvbox palette. It resolves to Gruvbox Dark _Medium_ rather than Hard; the
foreground colors are identical between the two and only the background differs, which
delta does not paint on context lines.

**`diff.colorMoved = zebra` is rejected.** It is the one part of the free built-in
baseline not adopted. Move detection recolors a moved block so it reads as neither an
addition nor a deletion. Not to taste, so not set.

**`--color-only` on `diffFilter` is required, not decoration.** `git add -p` needs the
filter to keep one output line per input line; without the flag delta reflows the diff and
git refuses it with `error: mismatched output from interactive.diffFilter`.

**`diff.renames` is omitted because git already does it.** It has defaulted to true for
years; setting it would be noise.

**Side-by-side is off.** At the working pane width of ~164 columns, it won't always have
the width to make it readable. It remains available per-invocation.

**difftastic was the interesting rejection.** It compares syntax trees rather than lines,
so a commit that only rewraps a function signature shows as a handful of token additions
and no deletions at all, where git shows a bunch of changed lines. That is a genuinely
different capability from delta, and the two can coexist. However, it doesn't seem useful
enough to adopt today.

**diff-so-fancy is delta with less in it.** An 84KB Perl script with no dependencies and
tidier headers than plain git, but no syntax highlighting, no line numbers, no blame
improvement, and no conflict rendering.

**git-split-diffs was rejected on its runtime.** It needs Node to render a diff, for a
smaller feature set than delta.

## Consequences

- Good, because the change inside a line is visible without reading both versions and
  comparing them by eye. This is the daily benefit and the reason for the decision.
- Good, because diffs are syntax highlighted — 198 languages, using bat's definitions.
  Note the default is asymmetric: added and context lines are highlighted, removed lines
  are not, so a `-`/`+` pair renders in two different vocabularies.
- Good, because the workmux dashboard picks this up for free. Its patch mode renders hunks
  through delta when the binary is on `PATH`, falling back to its own coloring when it is
  not. That path does not go through `core.pager`, so it is the install rather than this
  config that buys it — but delta reads `~/.config/git/config` when workmux invokes it, so
  `syntax-theme` still applies.
- Good, because `git blame` becomes substantially more readable at no configuration cost.
- Good, because delta reads `~/.config/git/config` and follows the `[include]` into
  `config.local`, so it fits the XDG layout and the local-overlay pattern without special
  handling. A machine can override any delta setting locally.
- Good, because truecolor reaches it. tmux reports `Tc` with `setrgbf`/`setrgbb`,
  `COLORTERM=truecolor` survives into the pane, and delta detects it. No terminal
  configuration was needed.
- Bad, because `core.pager` names a binary this repo does not yet install, and git
  resolves that name at run time. Until the Brewfile exists, a machine without delta gets
  `fatal: unable to execute pager 'delta'` and exit 128 from `git show`, `git log`, and
  `git diff` — no output at all — and
  `error: mismatched output from interactive.diffFilter` from `git add -p`. A
  `delta || less` guard would degrade to plain output instead, and is deliberately not
  used: this setup is adopted wholesale or not at all, and the Brewfile will install delta
  shortly. Guarding one binary while every other package assumes its dependencies are
  present buys nothing.
- Bad, because it is four transitive Homebrew dependencies — `libgit2`, `llhttp`,
  `libssh2`, `ca-certificates` — rather than the single static Rust binary the description
  implies.
- Bad, because `hyperlinks = true` fills the output stream with OSC 8 escape sequences.
  Ghostty renders them as clickable paths and they are invisible in normal use, but they
  are noise if the output is ever piped or captured.
- Bad, because it is one more thing between git and the screen. Rendering cost is real but
  not perceptible — roughly 40ms on a 1,200-line commit, and delta streams per file, so
  the first screen paints immediately even on `git log -p`.
- Revisit difftastic as a `git dft` alias if a refactor ever makes a line-based diff
  actively useless. Nothing above rules it out; it is the disk cost against expected use.

## More Information

Verified against delta 0.19.2 and git 2.50.1 (Apple Git-155), August 2026, under tmux in
Ghostty.

**The Brewfile must include `git-delta` when it is written.** With no guard on
`core.pager`, that is what closes the gap rather than a nicety. Tracked in `TODOS.md`.

Backing out is a one-line revert of `git/.config/git/config` plus
`brew uninstall git-delta && brew autoremove`. Nothing else depends on it.
