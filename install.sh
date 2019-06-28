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
  local logfile="$DOT/.install.log"
  if [[ ! -e $logfile ]]; then
    return 1
  fi
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

function git_clone() {
  local url="git@github.com:$1.git"
  local dir="$2"
  if [[ ! -d $dir ]]; then
    infcho "Cloning $url to $dir"
    error_msg=$(git clone "$url" "$dir" 2>&1)
    if [[ $? = 0 ]]; then
      remcho "rm -rf $dir"
    else
      errcho "Could not clone $url to $dir. Received error:"
      errcho "$error_msg"
      errcho "Run \`git clone \"$url\" \"$dir\"\` to retry."
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

function brew_cask_install() {
  if [[ $brew_cask_list = '' ]]; then
    brew_cask_list=$(brew cask list)
  fi

  if [[ ! $(echo $brew_cask_list | grep ${1#*/*/}) ]]; then
    infcho "Installing $1"
    if brew cask install "$1" > /dev/null; then
      remcho "brew cask uninstall $1"
    else
      errcho "Failed to install $1. Run \`brew cask install \"$1\"\` to retry"
    fi
  fi
}

function install_kitty() {
  local kitty_path="$HOME/git/other/kitty"
  if [[ ! -d "$kitty_path" ]]; then
    infcho "Installing kitty from source"
    git_clone kovidgoyal/kitty "$kitty_path"
    (
    cd "$kitty_path"
    if make app &> /dev/null; then
      remcho "rm -rf $kitty_path"
    else
      errcho "Failed to build kitty. Run \`make app\` in $kitty_path to see error, or run \`rm -rf "$kitty_path"\` to remove the kitty repo."
      return 1
    fi
    )
  fi

  local kitty_bin="$HOME/bin/kitty"
  local kitty_launcher="$kitty_path/kitty.app/Contents/MacOS/kitty"
  if [[ ! -L "$kitty_bin" ]]; then
    infcho "Symlinking kitty launcher to $kitty_bin"
    if [[ -e "$kitty_bin" ]]; then
      infcho "Removing $kitty_bin without backup"
    fi
    if ln -s "$kitty_launcher" "$kitty_bin"; then
      remcho "rm $kitty_bin"
    else
      errcho "Failed to symlink kitty launcher. Run \`ln -s \"$kitty_launcher\" \"$kitty_bin\"\` to retry."
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
    for filepath in $(all_paths "$DOT/home" ''); do
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
  for filepath in $(all_paths "$DOT/home" ''); do
    local cfgpath="$DOT/home/$filepath"
    local homepath="$HOME/.$filepath"
    if [[ -L "$homepath" ]]; then continue; fi
    if [[ -f "$homepath" && ! -L "$homepath" ]]; then
      infcho "Removing $homepath without backup"
      rm "$homepath"
    fi
    infcho "Creating symbolic link at $homepath to $cfgpath"
    mkdir -p $(dirname "$homepath")
    if ln -s "$cfgpath" "$homepath"; then
      remcho "rm $homepath"
    else
      errcho "Failed to create symlink. Run \`ln -s \"$cfgpath\" \"$homepath\"\` to retry"
    fi
  done
}

function main() {
  health_checks

  local DOT="$HOME/.dotfiles"
  local CONFIG="$HOME/.config"
  local LOGGED=''

  git_clone spejamchr/cfg "$DOT"

  create_dir "$CONFIG"
  if create_dir "$HOME/git"; then
    create_dir "$HOME/git/work"
    create_dir "$HOME/git/fun"
    create_dir "$HOME/git/other"
  fi
  create_dir "$HOME/bin"

  git_clone romkatv/powerlevel10k "$CONFIG/powerlevel10k"
  git_clone chriskempson/base16-shell "$CONFIG/base16-shell"

  install_brew
  install_command_line_tools

  brew_install chruby
  brew_install koekeishiya/formulae/chunkwm
  brew_install cmake
  brew_install gnupg
  brew_install htop
  brew_install imagemagick
  brew_install librsvg
  brew_install libyaml
  brew_install mpv
  brew_install mysql@5.7
  brew_install neovim
  brew_install optipng
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

  brew_cask_install homebrew/cask-fonts/font-firacode-nerd-font
  brew_cask_install flux
  brew_cask_install gpg-suite-no-mail
  brew_cask_install qutebrowser

  install_kitty

  backup_existing_config_files
  create_symlinks
}

main
