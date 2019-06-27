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

### Overview

This stores my dotfiles, and installs several packages I use.

1. Set up some local directories to hold various git repositories
2. Install a bunch of stuff
3. Backup existing dotfiles
4. Symlink my dotfiles into place

### Prerequisites

1. macOS
2. `ruby`
3. `git`

### Installed Stuff

- [`Homebrew`](https://brew.sh/): The missing package manager for macOS (or Linux)
- macOS command line tools: Commonly used tools, utilities, and compilers
- [`chruby`](https://github.com/postmodern/chruby): Ruby environment tool
- [`chunkwm`](https://github.com/koekeishiya/chunkwm): Tiling window manager for macOS based on plugin architecture
- [`cmake`](https://cmake.org/): Cross-platform make
- [`firacode`](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/FiraCode): Monospaced font with programming ligatures
- [`flux`](https://justgetflux.com/): Warm up your computer display at night
- [`gnupg`](https://gnupg.org/): GNU Pretty Good Privacy (PGP) package
- [`gpg-suite-no-mail`](https://gpgtools.org/): GPG Keychain saves GPG passwords
- [`htop`](https://hisham.hm/htop/): Improved top (interactive process viewer)
- [`imagemagick`](https://imagemagick.org/index.php): Tools and libraries to manipulate images in many formats
- [`librsvg`](https://wiki.gnome.org/Projects/LibRsvg): Library to render SVG files using Cairo
- [`libyaml`](https://github.com/yaml/libyaml): YAML Parser
- [`mpv`](https://mpv.io/): Media player based on MPlayer and mplayer2
- [`mysql@5.7`](https://dev.mysql.com/doc/refman/5.7/en/): Open source relational database management system
- [`neovim`](https://neovim.io/): Ambitious Vim-fork focused on extensibility and agility
- [`pianobar`](https://github.com/PromyLOPh/pianobar/): Command-line player for [pandora](https://pandora.com)
- [`pkg-config`](https://freedesktop.org/wiki/Software/pkg-config/): Manage compile and link flags for libraries
- [`puma-dev`](https://github.com/puma/puma-dev): A tool to manage rack apps in development with puma
- [`optipng`](https://optipng.sourceforge.io/): PNG file optimizer
- [`qutebrowser`](https://www.qutebrowser.org/): A keyboard-driven, vim-like browser based on PyQt5
- [`redis`](https://redis.io/): Persistent key-value database, with built-in net interface
- [`ripgrep`](https://github.com/BurntSushi/ripgrep): Search tool like grep and The Silver Searcher
- [`ruby-install`](https://github.com/postmodern/ruby-install): Install Ruby, JRuby, Rubinius, TruffleRuby, or mruby
- [`skhd`](https://github.com/koekeishiya/skhd): Simple hotkey daemon for macOS
- [`yarn`](https://yarnpkg.com/lang/en/): JavaScript package manager
- [`zsh`](https://www.zsh.org/): UNIX shell (command interpreter)
- [`zsh-completions`](https://github.com/zsh-users/zsh-completions): Additional completion definitions for zsh

### Debugging

If the script manages to clone this repo, it will store a logfile in this repo
at `.install.log`.
