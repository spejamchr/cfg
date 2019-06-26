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

source ~/.config/powerlevel10k/powerlevel10k.zsh-theme

POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs vi_mode)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status root_indicator background_jobs chruby date time_joined)
