#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'json'
require_relative "utilities"

NOW = Time.now.strftime("%Y%m%d%H%M%S").freeze

WALLPAPER_DIR = File.join(Dir.home, "Pictures", "GeneratedWallpapers").freeze
FileUtils.mkdir_p WALLPAPER_DIR

class Display
  attr_reader :index, :x, :y, :w, :h

  def initialize(display_hash)
    @index = display_hash.fetch("index")

    frame = display_hash.fetch("frame")
    @x = frame.fetch("x")
    @y = frame.fetch("y")
    @w = frame.fetch("w")
    @h = frame.fetch("h")
  end
end

DISPLAYS = JSON.parse(`yabai -m query --displays 2>/dev/null || printf '[]'`)
  .map { |h| Display.new(h) }
  .freeze

SEEDS = 5000

PALETTE = build_palette.freeze

NEUTRAL_COLORS = [PALETTE.fetch(:white), PALETTE.fetch(:bright_black)].freeze
WARM_COLORS = [PALETTE.fetch(:red), PALETTE.fetch(:magenta), PALETTE.fetch(:yellow)].freeze
COOL_COLORS = [PALETTE.fetch(:blue), PALETTE.fetch(:green), PALETTE.fetch(:cyan)].freeze

def gen_seeds(min_x, max_x, min_y, max_y)
  sx = max_x - min_x
  sy = max_y - min_y

  SEEDS.times.map do
    {
      x: (rand * sx) + min_x,
      y: (rand * rand * sy) + min_y,
      a: -1.1,
      l: [50, 50],
    }
  end
end

# @param display [Display]
# @param x [Numeric]
def color(display, x)
  return NEUTRAL_COLORS.sample if rand < 0.05

  scaled_x = -15 * (((x - display.x) / (display.w - display.x)) - 0.5)
  sigmoid_x = 1 / (1 + Math.exp(scaled_x))

  if sigmoid_x < rand
    WARM_COLORS.sample
  else
    COOL_COLORS.sample
  end
end

def round(n)
  n.round(5)
end

# @param display [Display]
# @return [Array<String>]
def build_svg_strokes(display) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  x = display.x
  y = display.y
  w = display.w
  h = display.h

  gen_seeds(x, w, y, h).map do |s|
    sa = s.fetch(:a)
    sl = s.fetch(:l)
    sx = s.fetch(:x)
    sy = s.fetch(:y)

    <<~HTML
      <line
        stroke-width="#{round(((0.7 * (h - sy)) / h) + 1.3)}"
        x1="#{round(sx + (sl[0] * Math.cos(sa)))}"
        y1="#{round(sy + (sl[0] * Math.sin(sa)))}"
        x2="#{round(sx + (sl[1] * Math.cos(sa + Math::PI)))}"
        y2="#{round(sy + (sl[1] * Math.sin(sa + Math::PI)))}"
        stroke="#{color(display, sx)}"
      />
    HTML
  end
end

# @param display [Display]
def build_svg(display) # rubocop:disable Metrics/MethodLength
  x = display.x
  y = display.y
  w = display.w
  h = display.h

  <<~HTML.gsub("\n", "").squeeze(" ")
    <svg
      viewBox="#{x.to_i} #{y.to_i} #{w.to_i} #{h.to_i}"
      width="#{w.to_i}"
      height="#{h.to_i}"
      xmlns="http://www.w3.org/2000/svg"
    >
      <rect width="100%" height="100%" fill="#{PALETTE.fetch(:black)}" />
      <g stroke-width="2" stroke-linecap="round" fill="none">
        #{build_svg_strokes(display).join}
      </g>
    </svg>
  HTML
end

# @param display [Display]
def svg_path(display)
  File.join(WALLPAPER_DIR, "generated-#{display.index}-#{NOW}.svg")
end

# @param display [Display]
def png_path(display)
  File.join(WALLPAPER_DIR, "generated-#{display.index}-#{NOW}.png")
end

# @param display [Display]
DISPLAYS.each do |display|
  svg = build_svg(display)

  File.write(svg_path(display), svg)

  system(
    "svg2png",
    "-w",
    (display.w.to_i * 2).to_s,
    "-h",
    (display.h.to_i * 2).to_s,
    svg_path(display),
    png_path(display),
  )

  script = <<~APPLESCRIPT
    tell application "System Events"
    set picture of desktop #{display.index} to POSIX file "#{png_path(display)}"
    end tell
  APPLESCRIPT

  system('osascript', '-e', script)
end

new_wallpaper_paths = DISPLAYS.map { |d| png_path(d) }

Dir.glob(File.join(WALLPAPER_DIR, 'generated-*')).each do |file|
  File.delete(file) unless new_wallpaper_paths.include?(file)
end
