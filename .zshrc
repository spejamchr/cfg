[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/.profile ] && source ~/.profile

# Edit this file more easily
alias ez="$EDITOR ~/.zshrc; source ~/.zshrc; echo \".zshrc edited and sourced\""

# Common emacs bindings for vi mode
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^P' up-line-or-history
bindkey '^N' down-line-or-history
bindkey '^[^M' self-insert-unmeta # Insert newline w/out running command

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
setopt SHARE_HISTORY
# Also remember command start time and duration
setopt EXTENDED_HISTORY
# Do not keep duplicate commands in history
setopt HIST_IGNORE_ALL_DUPS
# Do not remember commands that start with a whitespace
setopt HIST_IGNORE_SPACE
# Enable autocompletion
zstyle ':completion:*' completer _complete _correct _approximate
zstyle ':completion:*' menu select
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

PROMPT=' %F{0}%K{6} %D{%a %b %d %H:%M:%S} %F{6}%K{0} '"\
"'%F{0}%K{4} %n %F{4}%K{0} '"\
"'%F{0}%K{2} %~ %F{2}%K{0} '"\
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
