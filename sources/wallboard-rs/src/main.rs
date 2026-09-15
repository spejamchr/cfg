//! Fast wallboard wallpaper generator — Ruby → Rust rewrite.
//!
//! Performance wins vs Ruby:
//! - SVG built into pre-allocated Vec<u8> (no string interpolation per line)
//! - `system_profiler` called once and cached (Ruby called it TWICE per display)
//! - serde_json for fast, zero-copy-friendly parsing

mod display_info;
mod palette;
mod svg_gen;

use std::fs;
use std::path::PathBuf;
use std::process::Command;

use chrono::SecondsFormat;

use self::display_info as di;
use crate::palette::Palette;
use crate::svg_gen::{DisplayDims, build_svg};

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
        // Generate SVG (fast: direct Vec<u8> write, no per-line allocations)
        let svg_buf = build_svg(
            &DisplayDims {
                logical_w: display.logical_w,
                logical_h: display.logical_h,
            },
            &palette,
        );

        let slugified = di::slugify(&display.name);
        let base_name = format!("generated-{}-{}", slugified, now_ts);
        let svg_path = wallpaper_dir.join(format!("{base_name}.svg"));
        let png_path = wallpaper_dir.join(format!("{base_name}.png"));

        // Write SVG (matches Ruby File.write behavior)
        fs::write(&svg_path, &svg_buf).expect("Failed to write SVG");

        println!("{:?}", svg_path);

        // Render SVG → PNG via rsvg-convert at physical pixel dimensions (HiDPI)
        let physical_w = display.physical_w.max(1);
        let physical_h = display.physical_h.max(1);

        let convert_ok = Command::new("rsvg-convert")
            .args(["-w", &physical_w.to_string(), "-h", &physical_h.to_string()])
            .arg(&svg_path)
            .arg("-o")
            .arg(&png_path)
            .status()
            .ok()
            .map(|s| s.success())
            .unwrap_or(false);

        if !convert_ok {
            eprintln!("{} | rsvg-convert FAILED for {}", now_ts, display.name);
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

/// Resolve a path relative to HOME.
fn env_home(suffix: &str) -> PathBuf {
    let home = std::env::var("HOME").expect("HOME must be set");
    PathBuf::from(home).join(suffix)
}
