#!/usr/bin/env zsh

function upgrade_kitty() {
  echo "-> Upgrading kitty..."
  local kitty_path="$HOME/git/other/kitty"
  if [[ -d "$kitty_path" ]]; then
    (
      cd "$kitty_path"
      git fetch
      if [[ $(git rev-list --count master...master@{upstream}) == 0 ]]; then
        echo "Already up-to-date\n"
      else
        git pull
        make
      fi
    )
  else
    echo "Kitty is not available at $kitty_path\n"
  fi
}

function updgrade_zsh_plugins() {
  echo "-> Upgrading zsh plugins..."
  source "$HOME/.zshrc"
  if which zplug >&-; then
    if zplug check; then
      echo "Already up-to-date\n"
    else
      zplug update
    fi
  else
    echo "zplug is not available\n"
  fi
}

function upgrade_brew_stuff() {
  echo "-> Upgrading brew..."
  if which brew >&-; then
    brew update
    echo "\n-> Upgrading brew packages..."
    [[ $(brew upgrade) ]] || echo "Already up-to-date\n"
    echo "-> Upgrading brew casks..."
    if [[ $(brew cask outdated) ]]; then
      brew cask upgrade
    else
      echo "Already up-to-date\n"
    fi
  else
    echo "brew is not available\n"
  fi
}

upgrade_kitty
updgrade_zsh_plugins
upgrade_brew_stuff
