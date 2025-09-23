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

upgrade_brew_stuff

bun add --global prettier-plugin-organize-imports
