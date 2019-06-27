#!/usr/bin/env bash

function health_checks() {
  if [[ ! $(uname -s) = Darwin ]]; then
    >&2 echo 'This script can only run on macOS'
    exit 1
  fi

  local error=''

  if ! which git >&-; then
    >&2 echo 'Please install git'
    error=true
  fi

  if ! which ruby >&-; then
    >&2 echo 'Please install ruby'
    error=true
  fi

  if [[ "$error" != '' ]]; then
    exit 1
  fi
}

function logit {
  local logfile="$CFG/.install.log"
  if [[ ! $LOGGED ]]; then
    echo "Logging results in $logfile"
    LOGGED=true
  fi
  echo "$(date +"%Y-%m-%d %T") $@" >> $logfile
}

function errcho() {
  logit "[err] $@"
  >&2 echo "$@"
}

function infcho() {
  logit "[info] $@"
  echo "$@"
}

function logcho() {
  logit "[log] $@"
}

function remcho() {
  logit '[Uninstall] - `'"$@"'`'
}

function clone_the_repo() {
  if [[ ! -d $CFG ]]; then
    echo "Cloning config directory to $CFG"
    local error_msg=$(git clone git@github.com:spejamchr/cfg.git "$CFG" 2>&1)
    if [[ $? = 0 ]]; then
      infcho "Cloned config repo to $CFG"
      remcho "rm -rf $CFG"
    else
      errcho "Could not clone config repo to $CFG. Received error:"
      errcho "$error_msg"
      errcho "Run \`git clone git@github.com:spejamchr/cfg.git \"$CFG\"\` to retry."
      exit 1
    fi
  fi
}

function create_dir() {
  if [[ ! -e "$1" ]]; then
    if mkdir "$1"; then
      infcho "Created $1"
      remcho "rm -r $1"
    else
      errcho "Could not create $1. Run \`mkdir \"$1\"\` to retry"
      return 1
    fi
  fi
}

function install_brew() {
  if [[ ! $(which brew) ]]; then
    infcho 'Installing Homebrew'
    logcho 'More info about uninstalling Homebrew here: https://github.com/Homebrew/install'
    yes | /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" > /dev/null
    if [[ $? = 0 ]]; then
      remcho '/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)"'
    else
      errcho 'Failed to install Homebrew. Run `/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" > /dev/null` to retry.'
      exit 1
    fi
  fi
}

function install_command_line_tools() {
  if [[ ! -d '/Library/Developer/CommandLineTools' ]]; then
    infcho 'Installing apple command line tools. You may have to enter your password in a prompt.'
    if xcode-select --install; then
      remcho 'rm -rf /Library/Developer/CommandLineTools'
      logcho 'More info about uninstalling the Command Line Tools here: https://developer.apple.com/library/archive/technotes/tn2339/_index.html#//apple_ref/doc/uid/DTS40014588-CH1-HOW_CAN_I_UNINSTALL_THE_COMMAND_LINE_TOOLS_'
    else
      errcho 'Failed to install Command Line Tools. Run `xcode-select --install` to retry'
      exit 1
    fi
  fi
}

function brew_install() {
  if  [[ ! $(ls /usr/local/Cellar | grep ${1#*/*/}) ]]; then
    infcho "Installing $1"
    if brew install "$1" > /dev/null; then
      remcho "brew uninstall $1"
    else
      errcho "Failed to install $1. Run \`brew install \"$1\"\` to retry"
    fi
  fi
}

function install_kitty() {
  local kitty_path="$HOME/git/other/kitty"
  if [[ ! -d "$kitty_path" ]]; then
    infcho "Installing kitty from source"
    local error_msg=$(git clone git@github.com:kovidgoyal/kitty.git "$kitty_path" 2>&1)
    if [[ $? = 0 ]]; then
      infcho "Cloned kitty repo to $kitty_path"
    else
      errcho "Could not clone kitty repo to $kitty_path. Received error:"
      errcho "$error_msg"
      errcho "Run \`git clone git@github.com:kovidgoyal/kitty.git \"$kitty_path\"\` to retry."
      return 1
    fi
    (
    cd "$kitty_path"
    if make &> /dev/null; then
      remcho "rm -rf $kitty_path"
    else
      errcho "Failed to build kitty. Run \`make\` in $kitty_path to see error, or run \`rm -rf "$kitty_path"\` to remove the kitty repo."
    fi
    )
  fi
}

function install_qutebrowser() {
  if [[ ! $(ls /Applications | grep qutebrowser.app) ]]; then
    infcho "Installing qutebrowser with brew cask"
    if brew cask install qutebrowser; then
      remcho "brew cask uninstall qutebrowser"
    else
      errcho 'Failed to install qutebrowser. Run `brew cask install qutebrowser` to retry.'
    fi
  fi
}

function all_paths() {
  (
    cd $1
    local paths=''
    local prefix="$2"
    for path in *; do
      if [[ ! -e $path ]]; then continue; fi
      if [[ -f "$path" ]]; then
        paths+=" $prefix$path"
      elif [[ -d "$path" ]]; then
        local dir_paths=$(all_paths "$path" "$prefix$path/")
        paths+=" $dir_paths"
      fi
    done
    echo $paths
  )
}

function backup_existing_config_files() {
  if [[ $OVERWRITE = '' ]]; then
    local error=''
    for filepath in $(all_paths "$CFG/home" ''); do
      local homepath="$HOME/.$filepath"
      if [[ -e "$homepath" && ! -L "$homepath" ]]; then
        infcho "Backing up $homepath to $homepath.bak"
        if mv "$homepath" "$homepath.bak"; then
          remcho "mv $homepath.bak $homepath"
        else
          errcho "Failed to back up $homepath. Run \`mv \"$homepath\" \"$homepath.bak\"\` to retry"
          error=true
        fi
      fi
    done
    if [[ "$error" != '' ]]; then
      exit 1
    fi
  fi
}

function create_symlinks() {
  for filepath in $(all_paths "$CFG/home" ''); do
    local cfgpath="$CFG/home/$filepath"
    local homepath="$HOME/.$filepath"
    if [[ -L "$homepath" ]]; then continue; fi
    if [[ -f "$homepath" && ! -L "$homepath" ]]; then
      infcho "Removing $homepath without backup"
      rm "$homepath"
    fi
    infcho "Creating symbolic link at $homepath to $cfgpath"
    if ln -s "$cfgpath" "$homepath"; then
      remcho "rm $homepath"
    else
      errcho "Failed to create symlink. Run \`ln -s \"$cfgpath\" \"$homepath\"\` to retry"
    fi
  done
}

function main() {
  health_checks

  local CFG="$HOME/.dotfiles"
  local LOGGED=''

  clone_the_repo

  if create_dir "$HOME/git"; then
    create_dir "$HOME/git/work"
    create_dir "$HOME/git/fun"
    create_dir "$HOME/git/other"
  fi

  install_brew
  install_command_line_tools

  brew_install chruby
  brew_install koekeishiya/formulae/chunkwm
  brew_install cmake
  brew_install gnupg
  brew_install htop
  brew_install imagemagick
  brew_install libyaml
  brew_install mpv
  brew_install mysql@5.7
  brew_install neovim
  brew_install pianobar
  brew_install pkg-config
  brew_install puma/puma/puma-dev
  brew_install redis
  brew_install ripgrep
  brew_install ruby-install
  brew_install koekeishiya/formulae/skhd
  brew_install yarn
  brew_install zsh
  brew_install zsh-completions

  install_kitty
  install_qutebrowser

  backup_existing_config_files
  create_symlinks
}

main