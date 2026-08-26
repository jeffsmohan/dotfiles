# Standard environment variables that no single tool owns
set -gx EDITOR nvim
set -gx VISUAL $EDITOR
set -gx LANG en_US.UTF-8

# less is already what most tools fall back to, plus setting flags:
# - F: print and exit when the output fits on one screen, rather than paging it
# - i: search case-insensitively unless the pattern itself has a capital
# - R: pass color escapes through instead of rendering them literally
set -gx PAGER less
set -gx LESS FiR

# Keep less from leaving a search history in ~/.lesshst.
set -gx LESSHISTFILE -

# ripgrep reads no config unless this names one.
set -gx RIPGREP_CONFIG_PATH $HOME/.config/ripgrep/ripgreprc
