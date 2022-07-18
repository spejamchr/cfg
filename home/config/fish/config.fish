set -gx fish_greeting '' # turn off https://fishshell.com/docs/current/cmds/fish_greeting.html
set -gx XDG_CONFIG_HOME ~/.config
set -gx EDITOR nvim
set -gx EO ~/git/work/exec_online
set -gx BASE16_SHELL /usr/local/opt/zplug/repos/chriskempson/base16-shell/
set -gx BASE16_SHELL_HOOKS $XDG_CONFIG_HOME/base16-shell-hooks

fish_add_path ~/code/scripts
fish_add_path ~/.bin
fish_add_path ~/.cargo/bin

if status is-interactive
    # Commands to run in interactive sessions can go here
    set -g fish_prompt_pwd_dir_length 0
end
