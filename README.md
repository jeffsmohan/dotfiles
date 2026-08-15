# dotfiles

Personal machine configuration, version controlled.

## Layout

```
docs/adr/    Architecture Decision Records — why the setup is the way it is
```

## Decisions

Anything non-obvious in this repo should have a corresponding record in
[`docs/adr/`](docs/adr/). Start with
[0000](docs/adr/0000-record-architecture-decisions.md), which explains the practice and
the conventions.

To add one: `cp docs/adr/template.md docs/adr/NNNN-short-slug.md`, then fill it in.

## Formatting

Formatting and linting run through [pre-commit](https://pre-commit.com/). **After cloning
this repo on a new machine, run:**

```
pre-commit install
```

Git hooks live in `.git/hooks/`, which is not version controlled, and the generated hook
hardcodes an absolute path to the local pre-commit install — so this has to be re-run per
clone. It cannot be committed. (Once `bootstrap.sh` exists, it should do this for you.)

```
pre-commit run --all-files   # format and lint everything, on demand
pre-commit autoupdate        # bump pinned tool versions
```

The hook checks staged files only. Most of these tools fix rather than report: when one
rewrites a file, the commit aborts with the fix already applied to your working tree.
Re-`git add` and commit again. `pre-commit run --all-files` is what CI runs.

See [0001](docs/adr/0001-format-and-lint-with-pre-commit.md) for the tools and why.

## Machine-local values

`local/` and `*.local` are gitignored. Anything machine-specific or private — credentials,
work-specific settings, per-machine paths — belongs there, never in a tracked file. This
repo is public.
