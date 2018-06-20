
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Let dots know I'm using it
export USES_DOTS=true

export PATH=$PATH:/Applications/Postgres.app/Contents/Versions/latest/bin
# Yarn setup (https://yarnpkg.com/en/docs/install#mac-tab)
export PATH="$PATH:`yarn global bin`"

# Rust stuff
export PATH="$HOME/.cargo/bin:$PATH"

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

    $@
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
alias cdentrada="cd ~/git/public_html/entrada"
alias cdteereach="cd ~/git/public_html"
alias teereach_atom="cdteereach; atom ."
alias entrada_start="cdentrada; php -S localhost:8000"

# alias teereach="ott; docom entrada_start; open http://localhost:8000/; teereach_atom"


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
    echo "[${BRANCH}${STAT}]"
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

export PS1="\[\e[36m\][\d \t] \h:\w \u \`parse_git_branch\`\[\e[m\]\n\[\e[36m\]\\$ \[\e[m\]"

function gitpushnew {
  BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
  if [ "$BRANCH" == "master" ]; then
    echo "You're on master!"
  else
    git push --set-upstream origin $BRANCH
  fi
}

# added by Anaconda3 4.3.0 installer
export PATH="/Users/spencer/anaconda/bin:$PATH"
export GPG_TTY=$(tty)

alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
alias rcfg='curl -Lks https://raw.githubusercontent.com/spejamchr/dots/master/install.sh | /bin/bash'
