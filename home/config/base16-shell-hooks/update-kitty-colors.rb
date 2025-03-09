#!/usr/bin/env ruby
# frozen_string_literal: true

THEME = File.read(File.join(Dir.home, '.base16_theme')).freeze

KITTY_DIR = File.join(ENV.fetch('XDG_CONFIG_HOME', nil), 'kitty').freeze

KITTY_COLORS_PATH = File.join(KITTY_DIR, 'colors.conf').freeze

DIFF_COLORS_PATH = File.join(KITTY_DIR, 'diff_colors.conf').freeze

# Represent a possibly present value
class Maybe
  def self.nothing
    new(nil)
  end

  def self.just(val)
    new(val)
  end

  def initialize(val)
    @val = val.nil? ? { kind: :nothing } : { kind: :just, val: val }
  end

  def map
    thing = just? ? yield(val[:val]) : self
    thing.is_a?(Maybe) ? thing : Maybe.new(thing)
  end

  def effect
    just? && yield(val[:val])
    self
  end

  def assign(name)
    return self unless just?
    return self.class.nothing unless val[:val].is_a?(Hash)

    yield(val[:val])
      .then { |v| v.is_a?(Maybe) ? v : Maybe.new(v) }
      .map { |ov| val[:val].merge(name => ov) }
  end

  private

  attr_reader :val

  def just?
    val[:kind] == :just
  end
end

def get_color(color)
  rgb_matches = THEME.scan(/#{color}="(.*)"/)
  if rgb_matches.empty?
    puts "Can't find color '#{color}'"
    Maybe.nothing
  else
    Maybe.just(rgb_matches.first.first.split('/').unshift('#').join)
  end
end

# Get array of integers (0-255) from hex string (#RRGGBB)
def rgb_integers(rgb_str)
  hex_pair = /[\da-f]{2}/i

  rgb_str.scan(hex_pair).map { |n| n.to_i(16) }
end

# Get hex string (#RRGGBB) from array of integers (0-255)
def rgb_string(rgb_ints)
  rgb_ints
    .map { |n| n.to_i.to_s(16) }
    .map { |c| c.length == 1 ? "0#{c}" : c }
    .unshift('#')
    .join
end

# Combine two colors with an alpha
def with_alpha(alpha, color, background)
  rgb_string(
    rgb_integers(color).zip(rgb_integers(background))
    .map { |c, b| (alpha * c) + ((1 - alpha) * b) }
    .map(&:round),
  )
end

# See https://github.com/chriskempson/base16/blob/master/styling.md
palette =
  Maybe
    .just({})
    .assign(:base00) { get_color('color00') } # black
    .assign(:base01) { get_color('color18') }
    .assign(:base02) { get_color('color19') }
    .assign(:base03) { get_color('color08') } # bright black
    .assign(:base04) { get_color('color20') }
    .assign(:base05) { get_color('color07') } # white
    .assign(:base06) { get_color('color21') }
    .assign(:base07) { get_color('color15') } # bright white
    .assign(:base08) { get_color('color01') } # red
    .assign(:base09) { get_color('color16') } # orange?
    .assign(:base0A) { get_color('color03') } # yellow
    .assign(:base0B) { get_color('color02') } # green
    .assign(:base0C) { get_color('color06') } # cyan
    .assign(:base0D) { get_color('color04') } # blue
    .assign(:base0E) { get_color('color05') } # magenta
    .assign(:base0F) { get_color('color17') } # brown?

kitty_colors = palette.map do |p|
  {
    foreground: p[:base05],
    background: p[:base00],

    selection_foreground: p[:base05],
    selection_background: p[:base02],

    color0: p[:base00], # black
    color8: p[:base03], # bright black

    color1: p[:base08], # red
    color9: p[:base08],

    color2: p[:base0B], # green
    color10: p[:base0B],

    color3: p[:base0A], # yellow
    color11: p[:base0A],

    color4: p[:base0D], # blue
    color12: p[:base0D],

    color5: p[:base0E], # magenta
    color13: p[:base0E],

    color6: p[:base0C], # cyan
    color14: p[:base0C],

    color7: p[:base05], # white
    color15: p[:base07], # bright white

    active_tab_foreground: p[:base0E],
    active_tab_background: p[:base01],
    inactive_tab_foreground: p[:base05],
    inactive_tab_background: p[:base01],

    cursor: p[:base07],
    cursor_text_color: p[:base00],

    url_color: p[:base0C],

    active_border_color: p[:base0B],
    inactive_border_color: p[:base03],
    bell_border_color: p[:base08],

    transparent_background_colors: p.values_at(:base01, :base02, :base07, :base0A).join(" "),
  }
end

kitty_diff_colors = palette.map do |p|
  {
    foreground: p[:base05],
    background: p[:base00],

    title_fg: p[:base04],
    title_bg: p[:base01],

    margin_fg: p[:base04],
    margin_bg: p[:base02],

    removed_bg: with_alpha(0.1, p[:base08], p[:base00]),
    highlight_removed_bg: with_alpha(0.2, p[:base08], p[:base00]),
    removed_margin_bg: with_alpha(0.1, p[:base08], p[:base01]),

    added_bg: with_alpha(0.1, p[:base0B], p[:base00]),
    highlight_added_bg: with_alpha(0.2, p[:base0B], p[:base00]),
    added_margin_bg: with_alpha(0.1, p[:base0B], p[:base01]),

    filler_bg: p[:base01],

    hunk_margin_bg: with_alpha(0.2, p[:base0D], p[:base00]),
    hunk_bg: with_alpha(0.2, p[:base0D], p[:base01]),

    search_fg: p[:base05],
    search_bg: p[:base02],

    select_fg: p[:base05],
    select_bg: p[:base02],
  }
end

kitty_colors.effect do |colors|
  File.open(KITTY_COLORS_PATH, 'w') do |f|
    f.puts '# Autogenerated by a base16-shell hook in'
    f.puts "# #{__FILE__}"
    colors.each { |kv| f.puts kv.join(' ') }
  end
  # `kitty @ --to unix:/tmp/mykitty set-colors --all --configured "#{KITTY_COLORS_PATH}"`
  `kitty @ --to unix:/tmp/mykitty load-config`
end

kitty_diff_colors.effect do |colors|
  File.open(DIFF_COLORS_PATH, 'w') do |f|
    f.puts '# Autogenerated by a base16-shell hook in'
    f.puts "# #{__FILE__}"
    colors.each { |kv| f.puts kv.join(' ') }
  end
end
