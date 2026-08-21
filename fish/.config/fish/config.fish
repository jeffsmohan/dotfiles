# Abbreviations and key bindings are only useful interactively
if status is-interactive
    set -g fish_key_bindings fish_vi_key_bindings

    abbr gad "git add"
    abbr gadd "git add -A"
    abbr gadp "git add -p"
    abbr gam "git commit --amend"
    abbr gama "git commit --amend -a"
    abbr gbr "git branch"
    abbr gbra "git branch -a"
    abbr gbrd "git branch -d"
    abbr gbrD "git branch -D"
    abbr gbrm "git branch -m"
    abbr gci "git commit"
    abbr gcia "git commit -a"
    abbr gco "git checkout"
    abbr gcob "git checkout -b"
    abbr gcp "git cherry-pick"
    abbr gdf "git diff"
    abbr gdfs "git diff --staged"
    abbr gf "git fetch --all --prune"
    abbr glg "git log"
    abbr gm "git merge"
    abbr gmv "git mv"
    abbr gp "git push"
    abbr gpf "git push --force"
    abbr gpl "git pull"
    abbr grb "git rebase"
    abbr grba "git rebase --abort"
    abbr grbc "git rebase --continue"
    abbr grbi "git rebase --interactive"
    abbr grm "git rm"
    abbr grs "git reset"
    abbr grsh "git reset --hard"
    abbr gs "git show"
    abbr gsh "git stash"
    abbr gshd "git stash drop"
    abbr gshl "git stash list"
    abbr gshp "git stash pop"
    abbr gshs "git stash show -p"
    abbr gst "git status"

    abbr awsp "set -gx AWS_PROFILE"
end

# Where pipx and Claude Code install user binaries. Appended rather than prepended, so it
# cannot shadow Homebrew, and skipped silently on a machine where it does not exist.
fish_add_path --global --path --append $HOME/.local/bin

# Machine-local context: work identities, credentials, and paths that exist on this laptop
# only. Untracked, and everything above works without it.
if test -f $__fish_config_dir/config.local.fish
    source $__fish_config_dir/config.local.fish
end
