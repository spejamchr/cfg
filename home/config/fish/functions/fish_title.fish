# Coppied from /usr/local/Cellar/fish/3.3.1/share/fish/functions/fish_title.fish @ line 1
function fish_title
    # emacs' "term" is basically the only term that can't handle it.
    if not set -q INSIDE_EMACS; or string match -vq '*,term:*' -- $INSIDE_EMACS
        # An override for the current command is passed as the first parameter.
        # This is used by `fg` to show the true process name, among others.
        # CHANGE: Comment (__fish_pwd) -- I don't like it in my tab title
        echo (set -q argv[1] && echo $argv[1] || status current-command) # (__fish_pwd)
    end
end
