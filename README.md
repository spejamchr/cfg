# `cfg`

> macOS only

### Install/Usage

```shell
curl -Lks https://raw.githubusercontent.com/spejamchr/cfg/master/install.sh | /bin/bash
```

If you'd prefer existing dotfiles get overwritten:

```shell
OVERWRITE=true curl -Lks https://raw.githubusercontent.com/spejamchr/cfg/master/install.sh | /bin/bash
```

This script will:

1. Clone this repo to `$HOME/.dotfiles`
2. Ensure several directories exist
3. Install a bunch of stuff (see below for the list)
4. Backup existing dotfiles (Unless you specify `OVERWRITE=true`)
5. Symlink the dotfiles stored in this repo into place
6. Install `zsh` plugins

### Prerequisites

1. macOS
2. `ruby`, `git`, and `zsh` (installed by default on macOS)

You shouldn't have to install anything to run the install script.

### Installed Stuff

- [`Homebrew`](https://brew.sh/): The missing package manager for macOS (or Linux)
- macOS command line tools: Commonly used tools, utilities, and compilers

Installed with `brew install`:

- [`bat`](https://github.com/sharkdp/bat): A cat(1) clone with wings
- [`blueutil`](https://github.com/toy/blueutil): CLI for bluetooth on OSX
- [`chruby`](https://github.com/postmodern/chruby): Ruby environment tool
- [`chunkwm`](https://github.com/koekeishiya/chunkwm): Tiling window manager for macOS based on plugin architecture
- [`cmake`](https://cmake.org/): Cross-platform make
- [`gnupg`](https://gnupg.org/): GNU Pretty Good Privacy (PGP) package
- [`htop`](https://hisham.hm/htop/): Improved top (interactive process viewer)
- [`imagemagick`](https://imagemagick.org/index.php): Tools and libraries to manipulate images in many formats
- [`libyaml`](https://github.com/yaml/libyaml): YAML Parser
- [`mysql@5.7`](https://dev.mysql.com/doc/refman/5.7/en/): Open source relational database management system
- [`neovim`](https://neovim.io/): Ambitious Vim-fork focused on extensibility and agility
- [`pianobar`](https://github.com/PromyLOPh/pianobar/): Command-line player for [pandora](https://pandora.com)
- [`pkg-config`](https://freedesktop.org/wiki/Software/pkg-config/): Manage compile and link flags for libraries
- [`puma-dev`](https://github.com/puma/puma-dev): A tool to manage rack apps in development with puma
- [`rbenv/tap/openssl@1.0`](https://github.com/rbenv/homebrew-tap): For installing rubies older than 2.4. [See also](https://github.com/postmodern/ruby-install/issues/363#issuecomment-580699347).
- [`redis`](https://redis.io/): Persistent key-value database, with built-in net interface
- [`ripgrep`](https://github.com/BurntSushi/ripgrep): Search tool like grep and The Silver Searcher
- [`ruby-install`](https://github.com/postmodern/ruby-install): Install Ruby, JRuby, Rubinius, TruffleRuby, or mruby
- [`skhd`](https://github.com/koekeishiya/skhd): Simple hotkey daemon for macOS
- [`sleepwatcher`](https://www.bernhard-baehr.de/): Monitors sleep, wakeup, and idleness of a Mac
- [`yarn`](https://yarnpkg.com/lang/en/): JavaScript package manager
- [`zplug`](https://github.com/zplug/zplug): The next-generation plugin manager for zsh
- [`zsh`](https://www.zsh.org/): UNIX shell (command interpreter)
- [`zsh-completions`](https://github.com/zsh-users/zsh-completions): Additional completion definitions for zsh

Installed with `brew cask install`:

- [`calibre`](https://calibre-ebook.com/): A powerful and easy to use e-book manager
- [`dropbox`](https://www.dropbox.com/): Cloud storage
- [`firacode`](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/FiraCode): Monospaced font with programming ligatures
- [`flux`](https://justgetflux.com/): Warm up your computer display at night
- [`gpg-suite-no-mail`](https://gpgtools.org/): Save GPG passwords with GPG Keychain
- [`mpv`](https://mpv.io/): Media player based on MPlayer and mplayer2
- [`sequel-pro`](https://www.sequelpro.com/): MySQL/MariaDB database management for macOS
- [`übersicht`](http://tracesof.net/uebersicht/): Keep an eye on what is happening on your machine and in the World

Cloned repos:

- [`kitty`](https://sw.kovidgoyal.net/kitty/): the fast, featureful, GPU based terminal emulator

### Debugging

The script will output information to `STDOUT`, and if the script successfully
clones this repo it will store a logfile in the repo at `.install.log`.

### Organization

The `install.sh` script and the logfile, `.install.log` are both at the root of
the repo (though the logfile is not tracked by git). The `home/` directory holds
all the dotfiles. It is organized such that a file `home/something` will be
symlinked to `~/.something`, and `home/dir/descendant` will be symlinked to
`~/.dir/descendant`.
