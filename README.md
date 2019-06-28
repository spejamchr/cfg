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
2. Ensure several directories exist: `~/git/work`, `~/git/fun`, `~/git/other`, `~/.bin`, and `~/.config`
3. Install a bunch of stuff (see below for the list)
4. Backup existing dotfiles
5. Symlink the dotfiles stored in this repo into place

### Prerequisites

1. macOS
2. `ruby`
3. `git`
4. [SSH connection with GitHub](https://help.github.com/en/articles/connecting-to-github-with-ssh)

### Installed Stuff

- [`Homebrew`](https://brew.sh/): The missing package manager for macOS (or Linux)
- macOS command line tools: Commonly used tools, utilities, and compilers

Installed with `brew install`:

- [`chruby`](https://github.com/postmodern/chruby): Ruby environment tool
- [`chunkwm`](https://github.com/koekeishiya/chunkwm): Tiling window manager for macOS based on plugin architecture
- [`cmake`](https://cmake.org/): Cross-platform make
- [`gnupg`](https://gnupg.org/): GNU Pretty Good Privacy (PGP) package
- [`htop`](https://hisham.hm/htop/): Improved top (interactive process viewer)
- [`imagemagick`](https://imagemagick.org/index.php): Tools and libraries to manipulate images in many formats
- [`libyaml`](https://github.com/yaml/libyaml): YAML Parser
- [`mpv`](https://mpv.io/): Media player based on MPlayer and mplayer2
- [`mysql@5.7`](https://dev.mysql.com/doc/refman/5.7/en/): Open source relational database management system
- [`neovim`](https://neovim.io/): Ambitious Vim-fork focused on extensibility and agility
- [`pianobar`](https://github.com/PromyLOPh/pianobar/): Command-line player for [pandora](https://pandora.com)
- [`pkg-config`](https://freedesktop.org/wiki/Software/pkg-config/): Manage compile and link flags for libraries
- [`puma-dev`](https://github.com/puma/puma-dev): A tool to manage rack apps in development with puma
- [`redis`](https://redis.io/): Persistent key-value database, with built-in net interface
- [`ripgrep`](https://github.com/BurntSushi/ripgrep): Search tool like grep and The Silver Searcher
- [`ruby-install`](https://github.com/postmodern/ruby-install): Install Ruby, JRuby, Rubinius, TruffleRuby, or mruby
- [`skhd`](https://github.com/koekeishiya/skhd): Simple hotkey daemon for macOS
- [`yarn`](https://yarnpkg.com/lang/en/): JavaScript package manager
- [`zsh`](https://www.zsh.org/): UNIX shell (command interpreter)
- [`zsh-completions`](https://github.com/zsh-users/zsh-completions): Additional completion definitions for zsh

Installed with `brew cask install`:

- [`firacode`](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/FiraCode): Monospaced font with programming ligatures
- [`flux`](https://justgetflux.com/): Warm up your computer display at night
- [`gpg-suite-no-mail`](https://gpgtools.org/): Save GPG passwords with GPG Keychain
- [`qutebrowser`](https://www.qutebrowser.org/): A keyboard-driven, vim-like browser based on PyQt5

Cloned repos:

- [`kitty`](https://sw.kovidgoyal.net/kitty/): the fast, featureful, GPU based terminal emulator
- [`powerlevel10k`](https://github.com/romkatv/powerlevel10k): A fast reimplementation of Powerlevel9k ZSH theme
- [`base16-shell`](https://github.com/chriskempson/base16-shell): Base16 for Shells

### Debugging

The script will output information to `STDOUT`, and if the script manages to
clone this repo it will store a logfile in the repo at `.install.log`.

### Organization

The `install.sh` script and the logfile, `.install.log` are both at the root of
the repo (though the install log is not tracked by git). The `home/` directory
holds all the dotfiles. It is organized such that a file `home/something` will
be symlinked to `~/.something`, and `home/dir/descendant` will be symlinked to
`~/.dir/descendant`.
