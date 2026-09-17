# Wallboard

Build a wallpaper with a dynamic color scheme.

## Recommended restructure: draw pixels directly in Rust

Replace the SVG + `rsvg-convert` step with an in-process rasterizer. You only need to draw 5 000 anti-aliased line segments onto an RGBA buffer, then encode PNG. Two practical options:

### Option A – `png` crate + manual line rasterization (fastest)

```rust
// Cargo.toml
// [dependencies]
// png = "0.17"
// rand = "0.8"

use png::{Encoder, ColorType, CompressionType, FilterType};
use std::io::BufWriter;

/// Draw a single anti-aliased line segment onto an RGBA buffer.
/// Uses 4×4 supersampling per pixel for smooth edges.
fn draw_line_aa(
    buf: &mut [u8],
    w: usize,
    h: usize,
    x1: f64, y1: f64, x2: f64, y2: f64,
    r: u8, g: u8, b: u8,
    stroke_width: f64,
) {
    // Bounding box (clamped)
    let min_x = (x1.min(x2) - stroke_width).max(0.0) as usize;
    let max_x = (x1.max(x2) + stroke_width).min(w as f64 - 1.0) as usize;
    let min_y = (y1.min(y2) - stroke_width).max(0.0) as usize;
    let max_y = (y1.max(y2) + stroke_width).min(h as f64 - 1.0) as usize;

    const SS: usize = 4; // supersample factor

    for py in min_y..=max_y {
        for px in min_x..=max_x {
            let mut coverage: f64 = 0.0;
            for sy in 0..SS {
                for sx in 0..SS {
                    let sample_x = (px as f64 + (sx + 0.5) as f64 / SS as f64);
                    let sample_y = (py as f64 + (sy + 0.5) as f64 / SS as f64);
                    // Distance from point to line segment
                    let d = point_to_segment_dist(sample_x, sample_y, x1, y1, x2, y2);
                    if d < stroke_width * 0.5 {
                        coverage += 1.0;
                    }
                }
            }
            let alpha = (coverage / (SS * SS) as f64).min(1.0);
            if alpha > 0.0 {
                let idx = (py * w + px) * 4;
                // Alpha-blend onto existing pixel
                let inv = 1.0 - alpha;
                buf[idx]     = (r as f64 * alpha + buf[idx]     as f64 * inv) as u8;
                buf[idx + 1] = (g as f64 * alpha + buf[idx + 1] as f64 * inv) as u8;
                buf[idx + 2] = (b as f64 * alpha + buf[idx + 2] as f64 * inv) as u8;
            }
        }
    }
}

fn point_to_segment_dist(px: f64, py: f64, x1: f64, y1: f64, x2: f64, y2: f64) -> f64 {
    let dx = x2 - x1;
    let dy = y2 - y1;
    let len_sq = dx * dx + dy * dy;
    if len_sq == 0.0 { return ((px - x1).powi(2) + (py - y1).powi(2)).sqrt(); }
    let t = ((px - x1) * dx + (py - y1) * dy) / len_sq;
    let t_clamped = t.clamp(0.0, 1.0);
    let cx = x1 + t_clamped * dx;
    let cy = y1 + t_clamped * dy;
    ((px - cx).powi(2) + (py - cy).powi(2)).sqrt()
}

/// Generate the full wallpaper as a PNG file (no SVG, no rsvg-convert).
fn render_wallpaper_png(
    path: &std::path::Path,
    w: u32,
    h: u32,
    palette: &Palette,
) -> std::io::Result<()> {
    let w = w as usize;
    let h = h as usize;
    let mut buf = vec![0u8, (w * h * 4)]; // black background

    // … same 5000-iteration loop as your SVG gen, but call draw_line_aa …

    let file = std::fs::File::create(path)?;
    let wtr = BufWriter::new(file);
    let mut encoder = Encoder::new(wtr, w as u32, h as u32);
    encoder.set_color(ColorType::Rgba);
    encoder.set_compression(CompressionType::Fast); // level 1, much faster than default
    encoder.set_filter(FilterType::None);
    let mut writer = encoder.write_header()?;
    writer.write_image_data(&buf)?;
    Ok(())
}
```

**Why this is faster:**

| Step              | Current (SVG → rsvg-convert)               | Direct raster                     |
| ----------------- | ------------------------------------------ | --------------------------------- |
| Process spawn     | 1 fork+exec                                | 0                                 |
| XML parse         | ~5000 elements                             | none                              |
| Rasterizer        | general-purpose (paths, fills, transforms) | 5000 line-segment distance checks |
| PNG encode        | inside rsvg-convert (C, libpng)            | in-process Rust `png` crate       |
| **Typical total** | **2–5 s**                                  | **~150–400 ms**                   |

The 4×4 supersampling gives you the same anti-aliased look as rsvg-convert's default. If you want it even faster, drop to 2×2 (still looks fine for a wallpaper viewed at arm's length).

## Other quick wins regardless of which option you pick

1. **`system_profiler` is slow (1–3 s).** You only need it for the physical-resolution lookup, which doesn't change for a physical display. Cache the result to a small JSON file; re-fetch only if a display cannot be found by name within the JSON file.

2. **PNG compression level.** `rsvg-convert` uses libpng's default (level 6). For a wallpaper that's immediately loaded into GPU memory, use level 1 (`CompressionType::Fast`) or even 0. You save 50–100 ms of encoding with a file that's a few MB larger (irrelevant).

3. **Parallelize across displays** (if you have 2+). The per-display work is independent. Use `std::thread::scope` or `rayon` to render both PNGs concurrently.

4. **Skip the SVG file entirely.** You no longer need to write a `.svg` to disk. This also simplifies your cleanup logic (no `.svg` files to delete).
