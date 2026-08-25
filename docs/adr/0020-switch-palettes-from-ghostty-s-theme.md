---
status: accepted
date: 2026-08-24
---

# Switch palettes from Ghostty's theme, except in the editor

## Context and Problem Statement

I used Solarized Dark for years, but it doesn't have the appropriate level of detail to
represent all the UI of Neovim and could use more distinct color options. I want to
trial-run a few palettes.

## Considered Options

- Terminal palette as the single source of truth, everywhere
- Terminal palette for the chrome, a real colourscheme for the editor
- [tinty](https://github.com/tinted-theming/tinty)

## Decision

**Ghostty's `theme` is the palette for tmux, fish, starship, and delta. They name the
sixteen ANSI slots and hold no hex at all, so they follow it with no edit.** For those
four this is more accurate than hardcoding, not less: they render exactly what the
terminal is set to, with no second transcription to drift.

**The editor is deliberately excluded.** Sixteen colours are too few for syntax
highlighting, and the difference is measurable: every base16-derived neovim scheme defines
384 highlight groups from 13 foreground and 11 background colours, where the curated
schemes give 22-61 and 15-59. The gap is worst on backgrounds — float borders, cursorline,
popup menus and diff blocks all collapse into one shade. So neovim takes a real
colorscheme, hand-paired.

Two costs. **The sixteen slots have no shade one step off the background**, which the tmux
status bar and the starship prompt both need. **And there is no orange**, costing starship
two segments. Not worth a slot of its own: Modus has no orange in its palette either, so
it would not be portable anyway.

**tinty lost on the surface that matters most: it does not drive Ghostty.** The project
has no Ghostty template, so Ghostty's config stays stale and its 463 themes stay
unreachable.

## More Information

`minimum-contrast` is gone: it rescues a failing palette silently, which would have made
it, not the theme, the thing under trial.

Comments are italic. Fira Mono ships no italic face, so Ghostty slants the upright one,
and that synthesis is legible enough here.

Ghostty's theme files and the editor plugins occasionally disagree about the same theme;
Everforest Dark Hard needs a `background` override because Ghostty paints it with
Everforest's dim shade where the plugin uses `bg0`. Every pairing is checked to the hex.
