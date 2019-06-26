[ -f ~/.fzf.bash ] && source ~/.fzf.bash
[ -f ~/.profile ] && source ~/.profile

# Edit this file more easily
alias eb="$EDITOR ~/.bashrc; source ~/.bashrc; echo \".bashrc edited and sourced\""

_my_prompt_cmd &> /dev/null
if [[ $? -eq 0 ]]; then
  PROMPT_COMMAND=_my_prompt_cmd
fi

PS1="\[\033[1m\]\\$ \[\033[0m\]"
