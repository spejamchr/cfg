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
# Reset chruby-set environment variables.
#
# Calls the `chruby_reset()` method provided by chruby. Removing all custom
# environment variables, returning the ruby version to the system default.
#
function chruby_reset
    set -l IFS ";"
    bchruby 'chruby_reset; echo "$PATH;${GEM_PATH:-_}"' | read -l ch_path ch_gem_path

    if test (id -u) != 0
        set -e GEM_HOME

        if test "$ch_gem_path" = _
            set -e GEM_PATH
        else
            set -gx GEM_PATH "$ch_gem_path"
        end
    end

    set -gx PATH (echo $ch_path | tr : '\n')

    set -l unset_vars RUBY_ROOT RUBY_ENGINE RUBY_VERSION RUBYOPT GEM_ROOT
    for i in (seq (count $unset_vars))
        set -q $unset_vars[$i]; and set -e $unset_vars[$i]; or true
    end
end
