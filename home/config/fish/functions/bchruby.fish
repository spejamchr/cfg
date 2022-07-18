# The MIT License (MIT)
#
# Copyright (c) 2014-2016 Jean Mertz <jean@mertz.fm>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# see https://github.com/JeanMertz/chruby-fish/blob/84454e7b974a73bb278b646fd1ac7dae515b6285/share/chruby/chruby.fish
# I (Spencer) Separated the script into individual fish functions to speed up the shell start-up time

#
# Execute chruby commands through bash.
#
# This method allows any command to be executed through the bash interpreter,
# allowing us to use the original chruby implementation while overlaying a thin
# wrapper on top of it to set ENV variables in the Fish shell.
#
# You can optionally set the $CHRUBY_ROOT environment variable if your
# `chruby.sh` is located in a custom path.
#
function bchruby
    set -q CHRUBY_ROOT; or set CHRUBY_ROOT /usr/local

    if test ! -f "$CHRUBY_ROOT/share/chruby/chruby.sh"
        echo "$CHRUBY_ROOT/share/chruby/chruby.sh does not exist." \
            "Set \$CHRUBY_ROOT to point to the correct path." \
            "(currently pointing to `$CHRUBY_ROOT`)"
        return 1
    end

    set bash_path (env | grep '^PATH=' | cut -c 6-)
    env - HOME="$HOME" \
        PREFIX="$PREFIX" \
        PATH="$bash_path" \
        RUBY_ROOT="$RUBY_ROOT" \
        GEM_HOME="$GEM_HOME" \
        GEM_ROOT="$GEM_ROOT" \
        GEM_PATH="$GEM_PATH" \
        bash -lc "source \"$CHRUBY_ROOT/share/chruby/chruby.sh\"; $argv"
end
