# vim:fileencoding=utf-8:foldmethod=marker

set -gx fish_greeting '' # turn off https://fishshell.com/docs/current/cmds/fish_greeting.html
set -gx XDG_CONFIG_HOME ~/.config
set -gx EDITOR nvim
set -gx DOTNET_ROOT "/opt/homebrew/Cellar/dotnet/9.0.0/libexec"

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
    set -g fish_prompt_pwd_dir_length 0

    chruby 3 # Don't start the latest ruby for rails running in puma-dev
end

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
