//! In-process wallpaper rasterizer — anti-aliased line segments onto an RGBA buffer.
//! No external rendering dependency; uses distance-to-segment for smooth edges.

use crate::palette::Palette;
use rand::Rng;

/// Display dimensions (logical for line generation, physical for raster target).
pub struct DisplayDims {
    pub logical_w: u32,
    pub logical_h: u32,
    pub physical_w: u32,
    pub physical_h: u32,
}

/// Render 5000 anti-aliased line segments into an RGBA8 buffer (w*h*4 bytes).
/// Lines are generated in logical coordinate space and scaled to physical resolution.
pub fn render_wallpaper(dims: &DisplayDims, palette: &Palette) -> Vec<u8> {
    let w = dims.physical_w as usize;
    let h = dims.physical_h as usize;
    let scale = dims.physical_w as f64 / dims.logical_w.max(1) as f64;

    // Opaque black background
    let mut buf = vec![0u8; w * h * 4];
    for i in (3..buf.len()).step_by(4) {
        buf[i] = 255;
    }

    let lw = dims.logical_w as f64;
    let lh = dims.logical_h as f64;

    // Pre-parse palette colors
    let white = parse_hex(&palette.white);
    let warm = [parse_hex(&palette.red), parse_hex(&palette.magenta), parse_hex(&palette.yellow)];
    let cool = [parse_hex(&palette.blue), parse_hex(&palette.green), parse_hex(&palette.cyan)];

    for _ in 0..5000 {
        // --- Seed position (same distribution as Ruby) ---
        let x_val: f64 = rand::random::<f64>() * lw;
        let y_val: f64 = rand::random::<f64>() * rand::random::<f64>() * lh;

        // --- Color selection (exact port of Ruby color()) ---
        let (r, g, b) = if rand::random::<f64>() < 0.05 {
            white
        } else {
            let scaled_x = -15.0 * ((x_val / lw) - 0.5);
            let sigmoid_x = 1.0 / (1.0 + (-scaled_x).exp());
            if sigmoid_x < rand::random::<f64>() {
                warm[rand::rng().random_range(0..3)]
            } else {
                cool[rand::rng().random_range(0..3)]
            }
        };

        // --- Line endpoints (same math as Ruby) ---
        let sa: f64 = -1.1;
        let l0 = 50.0 + rand::random::<f64>();
        let l1 = 50.0 + rand::random::<f64>();

        let x1 = (x_val + l0 * sa.cos()) * scale;
        let y1 = (y_val + l0 * sa.sin()) * scale;
        let x2 = (x_val + l1 * (sa + std::f64::consts::PI).cos()) * scale;
        let y2 = (y_val + l1 * (sa + std::f64::consts::PI).sin()) * scale;

        // --- Stroke width (same formula, scaled to physical) ---
        let sw = ((0.7 * (lh - y_val)) / lh + 1.3) * scale;

        draw_aa_line(&mut buf, w, h, x1, y1, x2, y2, sw, r, g, b);
    }

    buf
}

/// Draw a single anti-aliased line segment using distance-to-segment.
/// `buf` is a flat RGBA8 buffer of size `w * h * 4`.
fn draw_aa_line(
    buf: &mut [u8],
    w: usize,
    h: usize,
    x1: f64,
    y1: f64,
    x2: f64,
    y2: f64,
    stroke_width: f64,
    r: u8,
    g: u8,
    b: u8,
) {
    let half_sw = stroke_width * 0.5;

    // Bounding box expanded by half stroke + 1px AA margin
    let min_x = ((x1.min(x2) - half_sw - 1.0).max(0.0)) as i32;
    let max_x = ((x1.max(x2) + half_sw + 1.0).min(w as f64 - 1.0)) as i32;
    let min_y = ((y1.min(y2) - half_sw - 1.0).max(0.0)) as i32;
    let max_y = ((y1.max(y2) + half_sw + 1.0).min(h as f64 - 1.0)) as i32;

    if min_x > max_x || min_y > max_y {
        return;
    }

    let dx = x2 - x1;
    let dy = y2 - y1;
    let len_sq = dx * dx + dy * dy;
    if len_sq < 1e-10 {
        return;
    }

    let r_f = r as f32;
    let g_f = g as f32;
    let b_f = b as f32;

    for py in min_y..=max_y {
        let py_f = py as f64 + 0.5;
        let row_offset = (py as usize) * w * 4;
        for px in min_x..=max_x {
            let px_f = px as f64 + 0.5;

            // Project point onto segment, clamp to [0,1]
            let t = ((px_f - x1) * dx + (py_f - y1) * dy) / len_sq;
            let tc = t.clamp(0.0, 1.0);
            let cx = x1 + tc * dx;
            let cy = y1 + tc * dy;
            let dist = ((px_f - cx).powi(2) + (py_f - cy).powi(2)).sqrt();

            // Anti-aliased coverage: 1px smooth falloff at the edge
            let coverage = (half_sw + 0.5 - dist).clamp(0.0, 1.0) as f32;
            if coverage > 0.0 {
                let idx = row_offset + (px as usize) * 4;
                let inv = 1.0 - coverage;
                buf[idx] = (buf[idx] as f32 * inv + r_f * coverage) as u8;
                buf[idx + 1] = (buf[idx + 1] as f32 * inv + g_f * coverage) as u8;
                buf[idx + 2] = (buf[idx + 2] as f32 * inv + b_f * coverage) as u8;
            }
        }
    }
}

/// Parse a "#rrggbb" hex string into (r, g, b) u8 tuple.
fn parse_hex(s: &str) -> (u8, u8, u8) {
    let s = s.trim_start_matches('#');
    let r = u8::from_str_radix(&s[0..2], 16).unwrap_or(0);
    let g = u8::from_str_radix(&s[2..4], 16).unwrap_or(0);
    let b = u8::from_str_radix(&s[4..6], 16).unwrap_or(0);
    (r, g, b)
}
