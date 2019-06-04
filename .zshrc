[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/.profile ] && source ~/.profile

# Edit this file more easily
alias ez="$EDITOR ~/.zshrc; source ~/.zshrc; echo \".zshrc edited and sourced\""

precmd() { _my_prompt_cmd }
PROMPT='%B%#%b '
