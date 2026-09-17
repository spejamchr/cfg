//! Fast wallboard wallpaper generator — Ruby → Rust rewrite.
//!
//! Performance wins vs Ruby:
//! - SVG built into pre-allocated Vec<u8> (no string interpolation per line)
//! - `system_profiler` called once and cached (Ruby called it TWICE per display)
//! - serde_json for fast, zero-copy-friendly parsing

use std::fs;
use std::path::PathBuf;
use std::process::Command;
use std::time::Instant;

use chrono::SecondsFormat;

use debug_print::debug_eprintln;
use wallboard::display_info as di;
use wallboard::palette::Palette;
use wallboard::svg_gen::{DisplayDims, render_wallpaper};

/// Cached results for the slow subprocess calls (kitty outputs, physical resolutions).
/// `yabai_displays` serves as the cache-buster: if it changes, we re-fetch everything.
#[derive(serde::Serialize, serde::Deserialize)]
struct FetchCache {
    yabai_displays: Vec<serde_json::Value>,
    kitty_outputs: Vec<String>,
    sp_map: std::collections::HashMap<String, [u32; 2]>,
}

fn cache_path() -> PathBuf {
    let home = std::env::var("HOME").expect("HOME must be set");
    PathBuf::from(home).join(".cache/wallboard/fetch_cache.json")
}

fn load_cache() -> Option<FetchCache> {
    let content = fs::read_to_string(cache_path()).ok()?;
    serde_json::from_str(&content).ok()
}

fn save_cache(cache: &FetchCache) {
    let path = cache_path();
    if let Some(parent) = path.parent() {
        let _ = fs::create_dir_all(parent);
    }
    if let Ok(json) = serde_json::to_string(cache) {
        let _ = fs::write(&path, json);
    }
}

