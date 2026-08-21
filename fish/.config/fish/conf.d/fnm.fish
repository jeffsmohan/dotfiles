# fnm owns node. It puts a shim directory on PATH pointing at whichever version the
# current directory asks for, so node is per-project rather than machine-wide.

if command -q fnm
    if status is-interactive
        fnm env --use-on-cd --version-file-strategy recursive --shell fish | source
    else
        fnm env --version-file-strategy recursive --shell fish | source
    end
end
