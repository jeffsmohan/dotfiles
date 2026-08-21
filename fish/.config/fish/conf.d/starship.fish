# Starship draws the prompt, reading ~/.config/starship.toml from the starship package.

if status is-interactive
    if command -q starship
        starship init fish | source
    end
end
