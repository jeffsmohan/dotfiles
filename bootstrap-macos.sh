#!/usr/bin/env bash

# Apply the macOS settings that make a machine feel like mine.

set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  printf 'bootstrap-macos: not macOS\n' >&2
  exit 1
fi

say() {
  printf '\n==> %s\n' "$1"
}

say "Keyboard"
defaults write -g KeyRepeat -int 2
defaults write -g InitialKeyRepeat -int 15
defaults write -g NSAutomaticPeriodSubstitutionEnabled -bool false # "  " != ". "

say "Trackpad"
# Tap to click is stored three times
defaults -currentHost write -g com.apple.mouse.tapBehavior -int 1
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

say "Dock"
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int 42
defaults write com.apple.dock show-recents -bool false
# Corner action 1 is "do nothing", modifier 0 is "no modifier held"
for corner in tl tr bl br; do
  defaults write com.apple.dock "wvous-$corner-corner" -int 1
  defaults write com.apple.dock "wvous-$corner-modifier" -int 0
done

say "Windows"
defaults write -g AppleMiniaturizeOnDoubleClick -bool false
defaults write -g AppleWindowTabbingMode -string always # open docs in tabs by default
defaults write com.apple.WindowManager EnableTilingByEdgeDrag -bool false
defaults write com.apple.WindowManager EnableTopTilingByEdgeDrag -bool false
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false
defaults write com.apple.WindowManager HideDesktop -bool true
defaults write com.apple.WindowManager GloballyEnabled -bool false

say "Sound"
defaults write -g com.apple.sound.uiaudio.enabled -int 0

say "Finder"
defaults write com.apple.finder FXPreferredViewStyle -string Nlsv # finder list view
defaults write com.apple.finder ShowPathbar -bool true
defaults write -g AppleShowAllExtensions -bool true

# None of these three reread their preferences on their own
say "Restarting affected apps"
for app in Dock Finder WindowManager; do
  killall "$app" 2>/dev/null || true
done

say "macOS settings applied"
