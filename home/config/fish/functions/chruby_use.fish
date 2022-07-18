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
# Set environment variables to point to custom Ruby install.
#
# Resets current Ruby version then runs chruby in bash, capturing it's defined
# variables and setting them in the current Fish instance.
#
function chruby_use
    set -l args '; echo "$RUBY_ROOT;${RUBYOPT:-_};${GEM_HOME:-_};${GEM_PATH:-_};${GEM_ROOT:-_};$PATH;$RUBY_ENGINE;$RUBY_VERSION;$?"'

    set -l IFS ";"
    bchruby chruby_use $argv $args | read -l ch_ruby_root ch_rubyopt ch_gem_home \
        ch_gem_path ch_gem_root ch_path \
        ch_ruby_engine ch_ruby_version \
        ch_status

    test "$ch_status" = 0; or return 1
    test -n "$RUBY_ROOT"; and chruby_reset

    set -gx RUBY_ENGINE "$ch_ruby_engine"
    set -gx RUBY_VERSION "$ch_ruby_version"

    set -gx RUBY_ROOT $ch_ruby_root
    test "$ch_gem_root" = _; or set -gx GEM_ROOT "$ch_gem_root"
    test "$ch_rubyopt" = _; or set -gx RUBYOPT "$ch_rubyopt"

    # Fish warns the user when a path in the PATH environment variable does not
    # exist:
    #
    #   set: Warning: path component /path/to/bin may not be valid in PATH.
    #   set: No such file or directory
    #
    # Given that this happens for every Ruby install (until gems are installed in
    # these paths), we pre-create this directory, to silence Fish' warning.
    #
    for gem_path in (echo "$ch_gem_path" | tr : '\n')
        test -d "$gem_path/bin"; or mkdir -p "$gem_path/bin"
    end

    set -gx PATH (echo "$ch_path" | tr : '\n')

    if test (id -u) != 0
        set -gx GEM_HOME "$ch_gem_home"
        set -gx GEM_PATH "$ch_gem_path"
    end
end
