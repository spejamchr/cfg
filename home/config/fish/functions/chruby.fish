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
# Custom `chruby` command to be called in the Fish environment.
#
# Thin wrapper around the bash version of `chruby`, passing along arguments to
# it, and capturing the outputted environment variables to be set in Fish.
#
function chruby
    set -l CHRUBY_FISH_VERSION '0.8.2'
    set -l RUBIES (bchruby 'echo ${RUBIES[@]}' | tr ' ' '\n')

    switch "$argv[1]"
        case -h --help
            bchruby "chruby $argv"
        case -V --version
            bchruby "chruby $argv"
            echo "chruby-fish: $CHRUBY_FISH_VERSION"
        case system
            chruby_reset
        case '*'
            if test "$argv[1]" = ''
                bchruby "chruby $argv"
            else
                set -l dir ruby match
                for dir in $RUBIES
                    set dir (echo "$dir" | sed -e 's|/$||')
                    set ruby (echo "$dir" | awk -F/ '{print $NF}')

                    test "$argv[1]" = "$ruby"; and set match "$dir"; and break
                    echo "$ruby" | grep -q -- "$argv[1]"; and set match "$dir"
                end

                if test -z "$match"
                    echo "chruby: unknown Ruby: $argv[1]" >&2
                    return 1
                end

                set -e argv[1]
                chruby_use "$match" "$argv"
            end
    end
end
