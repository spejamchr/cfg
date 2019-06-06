export XDG_CONFIG_HOME="$HOME/.config"

# Base16 Shell
BASE16_SHELL="$HOME/.config/base16-shell/"
[ -n "$PS1" ] && \
    [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
        eval "$("$BASE16_SHELL/profile_helper.sh")"

export MANPATH="/usr/local/man:$MANPATH"

# Let dots know I'm using it
export USES_DOTS=true

# Set the locale
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

export PATH="$PATH:`yarn global bin`" # Yarn setup (https://yarnpkg.com/en/docs/install#mac-tab)
export PATH="$HOME/.cargo/bin:$PATH" # Rust stuff
export PATH="/usr/local/opt/mysql@5.7/bin:$PATH" # Use the old mysql version
export PATH="$HOME/.local/bin:$PATH" # Haskell Stuff
export PATH="$PATH:$HOME/code/scripts" # My own scripts

export CLICOLOR=1

# Use NeoVim
export VISUAL=nvim
export EDITOR="$VISUAL"

# More History
export HISTSIZE=5000

source /usr/local/opt/chruby/share/chruby/chruby.sh
source /usr/local/opt/chruby/share/chruby/auto.sh
chruby 2.6.2

# Edit this file more easily
alias ep="$EDITOR ~/.profile; source ~/.profile; echo \".profile edited and sourced\""

alias qute='open /Applications/qutebrowser.app/ --args'
alias start_resque="bundle exec rake environment resque:work QUEUE='*'"
alias sync_test="rails db:test:prepare"

alias config="/usr/bin/git --git-dir=$HOME/.cfg --work-tree=$HOME"
function git_or_config() {
  if [[ "$(pwd)" == $HOME ]]; then
    config $@
  else
    git $@
  fi
}
alias git='git_or_config'

# It's nicer to open a dir for editing when it's also the cwd
function edit() {
  (cd $1; $EDITOR .)
}

# This just simplifies things below
function rails_command() {
  (
    cd $1
    shift
    [[ -f .ruby-version ]] && chruby `cat .ruby-version`
    eval $@
  )
}

function rails_log() { rails_command $1 tail -f log/development.log; }
function rails_console() { rails_command $1 rails console; }
function rails_resque() { rails_command $1 start_resque; }

function in_new_kitty_window() {
  if [[ "$TERM" != "xterm-kitty" ]]; then
    echo "Only available in Kitty"
    return 1
  fi

  title="$1"
  shift

  kitty @ new-window --new-tab --tab-title "$title" --title "$title" --keep-focus

  [[ "$@" ]] && kitty @ send-text --match title:"$title" "$@"
}

alias slack="open /Applications/Slack.app/"

################################################################################
export TT=~/git/work/TroopTrack

function tt_terminal {
  cd $TT
  in_new_kitty_window "source" "edit $TT \n" && \
    in_new_kitty_window "log" "rails_log $TT \n" && \
    in_new_kitty_window "console" "rails_console $TT \n" && \
    in_new_kitty_window "resque" "rails_resque $TT \n"
  }

alias tt="tt_terminal; qute -r tt; slack"

################################################################################
export EO=~/git/work/exec_online
export P3=~/git/work/platform3

# Run Rubocop against locally modified files
alias rubodiff='bundle exec pronto run --commit=$(git rev-parse origin/master) --runner rubocop'

function eo_terminal {
  cd $EO
  in_new_kitty_window "eo_source" "edit $EO \n" && \
    in_new_kitty_window "eo_log" "rails_log $EO \n" && \
    in_new_kitty_window "eo_console" "rails_console $EO \n" && \
    in_new_kitty_window "eo_resque" "rails_resque $EO \n" && \
    in_new_kitty_window "yarn" "cd $P3; yarn start \n" && \
    in_new_kitty_window "P3_source" "edit $P3 \n" && \
    in_new_kitty_window "P3_bash" "cd $P3 \n"
}

alias eo="eo_terminal; qute -r eo; slack"

################################################################################
export AHG=~/git/work/ahg_connect
export AHGD=~/git/work/ahg_app
export AHGM=~/git/work/ahgMobile

function ahg_terminal {
  cd $AHG
  in_new_kitty_window "source" "edit $AHG \n" && \
    in_new_kitty_window "log" "rails_log $AHG \n" && \
    in_new_kitty_window "console" "rails_console $AHG \n"
}

alias ahg="ahg_terminal; qute -r ahg; slack"

################################################################################
# Custom Bash prompt
function _fg() { echo "\033[3$1m"; }
function _bg() { echo "\033[4$1m"; }

function _prompt_piece() {
  BLACK="0"
  WHITE="7"
  CLEAR="\033[0m"
  sep=""
  echo " \033[30m$(_bg $1)$sep$(_fg $BLACK) $2 $CLEAR$(_fg $1 t)$sep$CLEAR"
}

function _my_prompt_cmd {
  C1="6"
  C2="4"
  C3="2"
  CLEAR="\033[0m"
  _date_and_time=$(_prompt_piece $C1 "$(date "+%a %b %d %H:%M:%S")")
  _user_name=$(_prompt_piece $C2 "$(whoami)")
  _current_dir=$(_prompt_piece $C3 "$(dirs)")
  echo -e "$CLEAR$_date_and_time$_user_name$_current_dir"
}

function gitpushnew {
  BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
  if [[ "$BRANCH" == "master" ]]; then
    echo "You're on master!"
    return 1
  elif [[ $(git config --get branch.$BRANCH.merge) ]]; then
    echo "This branch already exists upstream"
    return 1
  else
    git push --set-upstream origin $BRANCH
  fi
}

export GPG_TTY=$(tty)

alias rcfg='curl -Lks https://raw.githubusercontent.com/spejamchr/dots/master/install.sh | /bin/bash'
