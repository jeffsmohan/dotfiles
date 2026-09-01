---
status: accepted
date: 2026-09-01
---

# Use Kanagawa Wave theme

## Context and Problem Statement

I ran Solarized Dark for years, but it doesn't have the level of detail to represent all
Neovim's UI. It seemed worth re-evaluating my palette.

## Considered Options

- Selenized Dark
- Kanagawa Wave
- iTerm2 Solarized Dark
- Everforest Dark Hard
- Modus Vivendi
- Modus Operandi

## Decision

**[Kanagawa Wave](https://github.com/rebelot/kanagawa.nvim), by a clear margin.** Each
theme got a run of real work, scored at the end of its run.

| Theme                 | Run       | Score |
| --------------------- | --------- | ----- |
| **Kanagawa Wave**     | ~2 days   | **8** |
| Selenized Dark        | ~1.5 days | 6     |
| iTerm2 Solarized Dark | ~2 days   | 6     |
| Everforest Dark Hard  | ~1 day    | 4     |
| Modus Vivendi         | <1 day    | 3     |
| Modus Operandi        | ~1 hour   | 1     |

High-level takeaways:

- Light themes: continue to feel wrong and be harder to work in for me
- Contrast vs background: don't need maximal contrast (WCAG AAA), which tends to feel
  overly harsh to me
- Separation between accent colors: this felt important; syntax colors too close together
  made code harder to read.

**`minimum-contrast` is gone**: it rescues a failing palette silently, which would have
made it, not the theme, the thing under trial. Worth keeping off.
