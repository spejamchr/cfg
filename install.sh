#!/usr/bin/env zsh

function health_checks() {
  if [[ ! $(uname -s) = Darwin ]]; then
    >&2 echo 'This script can only run on macOS'
    exit 1
  fi

  local error

  if ! which git >&-; then
    >&2 echo 'Please install git'
    error=true
  fi

  if ! which ruby >&-; then
    >&2 echo 'Please install ruby'
    error=true
  fi

  if [[ "$error" ]]; then
    exit 1
  fi
}

function personal_computer() {
  # How can I detect this more flexibly?
  [[ whoami = 'spencer' ]]
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

function try_to() {
  if [[ "$#" -lt 2 ]]; then
    errcho "Not enough args to \`try_to()\`, expected 2..3 but got $#"
    exit 1
  fi
  local description=$1
  local cmd=$2
  local remove=$3
  infcho "-> $description"
  if msg=$(eval "$cmd" 2>&1); then
    [[ "$remove" ]] && remcho "$remove"
  else
    errcho "Failed!"
    errcho "$msg"
    errcho "Run \`$cmd\` to retry."
    return 1
  fi

}

function git_clone() {
  local url="https://github.com/$1.git"
  local dir="$2"
  if [[ ! -d $dir ]]; then
    try_to "Clone $url to $dir" \
      "git clone \"$url\" \"$dir\"" \
      "rm -rf \"$dir\"" \
      || exit 1
  fi
}

function ensure_dir() {
  if [[ ! -e "$1" ]]; then
    try_to "Create $1" \
      "mkdir -p \"$1\"" \
      "rm -r \"$1\"" || exit 1
  fi
}

function install_brew() {
  if [[ ! $(which brew) ]]; then
    try_to 'Install Homebrew' \
      'yes | /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" > /dev/null' \
      '/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)"' \
      && logcho 'More info about uninstalling Homebrew here: https://github.com/Homebrew/install'
  fi
}

function install_command_line_tools() {
  if [[ ! -d '/Library/Developer/CommandLineTools' ]]; then
    try_to 'Install Apple Command Line Tools. You may have to enter your password in a prompt.' \
      'xcode-select --install' \
      'rm -rf /Library/Developer/CommandLineTools' \
      && logcho 'More info about uninstalling the Command Line Tools here: https://developer.apple.com/library/archive/technotes/tn2339/_index.html#//apple_ref/doc/uid/DTS40014588-CH1-HOW_CAN_I_UNINSTALL_THE_COMMAND_LINE_TOOLS_'
  fi
}

function brew_install() {
  if  [[ ! $(ls /usr/local/Cellar | grep ${1#*/*/}) ]]; then
    try_to "Install $1 with Homebrew" \
      "brew install \"$1\"" \
      "brew uninstall \"$1\"" \
      && [[ "$2" ]] && infcho "$2"
  fi
}

function brew_cask_install() {
  if [[ ! "$brew_cask_list" ]]; then
    brew_cask_list=$(brew list --cask)
  fi

  if [[ ! $(echo "$brew_cask_list" | grep ${1#*/*/}) ]]; then
    try_to "Install $1 with Homebrew Cask" \
      "brew install --cask \"$1\"" \
      "brew uninstall --cask \"$1\""
  fi
}

function backup_or_remove() {
  if [[ -e "$1" ]]; then
    if [[ "$OVERWRITE" ]]; then
      try_to "Remove $1 without backup" \
        "rm -rf \"$1\""
    else
      try_to "Back up $1 to $1.bak" \
        "mv \"$1\" \"$1.bak\"" \
        "mv \"$1.bak\" \"$1\""
    fi
  fi
}

function install_kitty() {
  local kitty_path="$HOME/git/other/kitty"
  if [[ ! -d "$kitty_path" ]]; then
    git_clone kovidgoyal/kitty "$kitty_path"
    try_to 'Build kitty' \
      "( cd \"$kitty_path\" && make )" \
      "rm -rf \"$kitty_path\""
  fi

  local kitty_bin="$HOMEBIN/kitty"
  local kitty_launcher="$kitty_path/kitty/launcher/kitty"
  if [[ ! -L "$kitty_bin" ]]; then
    backup_or_remove "$kitty_bin" || return 1
    try_to "Symlink kitty launcher to $kitty_bin" \
      "ln -s \"$kitty_launcher\" \"$kitty_bin\"" \
      "rm \"$kitty_bin\""
  fi
}

function all_paths() {
  (
    cd $1
    local paths
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
  if [[ ! $OVERWRITE ]]; then
    local error
    for filepath in $(all_paths "$DOT/home"); do
      local homepath="$HOME/.$filepath"
      if [[ -e "$homepath" && ! -L "$homepath" ]]; then
        backup_or_remove "$homepath" || error=true
      fi
    done
    if [[ "$error" ]]; then
      exit 1
    fi
  fi
}

function create_symlinks() {
  for filepath in $(all_paths "$DOT/home"); do
    local cfgpath="$DOT/home/$filepath"
    local homepath="$HOME/.$filepath"
    [[ -L "$homepath" ]] && continue
    if [[ -f "$homepath" && ! -L "$homepath" ]]; then
      backup_or_remove "$homepath" || continue
    fi
    ensure_dir $(dirname "$homepath")
    try_to "Create symlink at $homepath to $cfgpath" \
      "ln -s \"$cfgpath\" \"$homepath\"" \
      "rm \"$homepath\""
  done
}

function install_sleepwatcher_plist() {
  sleepwatcher_dir=$(brew --prefix sleepwatcher)
  ensure_dir "$sleepwatcher_dir"
  filename="de.bernhard-baehr.sleepwatcher-20compatibility-localuser.plist"
  plist_path="$sleepwatcher_dir/$filename"
  if [[ -f "$plist_path" && ! -L "$plist_path" ]]; then
    backup_or_remove "$plist_path" || exit 1
  fi

  if [[ ! -L "$plist_path" ]]; then
    from_path="$DOT/system/sleepwatcher/$filename"
    try_to "Create symlink at $plist_path to $from_path" \
      "ln -s \"$from_path\" \"$plist_path\"" \
      "rm \"$plist_path\""
  fi
}

function main() {
  health_checks

  local DOT="$HOME/.dotfiles"
  local CONFIG="$HOME/.config"
  local HOMEBIN="$HOME/.bin"
  local LOGGED

  git_clone spejamchr/cfg "$DOT"

  ensure_dir "$CONFIG"
  ensure_dir "$HOMEBIN"
  ensure_dir "$HOME/git"
  ensure_dir "$HOME/git/work"
  ensure_dir "$HOME/git/fun"
  ensure_dir "$HOME/git/other"

  install_brew
  install_command_line_tools

  brew_install bat
  brew_install blueutil
  brew_install chruby
  brew_install cmake
  brew_install gnupg
  brew_install htop
  brew_install imagemagick
  brew_install koekeishiya/formulae/skhd 'Post-install configuration required. See `brew info skhd`'
  brew_install koekeishiya/formulae/yabai 'Post-install configuration required. See `brew info yabai`'
  brew_install libyaml
  brew_install mysql@5.7 'Post-install configuration required. See `brew info mysql@5.7`'
  brew_install neovim
  brew_install pianobar
  brew_install pkg-config
  brew_install puma/puma/puma-dev 'Post-install configuration required. See `brew info puma-dev`'
  brew_install rbenv/tap/openssl@1.0
  brew_install redis 'Run `brew services start redis` to start redis'
  brew_install ripgrep
  brew_install ruby-install
  brew_install sleepwatcher 'Run `brew services start sleepwatcher` to start sleepwatcher'
  brew_install yarn
  brew_install zplug 'Run `zplug install` to install zsh plugins'
  brew_install zsh
  brew_install zsh-completions

  brew_cask_install dropbox
  brew_cask_install homebrew/cask-fonts/font-firacode-nerd-font
  brew_cask_install flux
  brew_cask_install gpg-suite-no-mail
  brew_cask_install keepassxc
  brew_cask_install mpv
  brew_cask_install sequel-pro
  brew_cask_install ubersicht

  if personal_computer; then
    brew_cask_install calibre
  fi

  install_kitty

  backup_existing_config_files
  create_symlinks

  install_sleepwatcher_plist

  source "$HOME/.zshrc"
  zplug check || try_to 'Install zsh plugins' 'zplug install'
}

main
