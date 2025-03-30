#!/usr/bin/env sh

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

function logit {
  local logfile="$CFG/.install.log"
  touch $logfile
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

function ensure_dir() {
  if [[ ! -e "$1" ]]; then
    try_to "Create $1" \
      "mkdir -p \"$1\"" \
      "rm -r \"$1\"" || exit 1
  fi
}

function install_brew() {
  if [[ ! $(brew --version 2>&-) ]]; then
    try_to 'Install Homebrew' \
      'yes | /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" > /dev/null' \
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
  if [[ "$2" && "$2" != $(whoami) ]]; then
    return 0
  fi

  if [[ ! "$brew_formulae_list" ]]; then
    brew_formulae_list=$(brew list --formulae)
  fi

  if [[ $(echo "$brew_formulae_list" | grep "^${1#*/*/}$") ]]; then
    infcho "$1 is already installed with brew"
  else
    try_to "Install $1 with Homebrew" \
      "brew install \"$1\"" \
      "brew uninstall \"$1\"" \
      && [[ "$2" ]] && infcho "$2"
  fi
}

function brew_cask_install() {
  if [[ "$2" && "$2" != $(whoami) ]]; then
    return 0
  fi

  if [[ ! "$brew_cask_list" ]]; then
    brew_cask_list=$(brew list --cask)
  fi

  if [[ $(echo "$brew_cask_list" | grep "^${1#*/*/}$") ]]; then
    infcho "$1 is already installed with brew cask"
  else
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
    for filepath in $(all_paths "$CFG/home"); do
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
  for filepath in $(all_paths "$CFG/home"); do
    local cfgpath="$CFG/home/$filepath"
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
    from_path="$CFG/system/sleepwatcher/$filename"
    try_to "Create symlink at $plist_path to $from_path" \
      "ln -s \"$from_path\" \"$plist_path\"" \
      "rm \"$plist_path\""
  fi
}

function install_base16_shell() {
  base16_install_dir="$HOME/.config/base16-shell"
  if [[ -d "$base16_install_dir" ]]; then
    infcho "base16-shell appears to be installed at $base16_install_dir"
  else
    try_to "Install base16-shell" \
      "git clone https://github.com/chriskempson/base16-shell.git $base16_install_dir" \
      "rm -r \"$base16_install_dir\""
  fi
}

function main() {
  health_checks

  local CFG="$HOME/cfg"
  local CONFIG="$HOME/.config"
  local HOMEBIN="$HOME/.bin"
  local LOGGED

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
  brew_install chruby-fish
  brew_install fd
  brew_install flyctl
  brew_install fzf
  brew_install git
  brew_install htop
  brew_install koekeishiya/formulae/skhd
  brew_install koekeishiya/formulae/yabai
  brew_install lua-language-server
  brew_install neovim
  brew_install node "spencer"
  brew_install node@20 "spencerchristiansen"
  brew_install oven-sh/bun/bun
  brew_install pianobar
  brew_install ripgrep
  brew_install ruby-install
  brew_install rustup
  brew_install sleepwatcher
  brew_install wget
  brew_install yarn

  brew_cask_install calibre "spencer"
  brew_cask_install discord "spencer"
  brew_cask_install docker
  brew_cask_install dropbox
  brew_cask_install firefox
  brew_cask_install font-fira-code-nerd-font
  brew_cask_install google-chrome
  brew_cask_install joplin
  brew_cask_install keepassxc "spencer"
  brew_cask_install kitty@nightly
  brew_cask_install mongodb-compass "spencerchristiansen"
  brew_cask_install postgres-unofficial "spencer"
  brew_cask_install slack 'spencerchristiansen'
  brew_cask_install ubersicht
  brew_cask_install visual-studio-code "spencerchristiansen"
  brew_cask_install zoom "spencer"

  backup_existing_config_files
  create_symlinks

  install_sleepwatcher_plist
  install_base16_shell
}

main
