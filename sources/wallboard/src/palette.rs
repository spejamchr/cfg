//! Color palette sourced from `TINTY_SCHEME_PALETTE_BASE{idx}_HEX_{R|G|B}` env vars.

pub struct Palette {
    pub black: String,
    pub white: String,
    pub bright_black: String,
    pub red: String,
    pub magenta: String,
    pub yellow: String,
    pub blue: String,
    pub green: String,
    pub cyan: String,
}

impl Palette {
    /// Build palette matching Ruby utilities.rb exactly.
    /// Tries TINTY_SCHEME_PALETTE_BASE{idx}_HEX_{R|G|B} first (matching Ruby's env key).
    /// Falls back to random values when not set.
    pub fn build() -> Self {
        let hex_for = |color: &str, ch: &str| -> String {
            let a = format!("TINTY_SCHEME_PALETTE_BASE{}_HEX_{}", color, ch);

            std::env::var(&a).ok().unwrap_or_else(|| {
                // Ruby fallback: (rand * 255).round.to_s(16)
                eprintln!("Unable to find tinty color at {}", a);
                let n = rand::random::<u8>();
                format!("{n:02x}")
            })
        };

        let get_color = |color: &str| -> String {
            hex_for(color, "R") + &hex_for(color, "G") + &hex_for(color, "B")
        };

        let black = get_color("00");
        let bright_black = get_color("03");
        let white = get_color("05");
        let red = get_color("08");
        let magenta = get_color("0E");
        let yellow = get_color("0A");
        let blue = get_color("0D");
        let green = get_color("0B");
        let cyan = get_color("0C");

        Self {
            black,
            white,
            bright_black,
            red,
            magenta,
            yellow,
            blue,
            green,
            cyan,
        }
    }
}
