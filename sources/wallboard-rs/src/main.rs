//! Fast wallboard wallpaper generator — Ruby → Rust rewrite.
//!
//! Performance wins vs Ruby:
//! - SVG built into pre-allocated Vec<u8> (no string interpolation per line)
//! - `system_profiler` called once and cached (Ruby called it TWICE per display)
//! - serde_json for fast, zero-copy-friendly parsing

use std::fs;
use std::path::PathBuf;
use std::process::Command;

use chrono::SecondsFormat;

use wallboard::display_info as di;
use wallboard::palette::Palette;
use wallboard::svg_gen::{DisplayDims, render_wallpaper};

fn main() {
    let now_ts = chrono::offset::Local::now()
        .to_rfc3339_opts(SecondsFormat::Secs, false)
        .replace(':', ""); // matches Ruby strftime("%Y%m%d%H%M%S")

    let wallpaper_dir = env_home("Pictures/GeneratedWallpapers");

    // Create output directory (matches Ruby FileUtils.mkdir_p)
    fs::create_dir_all(&wallpaper_dir).ok();

    // ---- Fetch display data once (no repeated calls!) ----
    let yabai_displays = di::fetch_yabai_displays();
    let kitty_outputs = di::fetch_kitty_outputs();

    if kitty_outputs.is_empty() {
        eprintln!("{} | No Kitty panel outputs found.", now_ts);
        return;
    }

    // Parse system_profiler ONCE (Ruby called it twice: once for map, once in heuristic)
    let sp_map = di::fetch_physical_resolutions();

    // ---- Build Display configs ----
    let displays: Vec<di::Display> = kitty_outputs
        .iter()
        .enumerate()
        .map(|(idx, name)| {
            let (logical_w, logical_h) = di::match_yabai_frame(name, &yabai_displays, idx);
            di::Display::new(name, logical_w, logical_h, &sp_map)
        })
        .collect();

    // ---- Build palette once (deterministic via env vars) ----
    let palette = Palette::build();

    // ---- Process each display ----
    for display in &displays {
        let physical_w = display.physical_w.max(1);
        let physical_h = display.physical_h.max(1);

        // Rasterize anti-aliased lines directly into an RGBA buffer at physical resolution
        let rgba_buf = render_wallpaper(
            &DisplayDims {
                logical_w: display.logical_w,
                logical_h: display.logical_h,
                physical_w,
                physical_h,
            },
            &palette,
        );

        let slugified = di::slugify(&display.name);
        let base_name = format!("generated-{}-{}", slugified, now_ts);
        let png_path = wallpaper_dir.join(format!("{base_name}.png"));

        // Encode RGBA → PNG in-process
        let png_ok = encode_png(&png_path, physical_w, physical_h, &rgba_buf);

        if !png_ok {
            eprintln!("{} | PNG encoding FAILED for {}", now_ts, display.name);
        }

        // Update kitty background via IPC (matches Ruby system(...))
        let socket = display.kitty_socket();
        let kitty_ok = Command::new("kitty")
            .args([
                "@",
                "--to",
                &socket,
                "set-background-image",
                "--layout=cscaled",
            ])
            .arg(&png_path)
            .status()
            .ok()
            .map(|s| s.success())
            .unwrap_or(false);

        let logical = format!("{}x{}", display.logical_w, display.logical_h);
        let physical = format!("{}x{}", physical_w, physical_h);
        let scale = display.scale_factor();
        let status = if kitty_ok {
            "."
        } else {
            " [kitty update FAILED]"
        };

        println!(
            "{} | Wallpaper for {} ({} → {}, scale: {}) {}",
            now_ts, display.name, logical, physical, scale, status
        );
    }

    // ---- Cleanup old wallpaper files (only keep ones we just generated) ----
    let valid_files: Vec<String> = displays
        .iter()
        .map(|d| format!("generated-{}-{}", di::slugify(&d.name), now_ts))
        .collect();

    if let Ok(entries) = fs::read_dir(&wallpaper_dir) {
        for entry in entries.flatten() {
            let name = entry.file_name();
            let ns = name.to_string_lossy();
            // Only clean up generated-* files, not subdirs or other patterns
            if ns.starts_with("generated-")
                && (ns.ends_with(".svg") || ns.ends_with(".png"))
                && !valid_files.iter().any(|v| ns.starts_with(v))
            {
                let _ = fs::remove_file(entry.path());
            }
        }
    }
}

/// Encode an RGBA8 buffer as a PNG file. Returns true on success.
fn encode_png(path: &std::path::Path, width: u32, height: u32, rgba: &[u8]) -> bool {
    let file = match fs::File::create(path) {
        Ok(f) => f,
        Err(e) => {
            eprintln!("  Failed to create {}: {}", path.display(), e);
            return false;
        }
    };

    let mut encoder = png::Encoder::new(file, width, height);
    encoder.set_color(png::ColorType::Rgba);
    encoder.set_depth(png::BitDepth::Eight);

    let mut writer = match encoder.write_header() {
        Ok(w) => w,
        Err(e) => {
            eprintln!("  PNG header error: {}", e);
            return false;
        }
    };

    match writer.write_image_data(rgba) {
        Ok(()) => true,
        Err(e) => {
            eprintln!("  PNG write error: {}", e);
            false
        }
    }
}

/// Resolve a path relative to HOME.
fn env_home(suffix: &str) -> PathBuf {
    let home = std::env::var("HOME").expect("HOME must be set");
    PathBuf::from(home).join(suffix)
}
