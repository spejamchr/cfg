#!/usr/bin/env sh

function upgrade_yabai() {
  echo "\n-> Upgrading yabai, will need password soon..."
  # Uninstall the old scripting-addition.
  sudo yabai --uninstall-sa

  # stop, upgrade, start yabai
  yabai --uninstall-service
  brew upgrade yabai
  yabai --start-service

  # Install and load the scripting-addition.
  sudo yabai --load-sa
}

function upgrade_brew_stuff() {
  echo "\n-> Upgrading brew..."
  if which brew >&-; then
    brew update
    if brew outdated --formula | grep yabai; then
      upgrade_yabai
    fi
    echo "\n-> Upgrading brew packages..."
    brew upgrade
    echo "\n-> Cleaning up..."
    brew cleanup
  else
    echo "brew is not available"
  fi
}

function upgrade_base16_shell() {
  echo "\n-> Updating base16_shell..."
  base16_install_dir="$HOME/.config/base16-shell"
  if [[ -d "$base16_install_dir" ]]; then
    git -C "$base16_install_dir" pull
  else
    echo "base16-shell is not installed at $base16_install_dir"
  fi
}

upgrade_brew_stuff
upgrade_base16_shell
