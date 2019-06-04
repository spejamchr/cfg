[ -f ~/.fzf.bash ] && source ~/.fzf.bash
[ -f ~/.profile ] && source ~/.profile

# Edit this file more easily
alias eb="$EDITOR ~/.bashrc; source ~/.bashrc; echo \".bashrc edited and sourced\""

PROMPT_COMMAND=_my_prompt_cmd
PS1="\[\033[1m\]\\$ \[$CLEAR\]"