fn main() {
    let _t_main = Instant::now();
    let now_ts = chrono::offset::Local::now()
        .to_rfc3339_opts(SecondsFormat::Secs, false)
        .replace(':', ""); // matches Ruby strftime("%Y%m%d%H%M%S")

    let wallpaper_dir = env_home("Pictures/GeneratedWallpapers");

    // Create output directory (matches Ruby FileUtils.mkdir_p)
    fs::create_dir_all(&wallpaper_dir).ok();

    // ---- Fetch display data (yabai always; kitty + sp_map cached) ----
    let _t_fetch = Instant::now();
    let yabai_displays = di::fetch_yabai_displays();

    let (kitty_outputs, sp_map) = if let Some(cached) = load_cache() {
        if cached.yabai_displays == yabai_displays {
            debug_eprintln!("[perf] fetch: cache HIT");
            let sp_map: std::collections::HashMap<String, (u32, u32)> = cached
                .sp_map
                .into_iter()
                .map(|(k, [w, h])| (k, (w, h)))
                .collect();
            (cached.kitty_outputs, sp_map)
        } else {
            debug_eprintln!("[perf] fetch: cache MISS (yabai changed)");
            let (kitty_outputs, sp_map) = std::thread::scope(|s| {
                let h1 = s.spawn(|| di::fetch_kitty_outputs());
                let h2 = s.spawn(|| di::fetch_physical_resolutions());
                (h1.join().unwrap(), h2.join().unwrap())
            });
            save_cache(&FetchCache {
                yabai_displays: yabai_displays.clone(),
                kitty_outputs: kitty_outputs.clone(),
                sp_map: sp_map
                    .iter()
                    .map(|(k, (w, h))| (k.clone(), [*w, *h]))
                    .collect(),
            });
            (kitty_outputs, sp_map)
        }
    } else {
        debug_eprintln!("[perf] fetch: cache MISS (no cache file)");
        let (kitty_outputs, sp_map) = std::thread::scope(|s| {
            let h1 = s.spawn(|| di::fetch_kitty_outputs());
            let h2 = s.spawn(|| di::fetch_physical_resolutions());
            (h1.join().unwrap(), h2.join().unwrap())
        });
        save_cache(&FetchCache {
            yabai_displays: yabai_displays.clone(),
            kitty_outputs: kitty_outputs.clone(),
            sp_map: sp_map
                .iter()
                .map(|(k, (w, h))| (k.clone(), [*w, *h]))
                .collect(),
        });
        (kitty_outputs, sp_map)
    };
    debug_eprintln!(
        "[perf] fetch_all: {:.1} ms",
        _t_fetch.elapsed().as_secs_f64() * 1000.0
    );

    if kitty_outputs.is_empty() {
        debug_eprintln!("{} | No Kitty panel outputs found.", now_ts);
        return;
    }

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

    // ---- Process each display in parallel ----
    let _t_total_render = Instant::now();
    let _t_total_png = Instant::now();
    let _t_total_kitty = Instant::now();

    std::thread::scope(|s| {
        for display in &displays {
            s.spawn(|| {
                let physical_w = display.physical_w.max(1);
                let physical_h = display.physical_h.max(1);

                // Rasterize anti-aliased lines directly into an RGBA buffer at physical resolution
                let t = Instant::now();
                let rgba_buf = render_wallpaper(
                    &DisplayDims {
                        logical_w: display.logical_w,
                        logical_h: display.logical_h,
                        physical_w,
                        physical_h,
                    },
                    &palette,
                );
                let _render_ms = t.elapsed().as_secs_f64() * 1000.0;
                debug_eprintln!(
                    "[perf] render_wallpaper ({}): {:.1} ms",
                    display.name,
                    _render_ms
                );

                let slugified = di::slugify(&display.name);
                let base_name = format!("generated-{}-{}", slugified, now_ts);
                let png_path = wallpaper_dir.join(format!("{base_name}.png"));

                // Encode RGBA → PNG in-process
                let t = Instant::now();
                let png_ok = encode_png(&png_path, physical_w, physical_h, &rgba_buf);
                let _png_ms = t.elapsed().as_secs_f64() * 1000.0;
                debug_eprintln!("[perf] encode_png ({}): {:.1} ms", display.name, _png_ms);

                if !png_ok {
                    debug_eprintln!("{} | PNG encoding FAILED for {}", now_ts, display.name);
                }

                // Update kitty background via IPC (matches Ruby system(...))
                let socket = display.kitty_socket();
                let t = Instant::now();
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
                let _kitty_ms = t.elapsed().as_secs_f64() * 1000.0;
                debug_eprintln!(
                    "[perf] kitty set-background-image ({}): {:.1} ms",
                    display.name,
                    _kitty_ms
                );

                let _logical = format!("{}x{}", display.logical_w, display.logical_h);
                let _physical = format!("{}x{}", physical_w, physical_h);
                let _scale = display.scale_factor();
                let _status = if kitty_ok {
                    "."
                } else {
                    " [kitty update FAILED]"
                };

                debug_eprintln!(
                    "{} | Wallpaper for {} ({} → {}, scale: {}) {}",
                    now_ts,
                    display.name,
                    _logical,
                    _physical,
                    _scale,
                    _status
                );
            });
        }
    });

    debug_eprintln!(
        "[perf] TOTAL — render: {:.1} ms | png: {:.1} ms | kitty: {:.1} ms",
        _t_total_render.elapsed().as_secs_f64() * 1000.0,
        _t_total_png.elapsed().as_secs_f64() * 1000.0,
        _t_total_kitty.elapsed().as_secs_f64() * 1000.0,
    );

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

    debug_eprintln!(
        "[perf] main() total: {:.1} ms",
        _t_main.elapsed().as_secs_f64() * 1000.0
    );
}

/// Encode an RGBA8 buffer as a PNG file. Returns true on success.
fn encode_png(path: &std::path::Path, width: u32, height: u32, rgba: &[u8]) -> bool {
    let file = match fs::File::create(path) {
        Ok(f) => f,
        Err(_e) => {
            debug_eprintln!("  Failed to create {}: {}", path.display(), _e);
            return false;
        }
    };

    let mut encoder = png::Encoder::new(file, width, height);
    encoder.set_color(png::ColorType::Rgba);
    encoder.set_depth(png::BitDepth::Eight);
    encoder.set_compression(png::Compression::Fast);

    let mut writer = match encoder.write_header() {
        Ok(w) => w,
        Err(_e) => {
            debug_eprintln!("  PNG header error: {}", _e);
            return false;
        }
    };

    match writer.write_image_data(rgba) {
        Ok(()) => true,
        Err(_e) => {
            debug_eprintln!("  PNG write error: {}", _e);
            false
        }
    }
}

/// Resolve a path relative to HOME.
fn env_home(suffix: &str) -> PathBuf {
    let home = std::env::var("HOME").expect("HOME must be set");
    PathBuf::from(home).join(suffix)
}
