
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Let dots know I'm using it
export USES_DOTS=true

export PATH=$PATH:/Applications/Postgres.app/Contents/Versions/latest/bin
# Yarn setup (https://yarnpkg.com/en/docs/install#mac-tab)
export PATH="$PATH:`yarn global bin`"

# Rust stuff
export PATH="$HOME/.cargo/bin:$PATH"

# Use the old mysql version
export PATH="/usr/local/opt/mysql@5.7/bin:$PATH"

# My own scripts
export PATH=$PATH:/Users/spencer/code/scripts

export CLICOLOR=1

# Use NeoVim
export VISUAL=nvim
export EDITOR="$VISUAL"

source /usr/local/opt/chruby/share/chruby/chruby.sh
source /usr/local/opt/chruby/share/chruby/auto.sh
chruby 2.5.1

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

function reading {
  current_playlist=$(osascript -e 'tell application "iTunes" to name of current playlist as string')
  playing=$(osascript -e 'tell application "iTunes" to player state as string')
  if [ $current_playlist != "Reading" ]; then
    osascript -e 'tell application "iTunes" to play playlist "Reading"'
  elif [ $playing != "playing" ]; then
    osascript -e 'tell application "iTunes" to play'
  fi
}

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

alias slack="open /Applications/Slack.app/"

################################################################################
# Start TroopTrack stuff
#
# ONLY AVAILABLE IN KITTY! (Since it's so easy to programmatically control)
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

if [ $(which kitty) ]; then
  alias tt_log="rails_command $TT tail -f log/development.log"
  alias tt_console="rails_command $TT rails console"
  alias tt_resque="rails_command $TT start_resque"

  function tt_terminal {
    cd $TT
    kitty @ new-window --new-tab --tab-title "source" --title "source" --keep-focus
    kitty @ send-text --match title:source "edit $TT \n"

    kitty @ new-window --new-tab --tab-title "log" --title "log" --keep-focus
    kitty @ send-text --match title:log tt_log "\n"

    kitty @ new-window --new-tab --tab-title "console" --title "console" --keep-focus
    kitty @ send-text --match title:console tt_console "\n"

    kitty @ new-window --new-tab --tab-title "resque" --title "resque" --keep-focus
    kitty @ send-text --match title:resque tt_resque "\n"
  }

  alias tt_website="open http://trooptrack.test"
  alias harvest="open https://trooptrack.harvestapp.com/time"
  alias tt_github="open https://github.com/TroopTrack/TroopTrack/issues"

  function tt {
    tt_terminal
    qute -r tt
    slack
  }
fi

################################################################################
# Start ExecOnline Stuff
#
# ONLY AVAILABLE IN KITTY! (Since it's so easy to programmatically control)
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

if [ $(which kitty) ]; then
  alias eo_log="rails_command $EO tail -f log/development.log"
  alias eo_console="rails_command $EO rails console"
  alias eo_resque="rails_command $EO start_resque"

  function eo_terminal {
    cd $EO
    kitty @ new-window --new-tab --tab-title "eo source" --title "eo_source" --keep-focus
    kitty @ send-text --match title:eo_source "edit $EO \n"

    kitty @ new-window --new-tab --tab-title "eo_log" --title "eo_log" --keep-focus
    kitty @ send-text --match title:log eo_log "\n"

    kitty @ new-window --new-tab --tab-title "eo_console" --title "eo_console" --keep-focus
    kitty @ send-text --match title:console eo_console "\n"

    kitty @ new-window --new-tab --tab-title "eo_resque" --title "eo_resque" --keep-focus
    kitty @ send-text --match title:resque eo_resque "\n"

    kitty @ new-window --new-tab --tab-title "yarn" --title "yarn" --keep-focus
    kitty @ send-text --match title:yarn "cd $P3; yarn start \n"

    kitty @ new-window --new-tab --tab-title "P3_source" --title "P3_source" --keep-focus
    kitty @ send-text --match title:P3_source "edit $P3 \n"

    kitty @ new-window --new-tab --tab-title "P3_bash" --title "P3_bash" --keep-focus
    kitty @ send-text --match title:P3_bash "cd $P3 \n"
  }

  function eo {
    eo_terminal
    qute -r eo
    slack
  }
fi

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

if [ $(which kitty) ]; then
  alias ahg_log="rails_command $AHG tail -f log/development.log"
  alias ahg_console="rails_command $AHG rails console"
  alias ahg_resque="rails_command $AHG start_resque"

  alias ahgd_start="(cd $AHGD; yarn start)"

  alias ahgm_start="(cd $AHGM; yarn ios)"

  function ahg_terminal {
    cd $AHG
    kitty @ new-window --new-tab --tab-title "source" --title "source" --keep-focus
    kitty @ send-text --match title:source "edit $AHG \n"

    kitty @ new-window --new-tab --tab-title "log" --title "log" --keep-focus
    kitty @ send-text --match title:log ahg_log "\n"

    kitty @ new-window --new-tab --tab-title "console" --title "console" --keep-focus
    kitty @ send-text --match title:console ahg_console "\n"
  }

  alias ahg_website="open http://ahg-connect.test/national"
  alias ahg_github="open https://github.com/TroopTrack/ahg_connect"
  alias ahg_pivotal="open https://www.pivotaltracker.com/n/projects/901476"

  function ahg {
    ahg_terminal
    qute -r ahg
    slack
  }
fi

################################################################################
# Start Teereach stuff (Kale Leavitt's website)
#
alias cdentrada="cd ~/git/work/public_html/entrada"
alias cdteereach="cd ~/git/work/public_html"
alias entrada_start="cdentrada; php -S localhost:8000"


# Use this to fix the built-in camera
#    from:    https://discussions.apple.com/thread/4282533?tstart=0
alias fix_camera="sudo killall VDCAssistant"

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

C1="96;164;162"
C2="98;114;164"
C3="96;164;113"
C4="124;96;164"
BLACK="0;0;0"
WHITE="255;255;255"
CLEAR="\033[0m"

function _fg() {
  if [ "$COLORTERM" ]; then
    echo "\033[38;2;$1m"
  elif [ "$2" ]; then
    echo "\033[36m"
  else
    echo "\033[30m"
  fi
}

function _bg() {
  if [ "$COLORTERM" ]; then
    echo "\033[48;2;$1m"
  else
    echo "\033[46m"
  fi
}

function _prompt_piece() {
  sep=""
  echo " \033[30m$(_bg $1)$sep$(_fg $WHITE) $2 $CLEAR$(_fg $1 t)$sep$CLEAR"
}

function z() {
  time "$@"
  phrases="done
  finished
  over
  end
  stop
  terminated
  complete
  concluded
  performed
  realized
  wrought
  brought to pass"

  word=$(echo "$phrases" | sort -R | head -n 1)
  say "$word"
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
  else
    git push --set-upstream origin $BRANCH
  fi
}

export GPG_TTY=$(tty)

alias rcfg='curl -Lks https://raw.githubusercontent.com/spejamchr/dots/master/install.sh | /bin/bash'
