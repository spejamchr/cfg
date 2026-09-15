//! SVG wallpaper generation — high-speed line-stroke rendering.
//! Writes directly into a pre-allocated Vec<u8> buffer (no string interpolation per line).

use crate::palette::Palette;
use rand::Rng;
use std::io::Write;

/// Generate the full SVG content for one display into a Vec<u8>.
/// Matches Ruby build_svg + build_svg_strokes exactly in output format.
pub fn build_svg(dims: &DisplayDims, palette: &Palette) -> Vec<u8> {
    // Pre-allocate ~160 bytes per line element + header/footer overhead
    let estimated = (5000usize * 160).saturating_mul(
        (dims.logical_w as f64 / dims.logical_h.max(1) as f64)
            .max(0.5)
            .min(2.0)
            .round() as usize,
    ) + 600;
    let mut buf = Vec::with_capacity(estimated);

    // SVG header
    write!(buf, "<svg viewBox=\"0 0 {lw} {lh}\" width=\"{lw}\" height=\"{lh}\" xmlns=\"http://www.w3.org/2000/svg\">",
        lw = dims.logical_w, lh = dims.logical_h).ok();

    // Background rect (always black)
    write!(
        buf,
        "<rect width=\"100%\" height=\"100%\" fill=\"{}\" />",
        palette.black
    )
    .ok();

    // Group open
    write!(
        buf,
        "<g stroke-width=\"2\" stroke-linecap=\"round\" fill=\"none\">"
    )
    .ok();

    let logical_w = dims.logical_w as f64;
    let logical_h = dims.logical_h as f64;

    for _ in 0..5000 {
        // --- Generate seed (same distribution as Ruby: rand*width, rand*rand*height) ---
        let x_val: f64 = rand::random::<f64>() * logical_w;
        let y_val: f64 = rand::random::<f64>() * rand::random::<f64>() * logical_h;

        // --- Color selection (exact port of Ruby color() function) ---
        let warm_colors = [&palette.red, &palette.magenta, &palette.yellow];
        let cool_colors = [&palette.blue, &palette.green, &palette.cyan];

        // NEUTRAL_COLORS.sample with 5% probability
        let stroke_color = if rand::random::<f64>() < 0.05 {
            &palette.white
        } else {
            let scaled_x = -15.0 * ((x_val / logical_w) - 0.5);
            let sigmoid_x = 1.0 / (1.0 + (-scaled_x).exp());

            if sigmoid_x < rand::random::<f64>() {
                &warm_colors[rand::rng().random_range(0..3)] // warm color sample
            } else {
                &cool_colors[rand::rng().random_range(0..3)] // cool color sample
            }
        };

        // --- Line coordinates (same math as Ruby) ---
        let sa: f64 = -1.1; // radians
        let l0 = 50.0 + rand::random::<f64>() * 1.0; // [50, 51)
        let l1 = 50.0 + rand::random::<f64>() * 1.0; // [50, 51)

        let x1 = x_val + l0 * sa.cos();
        let y1 = y_val + l0 * sa.sin();
        let x2 = x_val + l1 * (sa + std::f64::consts::PI).cos();
        let y2 = y_val + l1 * (sa + std::f64::consts::PI).sin();

        // --- Stroke width (same formula as Ruby, rounded to 5 decimal places) ---
        let sw_raw = ((0.7 * (logical_h - y_val)) / logical_h) + 1.3;
        let sw_str = format_round(sw_raw);

        // Write single-line line element
        write!(
            buf,
            "<line stroke-width=\"{}\" x1=\"{}\" y1=\"{}\" x2=\"{}\" y2=\"{}\" stroke=\"{}\" />",
            sw_str,
            format_dec(x1),
            format_dec(y1),
            format_dec(x2),
            format_dec(y2),
            stroke_color
        )
        .ok();
    }

    // Group close + SVG close
    write!(buf, "</g></svg>").ok();
    buf
}

/// Struct carrying display dimensions for SVG generation.
pub struct DisplayDims {
    pub logical_w: u32,
    pub logical_h: u32,
}

/// Round to 5 decimal places and format without trailing zeros.
fn format_dec(v: f64) -> String {
    let r = (v * 1e5).round() / 1e5;
    if r.fract() == 0.0 {
        format!("{:.0}", r)
    } else {
        let s = format!("{:.5}", r);
        let stripped = s.trim_end_matches('0');
        stripped.trim_end_matches('.').to_string()
    }
}

fn format_round(v: f64) -> String {
    format_dec(v)
}
