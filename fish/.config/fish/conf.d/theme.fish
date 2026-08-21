# Syntax highlighting, in the Gruvbox Dark Hard palette Ghostty and starship already use.
#
# Change colours by editing this file, not with `fish_config`: the web tool writes its own
# conf.d file and would shadow this one.

set -g fish_color_normal ebdbb2
set -g fish_color_command b8bb26
set -g fish_color_keyword fb4934
set -g fish_color_quote fabd2f
set -g fish_color_redirection 8ec07c
set -g fish_color_end fe8019
set -g fish_color_error fb4934
set -g fish_color_param ebdbb2
set -g fish_color_option d3869b
set -g fish_color_comment 928374
set -g fish_color_operator fe8019
set -g fish_color_escape d3869b
set -g fish_color_autosuggestion 665c54
set -g fish_color_valid_path --underline
set -g fish_color_cancel --reverse

# Used by fish's own prompt helpers; starship draws the prompt, so these are near-unused.
set -g fish_color_cwd fabd2f
set -g fish_color_cwd_root fb4934
set -g fish_color_user b8bb26
set -g fish_color_host 83a598
set -g fish_color_host_remote fabd2f
set -g fish_color_status fb4934

set -g fish_color_selection ebdbb2 --bold --background=504945
set -g fish_color_search_match --background=3c3836
set -g fish_color_history_current --bold

set -g fish_pager_color_progress 928374 --background=3c3836
set -g fish_pager_color_prefix 8ec07c --bold
set -g fish_pager_color_completion ebdbb2
set -g fish_pager_color_description 928374
set -g fish_pager_color_selected_background --background=504945
