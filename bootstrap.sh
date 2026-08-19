#!/usr/bin/env bash
#
# Take a freshly cloned copy of this repo to a configured machine.
#
# Safe to re-run, and re-running is how you apply changes after a `git pull`.

set -euo pipefail

readonly homebrew_installer="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"

# Stow reads .stowrc from the current directory, so run from the repo root
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$repo_root"

# === Helper functions ===

say() {
  printf '\n==> %s\n' "$1"
}

die() {
  printf 'bootstrap: %s\n' "$1" >&2
  exit 1
}

# A login shell that has never sourced Homebrew's shellenv does not have brew on
# PATH, so `command -v brew` failing does not mean it is missing.
# Apple Silicon installs in /opt/homebrew; Intel in /usr/local.
load_homebrew() {
  local prefix
  for prefix in /opt/homebrew /usr/local; do
    if [[ -x "$prefix/bin/brew" ]]; then
      eval "$("$prefix/bin/brew" shellenv bash)"
      return 0
    fi
  done
  return 1
}

install_homebrew() {
  local reply
  echo "Homebrew is not installed (required)"
  echo "Installer: $homebrew_installer"
  read -r -p "Install Homebrew now? [y/N] " reply || reply=""
  if ! [[ "$reply" =~ ^[Yy]([Ee][Ss])?$ ]]; then
    die "Homebrew is required. Install it and re-run."
  fi
  /bin/bash -c "$(curl -fsSL "$homebrew_installer")"
}

# === Bootstrap steps ===

say "Homebrew"
if ! command -v brew >/dev/null 2>&1 && ! load_homebrew; then
  install_homebrew
  load_homebrew || die "Homebrew installed, but no brew in /opt/homebrew or /usr/local."
fi
brew --version

say "Dependencies"
brew bundle --file=Brewfile

# Top-level directories are assumed to be stow packages:
# - dot-directories excluded via `*/` glob
# - non-stow directories exclude themselves with `.stow-local-ignore` file
say "Packages"
packages=()
for dir in */; do
  packages+=("${dir%/}")
done
if [[ ${#packages[@]} -eq 0 ]]; then
  die "No stow packages found in $repo_root."
fi

# Invoke stow once over all packages:
# - stow plans every package before touching anything, making the operation atomic
# - a conflict anywhere returns the error instead of leaving a partial install
echo "Stowing: ${packages[*]}"
if ! stow --restow "${packages[@]}"; then
  die "Stow changed nothing. Move the file it named above aside, then re-run."
fi

say "Git hooks"
pre-commit install

say "Done"
echo "Set the values this repo deliberately does not carry — see README.md."
