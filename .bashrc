
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Let dots know I'm using it
export USES_DOTS=true

export PATH=$PATH:/Applications/Postgres.app/Contents/Versions/latest/bin
# Yarn setup (https://yarnpkg.com/en/docs/install#mac-tab)
export PATH="$PATH:`yarn global bin`"

# My own scripts
export PATH=$PATH:/Users/spencer/code/scripts

export CLICOLOR=1

source /usr/local/opt/chruby/share/chruby/chruby.sh
source /usr/local/opt/chruby/share/chruby/auto.sh
chruby 2.5.1

alias eb="vim ~/.bash_profile; source ~/.bash_profile; echo \".bash_profile edited and sourced\""

alias ds="find . -name '.DS_Store' -type f -print -delete"  # Remove .DS_Store files

################################################################################
# Start TroopTrack stuff
# cd to TroopTrack and: open atom, start tailing the log, open rails console,
#                       Start resque (all in separate tabs)
# Open the dev website
# Open Slack

# Open a new Terminal Tab
function ott() {
  osascript -e 'tell application "Terminal" to activate' -e 'tell application "System Events" to tell process "Terminal" to keystroke "t" using command down'
}
# Do some command in the currently open terminal tab
function docom() {
  osascript -e 'tell application "Terminal" to do script "'$1'" in selected tab of the front window'
}

alias cdtt="cd ~/git/TroopTrack"
alias start_resque="bundle exec rake environment resque:work QUEUE='*'"

alias tt_atom="cdtt; atom ."
alias tt_log="cdtt; tail -f log/development.log"
alias tt_console="cdtt; rails c"
alias tt_resque="cdtt; start_resque"

alias tt_terminal="ott; docom tt_log; ott; docom tt_console; ott; docom tt_resque"
alias tt_website="open http://trooptrack.test"
alias slack="open /Applications/Slack.app/"
alias harvest="open https://trooptrack.harvestapp.com/time"
alias tt_github="open https://github.com/TroopTrack/TroopTrack/issues"

alias tt="tt_github; tt_website; slack; tt_atom; sleep 1; tt_terminal"
################################################################################
# Start AHGConnect Stuff
# cd to AHGConnect and: open atom, start tailing the log, open rails console
# Open the dev website
# Open Slack

alias cdahg="cd ~/git/ahg_connect"
alias cdahgt="cd ~/git/ahg_app"
alias cdahgm="cd ~/git/ahgMobile"

alias ahg_atom="cdahg; atom ."
alias ahg_log="cdahg; tail -f log/development.log"
alias ahg_console="cdahg; rails c"

alias ahgt_start="cdahgt; yarn start"
alias ahgt_atom="cdahgt; atom ."

alias ahgm_start="cdahgm; yarn ios"
alias ahgm_atom="cdahgm; atom ."

alias ahg_terminal="ott; docom ahg_log; ott; docom ahg_console; ott; docom ahgt_start; ott; docom ahgt_atom; ott; docom ahgm_start; ott; docom ahgm_atom"
alias ahg_terminal="ott; docom ahg_log; ott; docom ahg_console"
alias ahg_website="open http://ahg-connect.test/national"
alias ahg_github="open https://github.com/TroopTrack/ahg_connect"
alias ahg_pivotal="open https://www.pivotaltracker.com/n/projects/901476"

alias ahg="harvest; ahg_pivotal; ahg_github; ahg_website; slack; ahg_atom; ahg_terminal"
################################################################################
# Start Teereach stuff (Kale Leavitt's website)
alias cdentrada="cd ~/git/public_html/entrada"
alias cdteereach="cd ~/git/public_html"
alias teereach_atom="cdteereach; atom ."
alias entrada_start="cdentrada; php -S localhost:8000"

alias teereach="ott; docom entrada_start; open http://localhost:8000/; teereach_atom"


# Use this to fix the built-in camera
#    from:    https://discussions.apple.com/thread/4282533?tstart=0
alias fix_camera="sudo killall VDCAssistant"

# Custom Bash prompt
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

function gitpushnew {
  BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
  if [ "$BRANCH" == "master" ]; then
    echo "You're on master!"
  else
    git push --set-upstream origin $BRANCH
  fi
}

export PS1="\[\e[36m\][\d \t] \h:\w \u \`parse_git_branch\`\[\e[m\]\n\[\e[36m\]\\$ \[\e[m\]"

# added by Anaconda3 4.3.0 installer
export PATH="/Users/spencer/anaconda/bin:$PATH"
export GPG_TTY=$(tty)

export PATH="$HOME/.cargo/bin:$PATH"

# Use NeoVim
export VISUAL=nvim
export EDITOR="$VISUAL"

alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
alias rcfg='curl -Lks https://raw.githubusercontent.com/spejamchr/dots/master/install.sh | /bin/bash'
