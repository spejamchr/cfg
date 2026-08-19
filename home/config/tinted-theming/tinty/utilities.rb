# frozen_string_literal: true

# @param color [String] A two-digit string identifying a BASEXX color
# @return [String] 2-character Hex string of a color
def hex_rgb(color, rgb)
  ENV.fetch("TINTY_SCHEME_PALETTE_BASE#{color}_HEX_#{rgb}",
            (rand * 255).round.to_s(16))
end

# @param color [String] A two-digit string identifying a BASEXX color
# @return [String] Hex string of a color
def get_color(color)
  hex = ["R", "G", "B"].map { |rgb| hex_rgb(color, rgb) }.join
  "##{hex}"
end

# Get array of integers (0-255) from hex string (#RRGGBB)
# @param rgb_str [String] color in Hex string format
# @return [[Integer, Integer, Integer]] Array of RGB integers (0-255)
def rgb_integers(rgb_str)
  hex_pair = /[\da-f]{2}/i

  rgb_str.scan(hex_pair).map { |n| n.to_i(16) }
end

# Get hex string (#RRGGBB) from array of integers (0-255)
# @param rgb_ints [[Integer, Integer, Integer]] Array of RGB integers (0-255)
# @return [String] color in Hex string format
def rgb_string(rgb_ints)
  rgb_ints
    .map { |n| n.to_i.to_s(16) }
    .map { |c| c.length == 1 ? "0#{c}" : c }
    .unshift('#')
    .join
end

# Combine two colors with an alpha
# @param alpha [Float]
# @param color [String] color in Hex string format
# @param background [String] color in Hex string format
# @return [String] color in Hex string format
def with_alpha(alpha, color, background)
  rgb_string(
    rgb_integers(color).zip(rgb_integers(background))
    .map { |c, b| (alpha * c) + ((1 - alpha) * b) }
    .map(&:round),
  )
end

# @return [{base00: String}]
def build_palette # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  {
    black: get_color("00"),
    base00: get_color("00"),

    darkest_gray: get_color("01"),
    base01: get_color("01"),

    dark_gray: get_color("02"),
    base02: get_color("02"),

    bright_black: get_color("03"),
    base03: get_color("03"),

    light_gray: get_color("04"),
    base04: get_color("04"),

    white: get_color("05"),
    base05: get_color("05"),

    lighter_white: get_color("06"),
    base06: get_color("06"),

    bright_white: get_color("07"),
    base07: get_color("07"),

    red: get_color("08"),
    base08: get_color("08"),

    orange: get_color("09"),
    base09: get_color("09"),

    yellow: get_color("0A"),
    base0A: get_color("0A"),

    green: get_color("0B"),
    base0B: get_color("0B"),

    cyan: get_color("0C"),
    base0C: get_color("0C"),

    blue: get_color("0D"),
    base0D: get_color("0D"),

    magenta: get_color("0E"),
    base0E: get_color("0E"),

    brown: get_color("0F"),
    base0F: get_color("0F"),
  }
end
