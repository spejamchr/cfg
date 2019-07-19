# Load ~/Library/Preferences/qutebrowser/autoconfig.yml
# See: https://qutebrowser.org/doc/help/configuring.html#configpy-autoconfig
config.load_autoconfig()

# From https://github.com/evannagle/qutebrowser-dracula-theme
import dracula.draw
dracula.draw.blood(c, {
    'spacing': {
        'vertical': 0,
        'horizontal': 5
    },
    'font': {
        'family': '"Fira Code", Menlo, Terminus, Monaco, Monospace',
        'size': 12
    }
})

# Make hints easier to see
c.colors.hints.match.fg = c.colors.hints.fg
c.colors.hints.fg = c.colors.statusbar.url.success.http.fg

# general settings
c.editor.command = ["kitty", "nvim", "{file}", "+norm {line}G{column}|"]
c.new_instance_open_target = "tab-bg"
c.prompt.filebrowser = False
c.completion.height = "30%"
c.completion.web_history.max_items = -1
c.input.partial_timeout = 2000
c.window.title_format = "{perc}{current_title}"
c.tabs.background = True
c.tabs.favicons.show = "always"
c.tabs.title.format = "{audio}{index} {current_title}"
c.tabs.position = "left"
c.tabs.width = 100
c.tabs.pinned.frozen = True
c.downloads.location.directory = '~/Downloads'
c.content.cache.size = 52428800
c.content.webgl = False
c.content.host_blocking.enabled = True
c.content.cookies.accept = 'no-3rdparty'
c.hints.border = "1px solid #CCCCCC"
c.hints.mode = "letter"
c.hints.min_chars = 1
c.hints.uppercase = True
c.keyhint.blacklist = ["*"]
c.scrolling.bar = "always"
c.scrolling.smooth = True
c.zoom.default = "90%"

# searches
c.url.searchengines['DEFAULT'] = 'https://searx.me/?q={}'
c.url.searchengines['a'] = 'https://wiki.archlinux.org/?search={}'
c.url.searchengines['d'] = 'https://duckduckgo.com/?q={}'
c.url.searchengines['g'] = 'http://www.google.com/search?hl=en&source=hp&ie=ISO-8859-l&q={}'
c.url.searchengines['y'] = 'https://www.youtube.com/results?search_query={}'
c.url.searchengines['w'] = 'https://secure.wikimedia.org/wikipedia/en/w/index.php?title=Special%%3ASearch&search={}'
c.url.searchengines['gh'] = 'https://github.com/search?q={}&type=Code'

# keybinds
# Focus the first visible input on the page
config.bind('gi', 'enter-mode insert ;; jseval --quiet var inputs = document.getElementsByTagName("input"); for(var i = 0; i < inputs.length; i++) { var hidden = false; for(var j = 0; j < inputs[i].attributes.length; j++) { hidden = hidden || inputs[i].attributes[j].value.includes("hidden"); }; if(!hidden) { inputs[i].focus(); break; } }')
config.bind('V', 'spawn mpv {url}')
config.bind('M', 'hint links spawn mpv {hint-url}')
