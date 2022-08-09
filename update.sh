#!/usr/bin/env zsh

if [[ $(arch) = 'i386' ]]; then
  HOMEBREW_PREFIX="/usr/local"
else
  HOMEBREW_PREFIX="/opt/homebrew"
fi

function upgrade_kitty() {
  echo "-> Upgrading kitty..."
  local kitty_path="/Applications/kitty.app"
  if [[ -d "$kitty_path" ]]; then
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin installer=nightly launch=n
  else
    echo "Kitty is not available at $kitty_path"
  fi
}

function upgrade_yabai() {
  echo "\n-> Upgrading yabai, will need password soon..."
  # stop, upgrade, start yabai
  brew services stop yabai
  brew upgrade yabai
  brew services start yabai

  # reinstall the scripting addition
  sudo yabai --uninstall-sa
  sudo yabai --install-sa

  # load the scripting addition
  killall Dock
}

function upgrade_brew_stuff() {
  echo "\n-> Upgrading brew..."
  if which brew >&-; then
    brew update
    if brew outdated --formula | grep yabai; then
      upgrade_yabai
    fi
    echo "\n-> Upgrading brew packages..."
    if [[ $(brew outdated --formula) ]]; then
      brew upgrade --formula
    else
      echo "Already up-to-date"
    fi
    echo "\n-> Upgrading brew casks..."
    if [[ $(brew outdated --cask) ]]; then
      brew upgrade --cask
    else
      echo "Already up-to-date"
    fi
  else
    echo "brew is not available"
  fi
}

upgrade_kitty
upgrade_brew_stuff
