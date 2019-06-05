[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/.profile ] && source ~/.profile

# Edit this file more easily
alias ez="$EDITOR ~/.zshrc; source ~/.zshrc; echo \".zshrc edited and sourced\""

# Common emacs bindings for vi mode
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line

setopt prompt_subst
autoload -Uz promptinit vcs_info compinit
promptinit
compinit

# Report command running time if it is more than 5 seconds
REPORTTIME=5
# Keep a lot of history
HISTFILE=~/.zhistory
HISTSIZE=5000
SAVEHIST=5000
# Add commands to history as they are entered, don't wait for shell to exit
setopt INC_APPEND_HISTORY
# Also remember command start time and duration
setopt EXTENDED_HISTORY
# Do not keep duplicate commands in history
setopt HIST_IGNORE_ALL_DUPS
# Do not remember commands that start with a whitespace
setopt HIST_IGNORE_SPACE
# Correct spelling of all arguments in the command line
setopt CORRECT_ALL
# Enable autocompletion
zstyle ':completion:*' completer _complete _correct _approximate

# Get version control info from git
zstyle ':vcs_info:*' actionformats '%b|%a'
zstyle ':vcs_info:*' formats '%b'
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*:-all-' command ~/code/scripts/git

vcs_info_wrapper() {
  vcs_info
  if [ -n "$vcs_info_msg_0_" ]; then
    # Get some extra info that vcs_info doesn't provide
    gs=`git status 2>&1 | tee`
    dirty=`echo -n "$gs" 2> /dev/null | grep "modified:" &> /dev/null; echo "$?"`
    untracked=`echo -n "$gs" 2> /dev/null | grep "Untracked files:" &> /dev/null; echo "$?"`
    ahead=`echo -n "$gs" 2> /dev/null | grep "Your branch is ahead of" &> /dev/null; echo "$?"`
    newfile=`echo -n "$gs" 2> /dev/null | grep "new file:" &> /dev/null; echo "$?"`
    renamed=`echo -n "$gs" 2> /dev/null | grep "renamed:" &> /dev/null; echo "$?"`
    deleted=`echo -n "$gs" 2> /dev/null | grep "deleted:" &> /dev/null; echo "$?"`
    bits=''
    [[ "${renamed}"   == "0" ]] && bits=">${bits}"
    [[ "${ahead}"     == "0" ]] && bits="*${bits}"
    [[ "${newfile}"   == "0" ]] && bits="+${bits}"
    [[ "${untracked}" == "0" ]] && bits="?${bits}"
    [[ "${deleted}"   == "0" ]] && bits="x${bits}"
    [[ "${dirty}"     == "0" ]] && bits="!${bits}"
    [[ ! "${bits}" == "" ]] && bits=" ${bits}"

    echo "%F{0}%K{5} ${vcs_info_msg_0_}${bits} %F{5}%K{0} "
  fi
}

PROMPT=' %F{0}%K{6} %D{%a %b %d %H:%M:%S} %F{6}%K{0} '"\
"'%F{0}%K{4} %n %F{4}%K{0} '"\
"'%F{0}%K{2} %~ %F{2}%K{0} '"\
"'$(vcs_info_wrapper)'"\
"'%f%k
%B%#%b '

# Change the cursor based on input or command mode. Similar to vim.
function zle-line-init zle-keymap-select() {
  case $KEYMAP in
    vicmd) print -n -- '\033[1 q';;
    viins|main) print -n -- '\033[5 q';;
  esac
}

zle -N zle-line-init
zle -N zle-keymap-select
