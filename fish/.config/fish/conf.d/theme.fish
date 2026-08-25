# Syntax highlighting, named rather than hex, so it follows Ghostty's theme.
#
# Change colours by editing this file, not with `fish_config`: the web tool writes its own
# conf.d file and would shadow this one.
#
# fish takes only the 16 names or a literal hex -- no palette indices -- so it cannot read
# the chrome band in slot 16. Where a shade was needed, `--reverse` stands in: it is drawn
# from the current fg/bg, so it inverts correctly on a light theme too.

set -g fish_color_normal brwhite
set -g fish_color_command brgreen
set -g fish_color_keyword brred
set -g fish_color_quote bryellow
set -g fish_color_redirection brcyan
set -g fish_color_end red
set -g fish_color_error brred
set -g fish_color_param brwhite
set -g fish_color_option brmagenta
set -g fish_color_comment brblack --italics
set -g fish_color_operator cyan
set -g fish_color_escape brmagenta
set -g fish_color_autosuggestion brblack
set -g fish_color_valid_path --underline
set -g fish_color_cancel --reverse

# Used by fish's own prompt helpers; starship draws the prompt, so these are near-unused.
set -g fish_color_cwd bryellow
set -g fish_color_cwd_root brred
set -g fish_color_user brgreen
set -g fish_color_host brblue
set -g fish_color_host_remote bryellow
set -g fish_color_status brred

set -g fish_color_selection --bold --reverse
set -g fish_color_search_match --reverse
set -g fish_color_history_current --bold

set -g fish_pager_color_progress brblack
set -g fish_pager_color_prefix brcyan --bold
set -g fish_pager_color_completion brwhite
set -g fish_pager_color_description brblack
set -g fish_pager_color_selected_background --reverse
