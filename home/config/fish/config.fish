set -gx fish_greeting '' # turn off https://fishshell.com/docs/current/cmds/fish_greeting.html
set -gx XDG_CONFIG_HOME ~/.config
set -gx EDITOR nvim
set -gx EO ~/git/work/exec_online

fish_add_path ~/code/scripts
fish_add_path ~/.bin
fish_add_path ~/.cargo/bin

if test (arch) = i386
    set HOMEBREW_PREFIX /usr/local
else
    set HOMEBREW_PREFIX /opt/homebrew
end

fish_add_path -m --path $HOMEBREW_PREFIX/bin

if status is-interactive
    set -gx BASE16_SHELL "$XDG_CONFIG_HOME/base16-shell/"
    if test -s "$BASE16_SHELL"
        source "$BASE16_SHELL/profile_helper.fish"
    end
    set -gx BASE16_SHELL_HOOKS "$XDG_CONFIG_HOME/base16-shell-hooks"

    set -g fish_prompt_pwd_dir_length 0
end
