#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'json'
require_relative "utilities"

NOW = Time.now.strftime("%Y%m%d%H%M%S").freeze

WALLPAPER_DIR = File.join(Dir.home, "Pictures", "GeneratedWallpapers").freeze
FileUtils.mkdir_p WALLPAPER_DIR

# ---------------------------------------------------------------------------
# Display info helpers
# ---------------------------------------------------------------------------

def yabai_displays
  JSON.parse(`yabai -m query --displays 2>/dev/null || printf '[]'`)
end

def kitty_output_names
  JSON.parse(`kitty +kitten panel --output-name=listjson 2>/dev/null`)
    .map { |h| h.fetch("name") }
rescue StandardError
  []
end

# Parse system_profiler SPDisplaysDataType output to map display names → physical resolutions.
# Output format (simplified):
#       Displays:
#         Color LCD:
#           Display Type: Built-in Liquid Retina XDR Display
#           Resolution: 3456 x 2234 Retina
#   or:
#         LG UltraFine:
#           Display Type: LG UltraFine
#           Resolution: 3840 x 2160
def physical_resolutions_map
  raw = `system_profiler SPDisplaysDataType 2>/dev/null`
  map = {}

  # Split into GPU entries by the "Chipset Model:" line (starts at column 5)
  entries = raw.split(/^      Chipset Model:/m)

  entries.each do |entry|
    # Look for display name lines: "        <name>:" (8-space indent, no colon in name)
    entry.lines.each_with_index do |line, idx|
      next unless line =~ /^        ([^:\n]+):$/

      sp_display_name = Regexp.last_match(1).strip
      next unless sp_display_name !~ /^(Graphics|Display Type|Chipset|Vendor|Type:|Bus|Total|Metal)/

      next unless sp_display_name

      # Check if this display has a Resolution line in the next 5 lines
      next_lines = entry.lines[idx..idx+5].join("\n")
      res_match = next_lines.match(/^          Resolution:\s*(\d+)\s*x\s*(\d+)/m)
      next unless res_match

      map[sp_display_name] = [Regexp.last_match(1).to_i, Regexp.last_match(2).to_i]
    end
  end

  map
end

PHYSICAL_RESOLUTIONS_MAP = physical_resolutions_map.freeze

# Build a Display object for each Kitty output name.
class Display
  attr_reader :name, :logical_w, :logical_h, :physical_w, :physical_h,
              :scale_factor, :kitty_socket

  def initialize(name, logical_w, logical_h)
    @name        = name
    @logical_w   = logical_w
    @logical_h   = logical_h
    @physical_w  = 0
    @physical_h  = 0
    resolve_physical_resolution
    compute_socket
  end

  private

  def resolve_physical_resolution
    sp_map = PHYSICAL_RESOLUTIONS_MAP
    return if sp_map.empty?

    matched_key = nil

    # Strategy 1: Direct substring match between Kitty output name and system_profiler display name.
    sp_map.keys.each do |sp_name|
      next if matched_key

      matched_key = sp_name if @name.include?(sp_name) || sp_name.include?(@name)
    end

    # Strategy 2: If no direct match, use heuristic matching.
    # "Retina" in the Kitty name → likely the built-in display (Color LCD in system_profiler).
    if matched_key.nil? && @name =~ /retina|liquid/i
      sp_map.each do |sp_name, _|
        next unless sp_name =~ /LCD|Color/i
        # Verify it's actually a built-in display by checking "Connection Type: Internal" in SP output
        next unless `system_profiler SPDisplaysDataType 2>/dev/null`.include?("Internal")

        matched_key = sp_name
        break
      end
    end

    # Strategy 3: If still no match, assume this is an external display with 1× scale.
    if matched_key.nil?
      @physical_w = @logical_w
      @physical_h = @logical_h
      return
    end

    @physical_w, @physical_h = sp_map[matched_key]
  end

  def compute_socket
    slugified = @name.gsub(/[^a-zA-Z0-9_]/, '_')
    @kitty_socket = "unix:/tmp/mykittywallboard_#{slugified}"
  end

  public

  def scale_factor
    return 1.0 unless physical_w.positive? && logical_w.positive?

    (physical_w.to_f / logical_w).round(2)
  end
end

# ---------------------------------------------------------------------------
# Main logic
# ---------------------------------------------------------------------------

yabai_data = yabai_displays
kitty_names = kitty_output_names

