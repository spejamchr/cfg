# `cfg`

> macOS only

### Installation

```shell
git clone git@github.com:spejamchr/cfg.git ~/cfg
```

### Usage

```shell
~/cfg/install.sh
```

If you'd prefer existing dotfiles get overwritten:

```shell
OVERWRITE=true ~/cfg/install.sh
```

This script will:

1. Ensure several directories exist
2. Install a bunch of stuff (see below for the list)
3. Backup existing dotfiles (Unless you specify `OVERWRITE=true`)
4. Symlink the dotfiles stored in this repo into place

### Prerequisites

1. macOS
2. `ruby` and `git` (installed by default on macOS)

You shouldn't have to install anything to run the install script.

### Installed Stuff

- [`Homebrew`](https://brew.sh/): The missing package manager for macOS (or Linux)
- macOS command line tools: Commonly used tools, utilities, and compilers

Installed with `brew install`:

- [`bat`](https://github.com/sharkdp/bat): A cat(1) clone with wings
- [`blueutil`](https://github.com/toy/blueutil): CLI for bluetooth on OSX
- [`bun`](https://github.com/oven-sh/bun): Incredibly fast JavaScript runtime, bundler, test runner, and package manager – all in one
- [`chruby-fish`](https://github.com/JeanMertz/chruby-fish): Thin wrapper around chruby to make it work with the Fish shell
- [`exercism`](https://exercism.io/cli/): Command-line tool to interact with exercism.io
- [`fd`](https://github.com/sharkdp/fd): A simple, fast and user-friendly alternative to 'find'
- [`flyctl`](https://fly.io/): Command-line tools for fly.io services
- [`fzf`](https://github.com/junegunn/fzf): 🌸 A command-line fuzzy finder
- [`git`](https://git-scm.com/): Distributed revision control system
- [`htop`](https://hisham.hm/htop/): Improved top (interactive process viewer)
- [`neovim`](https://neovim.io/): Ambitious Vim-fork focused on extensibility and agility
- [`node@20`](https://nodejs.org/): Platform built on V8 to build network applications
- [`pianobar`](https://github.com/PromyLOPh/pianobar/): Command-line player for [pandora](https://pandora.com)
- [`ripgrep`](https://github.com/BurntSushi/ripgrep): Search tool like grep and The Silver Searcher
- [`ruby-install`](https://github.com/postmodern/ruby-install): Install Ruby, JRuby, Rubinius, TruffleRuby, or mruby
- [`rustup`](https://github.com/rust-lang/rustup): Rust toolchain installer
- [`skhd`](https://github.com/koekeishiya/skhd): Simple hotkey daemon for macOS
- [`sleepwatcher`](https://www.bernhard-baehr.de/): Monitors sleep, wakeup, and idleness of a Mac
- [`tinty`](https://github.com/tinted-theming/tinty): A base16 and base24 color scheme manager
- [`wget`](https://www.gnu.org/software/wget/): Internet file retriever
- [`yabai`](https://github.com/koekeishiya/yabai): A tiling window manager for macOS based on binary space partitioning
- [`yarn`](https://yarnpkg.com/lang/en/): JavaScript package manager

Installed with `brew cask install`:

- [`calibre`](https://calibre-ebook.com/): A powerful and easy to use e-book manager
- [`discord`](https://discord.com/): Voice and text chat software
- [`docker`](https://www.docker.com/products/docker-desktop): App to build and share containerised applications and microservices
- [`dropbox`](https://www.dropbox.com/): Client for the Dropbox cloud storage service
- [`firefox`](https://www.mozilla.org/firefox/): Web browser
- [`font-fira-code-nerd-font`](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/FiraCode): Monospaced font with programming ligatures
- [`google-chrome`](https://www.google.com/chrome/): Web browser
- [`joplin`](https://joplinapp.org/): Note taking and to-do application with synchronisation capabilities
- [`keepassxc`](https://keepassxc.org/): Cross-platform Password Manager
- [`kitty@nightly`](https://github.com/kovidgoyal/kitty): Cross-platform, fast, feature-rich, GPU based terminal
- [`mongodb-compass`](https://www.mongodb.com/products/compass): Interactive tool for analyzing MongoDB data
- [`notunes`](https://github.com/tombonez/noTunes): Simple application that will prevent iTunes or Apple Music from launching
- [`postgres-unofficial`](https://postgresapp.com/): App wrapper for Postgres
- [`slack`](https://slack.com/): Team communication and collaboration software
- [`übersicht`](http://tracesof.net/uebersicht/): Keep an eye on what is happening on your machine and in the World
- [`visual-studio-code`](https://code.visualstudio.com/): Open-source code editor
- [`zoom`](https://www.zoom.us/): Video communication and virtual meeting platform

Other:

- [`prettier-plugin-organize-imports`](https://github.com/simonhaenisch/prettier-plugin-organize-imports): Make Prettier organize your imports using the TypeScript language service API.
  - Installed with `bun add --global`

### Debugging

The script will output information to `STDOUT` and store a logfile in the repo at `.install.log`.

### Organization

The `install.sh` script and the logfile, `.install.log`, are both at the root of the repo (though
the logfile is not tracked by git). The `home/` directory holds all the dotfiles. It is organized
such that a file `home/something` will be symlinked to `~/.something`, and `home/dir/descendant`
will be symlinked to `~/.dir/descendant`.
