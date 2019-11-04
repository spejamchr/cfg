#!/usr/bin/env zsh

function upgrade_kitty() {
  echo "-> Upgrading kitty..."
  local kitty_path="$HOME/git/other/kitty"
  if [[ -d "$kitty_path" ]]; then
    (
      cd "$kitty_path"
      git fetch
      local commit_diff=$(git rev-list --count master...master@{upstream})
      if [[ "$commit_diff" == 0 ]]; then
        echo "Already up-to-date"
      else
        git pull
        git log -$commit_diff
        make
      fi
    )
  else
    echo "Kitty is not available at $kitty_path"
  fi
}

function updgrade_zsh_plugins() {
  echo "\n-> Upgrading zsh plugins..."
  source "$HOME/.zshrc"
  if which zplug >&-; then
    zplug check || zplug install

    # I can't find a nice way of determining in a script if the plugins are
    # outdated, so just update them every time.
    zplug update
  else
    echo "zplug is not available"
  fi
}

function upgrade_brew_stuff() {
  echo "\n-> Upgrading brew..."
  if which brew >&-; then
    brew update
    echo "\n-> Upgrading brew packages..."
    [[ $(brew upgrade) ]] || echo "Already up-to-date"
    echo "\n-> Upgrading brew casks..."
    if [[ $(brew cask outdated) ]]; then
      brew cask upgrade
    else
      echo "Already up-to-date"
    fi
  else
    echo "brew is not available"
  fi
}

upgrade_kitty
updgrade_zsh_plugins
upgrade_brew_stuff
