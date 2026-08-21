# Put Homebrew on PATH before anything else in conf.d runs.
#
# This lives here rather than in config.fish because conf.d loads first, and the files in
# it test for brew-installed commands with `command -q`. Without Homebrew already on PATH
# those tests fail and the files silently do nothing: no fnm means no node, and no
# starship means fish's default prompt.
#
# The leading underscore ensures the ordering. fish loads conf.d in a plain byte sort
# of the filenames.

# `brew shellenv` guesses the shell from its parent process and guesses wrong here,
# emitting bash syntax that fish can't parse, so ask for fish output explicitly. Not
# interactive-guarded: a non-interactive fish needs these paths just as much.
if test -x /opt/homebrew/bin/brew
    eval (/opt/homebrew/bin/brew shellenv fish)
end
