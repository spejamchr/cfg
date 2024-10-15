# vim:fileencoding=utf-8:foldmethod=marker

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

# pnpm
set -gx PNPM_HOME "/Users/schristiansen/Library/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end
# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

# ExecOnline {{{
# Last updated for this PR: https://github.com/execonline-inc/exec_online/pull/8956
# The PR assumes a POSIX-compliant shell. I'm not sure what will break using fish.
# Normally I would source ~/.dev/.rc. Instead, I'm manually defining the `dev`
# alias in fish, and I'm skipping the bits about sourcing ~/.dev/.env and
# defining the `dev-awsume` function.
alias dev="$EO/dev"
# }}}