DISPLAYS = []
kitty_names.each_with_index do |kname, idx|
  # Find corresponding yabai display data. Match by:
  #   - label substring match, OR
  #   - positional index (most common case)
  yabai_entry = yabai_data.find do |yd|
    yd["label"] && (yd["label"].include?(kname) || kname.include?(yd["label"]))
  end || yabai_data[idx]

  if yabai_entry
    frame = yabai_entry.fetch("frame")
    display = Display.new(kname, frame.fetch("w").to_i, frame.fetch("h").to_i)
  else
    puts Time.now.to_s + " | WARNING: No yabai data for Kitty output '#{kname}'"
    display = Display.new(kname, 1920, 1080)
  end

  DISPLAYS << display
end

SEEDS = 5000

PALETTE = build_palette.freeze

NEUTRAL_COLORS = [PALETTE.fetch(:white), PALETTE.fetch(:bright_black)].freeze
WARM_COLORS    = [PALETTE.fetch(:red), PALETTE.fetch(:magenta), PALETTE.fetch(:yellow)].freeze
COOL_COLORS    = [PALETTE.fetch(:blue), PALETTE.fetch(:green), PALETTE.fetch(:cyan)].freeze

def gen_seeds(width, height)
  SEEDS.times.map do
    { x: rand * width, y: rand * rand * height, a: -1.1, l: [50, 50] }
  end
end

def color(display, x)
  return NEUTRAL_COLORS.sample if rand < 0.05

  scaled_x = -15 * ((x / display.logical_w) - 0.5)
  sigmoid_x = 1 / (1 + Math.exp(scaled_x))

  if sigmoid_x < rand
    WARM_COLORS.sample
  else
    COOL_COLORS.sample
  end
end

def round(n) = n.round(5)

def build_svg_strokes(display) # rubocop:disable Metrics/MethodLength
  w = display.logical_w
  h = display.logical_h

  gen_seeds(w, h).map do |s|
    sa = s.fetch(:a)
    sl = s.fetch(:l)
    sx = s.fetch(:x)
    sy = s.fetch(:y)
    <<~HTML
      <line stroke-width="#{round(((0.7 * (h - sy)) / h) + 1.3)}"
        x1="#{round(sx + (sl[0] * Math.cos(sa)))}" y1="#{round(sy + (sl[0] * Math.sin(sa)))}"
        x2="#{round(sx + (sl[1] * Math.cos(sa + Math::PI)))}" y2="#{round(sy + (sl[1] * Math.sin(sa + Math::PI)))}"
        stroke="#{color(display, sx)}" />
    HTML
  end
end

def build_svg(display)
  w = display.logical_w
  h = display.logical_h
  <<~HTML.gsub("\n", "").squeeze(" ")
    <svg viewBox="0 0 #{w.to_i} #{h.to_i}" width="#{w.to_i}" height="#{h.to_i}"
      xmlns="http://www.w3.org/2000/svg">
      <rect width="100%" height="100%" fill="#{PALETTE.fetch(:black)}" />
      <g stroke-width="2" stroke-linecap="round" fill="none">#{build_svg_strokes(display).join}</g>
    </svg>
  HTML
end

def file_key(display)
  display.name.gsub(/[^a-zA-Z0-9_]/, '_')
end

def svg_path(display) = File.join(WALLPAPER_DIR, "generated-#{file_key(display)}-#{NOW}.svg")
def png_path(display) = File.join(WALLPAPER_DIR, "generated-#{file_key(display)}-#{NOW}.png")

# Process each display
DISPLAYS.each do |display|
  svg = build_svg(display)
  File.write(svg_path(display), svg)

  # Render SVG at physical pixel dimensions for the HiDPI image.
  system(
    "rsvg-convert", "-w", display.physical_w.to_s,
    "-h", display.physical_h.to_s, svg_path(display), "-o", png_path(display)
  )

  # Update the kitty panel on this display via its dedicated socket.
  success = system(
    "kitty", "@", "--to", display.kitty_socket,
    "set-background-image", "--layout=cscaled", png_path(display)
  )

  logical_display_msg = "#{display.logical_w}×#{display.logical_h}"
  physical_display_msg = "#{display.physical_w}×#{display.physical_h}"
  scale_msg = "scale: #{display.scale_factor}"
  display_msg = "#{logical_display_msg} → #{physical_display_msg}, #{scale_msg}"
  status_msg = success ? "." : " [kitty update FAILED]"

  puts Time.now.to_s + " | Wallpaper for #{display.name} (#{display_msg})" + status_msg
end

# Clean up old wallpaper files — only keep ones we just generated.
new_paths = DISPLAYS.map { |d| png_path(d) }
Dir.glob(File.join(WALLPAPER_DIR, 'generated-*')).each do |file|
  File.delete(file) unless new_paths.include?(file)
end
