---
status: accepted
date: 2026-08-15
---

# Format and lint with pre-commit, prettier, and taplo

## Context and Problem Statement

This repo is mostly prose and small config files, edited from several directions: an
editor with format-on-save, coding agents rewriting files, and hand edits in a terminal.
Each of those has an opinion about line width, list markers, and emphasis syntax.

Consistency here is not aesthetics. It is (a) readability and (b) preventing tools from
fighting each other.

## Considered Options

- prettier + taplo, run by pre-commit
- dprint
- Editor format-on-save only, no repo-level enforcement
- Nothing

## Decision

Run formatters through [pre-commit](https://pre-commit.com/), configured in
`.pre-commit-config.yaml`:

- **prettier** for Markdown, YAML, and JSON, with `proseWrap: always` and `printWidth: 90`
  in `.prettierrc.json`
- **taplo** for TOML
- **pre-commit-hooks** for whitespace and syntax hygiene: trailing whitespace, final
  newlines, line endings, parseable YAML/TOML, merge-conflict markers
- **typos** for spelling, since this repo is largely prose

`pre-commit run --all-files` locally; the same command runs in GitHub Actions
(`.github/workflows/lint.yml`) on push and pull request. Tool versions are pinned by git
revision in the config, so local and CI always run the same versions.

pre-commit installs each tool in its own managed environment. Nothing is added to `$PATH`
and the repo stays free of `package.json`, `node_modules`, and a lockfile, which matters
for a repo that is otherwise dotfiles.

The runtime under a tool is a separate question from the tool's own version, and pinning
the revision does not settle it. Left alone, pre-commit runs prettier on whatever Node is
already on the machine — the environment is named `node_env-system` and its `node` is a
shell shim around the system binary. That makes the hook only as reliable as an unrelated
Homebrew package: when a `libllhttp` bump left Homebrew's Node unable to start, prettier
could not run at all, while every other hook was fine. It also quietly breaks the promise
above, since CI's Node and the laptop's Node are unrelated.

So prettier pins `language_version` to a Node LTS, which makes pre-commit fetch its own
prebuilt Node instead. Verified by running the hook with no Node on `$PATH`. The cost is a
one-time download per clone and a second pin to keep current — `pre-commit autoupdate`
does not bump it, since it is a runtime version rather than a repo revision.

An `.editorconfig` carries the same baseline — line endings, final newline, indent,
charset, line length — for editors, before any hook runs. It is not enforcement; it is
there so a file is written correctly rather than rewritten a second later, which keeps the
hooks quiet and the diffs small. Prettier also reads it, with `.prettierrc.json` taking
precedence where they overlap, so the two cannot drift into disagreeing about line length.

Enforcement is a real git hook, installed with `pre-commit install`. It runs on staged
files at commit time, so the formatters are the default path rather than something to
remember. The hook lives in `.git/hooks/`, which git does not version, and the generated
file hardcodes an absolute path to the local pre-commit install — so it cannot be
committed and must be re-run on every clone. `bootstrap.sh` should do it once that exists.
Until then it is a documented manual step in the README.

`proseWrap: always` is the deliberate choice over the `preserve` default: preserve leaves
wrapping to whoever typed last, which is exactly the inconsistency this is meant to
remove.

**dprint** was the close alternative — a single binary with official Wasm plugins covering
Markdown, TOML, YAML, and JSON, which would have replaced both prettier and taplo. It was
rejected because it fetches its plugins over the network at runtime, which sits badly
inside pre-commit's sandboxed hook environments, and because prettier's Markdown output is
what every editor and agent already converges on. Fewer fights.

**markdownlint** was considered and rejected: its formatting rules overlap prettier, and
the rules that do not overlap mostly argue with the author about how to write.

## Consequences

- Good, because there is one authority on file formatting. An agent and an editor
  disagreeing now resolves to the same answer instead of an edit war.
- Good, because CI and local runs are the same command at the same pinned versions, so
  "passes locally" means something.
- Good, because adding a format later — shell, Lua — is a few lines in an existing config
  rather than a new decision.
- Bad, because `proseWrap: always` reflows paragraphs. Changing one word near the top of a
  paragraph can rewrite every line below it, and the diff will not show what actually
  changed. This is the accepted price of not hand-managing wrapping.
- Bad, because these hooks fix rather than report. A commit that trips one aborts with the
  fix already written to the working tree, and has to be re-staged and re-run. Surprising
  the first time, and worse for anything scripted that expects `git commit` to either
  succeed or leave the tree untouched.
- Bad, because pinned revisions go stale silently. Bumping them is a manual
  `pre-commit autoupdate`, and nothing prompts it. Prettier's `language_version` is worse:
  `autoupdate` does not touch it, so it goes stale with nothing to bump it but noticing.
- Bad, because pre-commit needs Python and spends time building tool environments on first
  run and after every version bump.
- Bad, because `typos` will occasionally flag a proper noun or a deliberate misspelling,
  and silencing it means adding a config file for it.

Deferred, to be added when the files they check actually exist: `shellcheck` and `shfmt`
for shell scripts, `fish_indent` (ships with fish) for fish config.

[pre-commit.ci](https://pre-commit.ci/) was deferred rather than rejected. It is free for
public repos and would send version-bump pull requests automatically, solving the stale
pins problem above, but it is a third-party GitHub App with write access to the repo.
Revisit if manual `pre-commit autoupdate` proves to be something that never happens.
