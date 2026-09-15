//! Color palette sourced from `TINTY_SCHEME_PALETTE_BASE{idx}_{HEX_}{R|G|B}` env vars.
//! Matches utilities.rb hex_rgb/get_color exactly, with fallback to random values.

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
        let hex_for = |idx: u8, ch: &str| -> String {
            // Try both possible env var formats
            let val = std::env::var(&format!("TINTY_SCHEME_PALETTE_BASE{:02}_HEX_{}", idx, ch))
                .or_else(|_| std::env::var(&format!("TINTY_SCHEME_PALETTE_BASE{:02}{}", idx, ch)));

            val.ok()
                .and_then(|v| u8::from_str_radix(&v, 16).ok())
                .map(|b| format!("#{b:02x}"))
                .unwrap_or_else(|| {
                    // Ruby fallback: (rand * 255).round.to_s(16)
                    let n = rand::random::<u8>();
                    format!("#{n:02x}")
                })
        };

        let black      = hex_for(0, "R") + &hex_for(0, "G")[1..] + &hex_for(0, "B")[1..];
        let bright_black = hex_for(3, "R") + &hex_for(3, "G")[1..] + &hex_for(3, "B")[1..];
        let white      = hex_for(5, "R") + &hex_for(5, "G")[1..] + &hex_for(5, "B")[1..];
        let red        = hex_for(8, "R") + &hex_for(8, "G")[1..] + &hex_for(8, "B")[1..];
        let magenta    = hex_for(14, "R") + &hex_for(14, "G")[1..] + &hex_for(14, "B")[1..];
        let yellow     = hex_for(10, "R") + &hex_for(10, "G")[1..] + &hex_for(10, "B")[1..];
        let blue       = hex_for(13, "R") + &hex_for(13, "G")[1..] + &hex_for(13, "B")[1..];
        let green      = hex_for(11, "R") + &hex_for(11, "G")[1..] + &hex_for(11, "B")[1..];
        let cyan       = hex_for(12, "R") + &hex_for(12, "G")[1..] + &hex_for(12, "B")[1..];

        Self { black, white, bright_black, red, magenta, yellow, blue, green, cyan }
    }
}
