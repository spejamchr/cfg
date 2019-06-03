export XDG_CONFIG_HOME="$HOME/.config"

# Base16 Shell
BASE16_SHELL="$HOME/.config/base16-shell/"
[ -n "$PS1" ] && \
    [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
        eval "$("$BASE16_SHELL/profile_helper.sh")"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Let dots know I'm using it
export USES_DOTS=true

# Set the locale
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

export PATH=$PATH:/Applications/Postgres.app/Contents/Versions/latest/bin
# Yarn setup (https://yarnpkg.com/en/docs/install#mac-tab)
export PATH="$PATH:`yarn global bin`"

# Rust stuff
export PATH="$HOME/.cargo/bin:$PATH"

# Use the old mysql version
export PATH="/usr/local/opt/mysql@5.7/bin:$PATH"

# Haskell Stuff
export PATH="$HOME/.local/bin:$PATH"

# My own scripts
export PATH="$PATH:$HOME/code/scripts"

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
alias eb="$EDITOR ~/.bashrc; source ~/.bashrc; echo \".bashrc edited and sourced\""

# Remove .DS_Store files
alias ds="find . -name '.DS_Store' -type f -print -delete"

# Use qutebrowser from the shell more easily
alias qute='open /Applications/qutebrowser.app/ --args'

# I have a hard time remembering this
alias start_resque="bundle exec rake environment resque:work QUEUE='*'"

# I forget this too easily:
alias sync_test="rails db:test:prepare"

# Remove the git alias if it exists
# Fixes a bug when re-sourcing this file.
[ "$(alias | grep 'alias git=')" ] && unalias git

# git for my dotfiles
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

function git_or_config {
  if [ "$HOME" == "$PWD" ]; then
    config "$@"
  else
    git "$@"
  fi
}

alias git='git_or_config'

# It's nicer to open a dir for editing when it's also the cwd
function edit {
  (cd $1; $EDITOR .)
}

# This just simplifies things below
function rails_command {
  (
    cd $1
    shift

    if [ -f .ruby-version ]; then
      version=$(cat .ruby-version)
    fi
    if [ "$version" ]; then
      chruby "$version"
    fi

    eval $@
  )
}

function rails_log {
  rails_command $1 tail -f log/development.log
}

function rails_console {
  rails_command $1 rails console
}

function rails_resque {
  rails_command $1 start_resque
}

function in_new_kitty_window {
  if [[ "$TERM" != "xterm-kitty" ]]; then
    echo "Only available in Kitty"
    return 1
  fi

  title="$1"
  shift

  kitty @ new-window --new-tab --tab-title "$title" --title "$title" --keep-focus

  if [[ "$@" ]]; then
    kitty @ send-text --match title:"$title" "$@"
  fi
}

alias slack="open /Applications/Slack.app/"

################################################################################
# Start TroopTrack stuff
#
# * cd to TroopTrack and (in separate tabs):
#   * open editor,
#   * start tailing the log,
#   * open rails console,
#   * start resque
# * Open the tt browser session
# * Open Slack
#
export TT=~/git/work/TroopTrack

function tt_terminal {
  cd $TT
  in_new_kitty_window "source" "edit $TT \n" && \
    in_new_kitty_window "log" "rails_log $TT \n" && \
    in_new_kitty_window "console" "rails_console $TT \n" && \
    in_new_kitty_window "resque" "rails_resque $TT \n"
  }

function tt {
  tt_terminal
  qute -r tt
  slack
}

################################################################################
# Start ExecOnline Stuff
#
# * cd to exec_online and:
#   * open editor,
#   * start tailing the log,
#   * open rails console
# * Open the eo browser session
# * Open Slack
#
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

function eo {
  eo_terminal
  qute -r eo
  slack
}

################################################################################
# Start AHGConnect Stuff
#
# ONLY AVAILABLE IN KITTY! (Since it's so easy to programmatically control)
#
# * cd to AHGConnect and:
#   * open editor,
#   * start tailing the log,
#   * open rails console
# * Open the ahg browser session
# * Open Slack
#
export AHG=~/git/work/ahg_connect
export AHGD=~/git/work/ahg_app
export AHGM=~/git/work/ahgMobile

function ahg_terminal {
  cd $AHG
  in_new_kitty_window "source" "edit $AHG \n" && \
    in_new_kitty_window "log" "rails_log $AHG \n" && \
    in_new_kitty_window "console" "rails_console $AHG \n"
}

function ahg {
  ahg_terminal
  qute -r ahg
  slack
}

################################################################################
# Custom Bash prompt
#
# get current branch in git repo
function parse_git_branch() {
  BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
  if [ ! "${BRANCH}" == "" ]
  then
    STAT=`parse_git_dirty`
    echo "${BRANCH}${STAT}"
  else
    echo ""
  fi
}

# get current status of git repo
function parse_git_dirty {
  status=`git status 2>&1 | tee`
  dirty=`echo -n "${status}" 2> /dev/null | grep "modified:" &> /dev/null; echo "$?"`
  untracked=`echo -n "${status}" 2> /dev/null | grep "Untracked files" &> /dev/null; echo "$?"`
  ahead=`echo -n "${status}" 2> /dev/null | grep "Your branch is ahead of" &> /dev/null; echo "$?"`
  newfile=`echo -n "${status}" 2> /dev/null | grep "new file:" &> /dev/null; echo "$?"`
  renamed=`echo -n "${status}" 2> /dev/null | grep "renamed:" &> /dev/null; echo "$?"`
  deleted=`echo -n "${status}" 2> /dev/null | grep "deleted:" &> /dev/null; echo "$?"`
  bits=''
  if [ "${renamed}" == "0" ]; then
    bits=">${bits}"
  fi
  if [ "${ahead}" == "0" ]; then
    bits="*${bits}"
  fi
  if [ "${newfile}" == "0" ]; then
    bits="+${bits}"
  fi
  if [ "${untracked}" == "0" ]; then
    bits="?${bits}"
  fi
  if [ "${deleted}" == "0" ]; then
    bits="x${bits}"
  fi
  if [ "${dirty}" == "0" ]; then
    bits="!${bits}"
  fi
  if [ ! "${bits}" == "" ]; then
    echo " ${bits}"
  else
    echo ""
  fi
}

C1="6"
C2="4"
C3="2"
C4="5"
BLACK="0"
WHITE="7"
CLEAR="\033[0m"

function _fg() {
  echo "\033[3$1m"
}

function _bg() {
  echo "\033[4$1m"
}

function _prompt_piece() {
  sep=""
  echo " \033[30m$(_bg $1)$sep$(_fg $BLACK) $2 $CLEAR$(_fg $1 t)$sep$CLEAR"
}

function _my_prompt_cmd {
  _date_and_time=$(_prompt_piece $C1 "$(date "+%a %b %d %H:%M:%S")")
  _user_name=$(_prompt_piece $C2 "$(whoami)")
  _current_dir=$(_prompt_piece $C3 "$(dirs +0)")
  pgb=$(parse_git_branch)
  if [ "$pgb" ];then
    _git_info=$(_prompt_piece $C4 "$pgb")
  else
    _git_info=""
  fi
  echo -e "$CLEAR$_date_and_time$_user_name$_current_dir$_git_info"
}

PROMPT_COMMAND=_my_prompt_cmd
PS1="\[\033[1m\]\\$ \[$CLEAR\]"

function gitpushnew {
  BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
  if [ "$BRANCH" == "master" ]; then
    echo "You're on master!"
    return 1
  elif [ $(git config --get branch.$BRANCH.merge) ]; then
    echo "This branch already exists upstream"
    return 1
  else
    git push --set-upstream origin $BRANCH
  fi
}

export GPG_TTY=$(tty)

alias rcfg='curl -Lks https://raw.githubusercontent.com/spejamchr/dots/master/install.sh | /bin/bash'
