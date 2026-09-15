//! Display info: yabai display frames, kitty output names, and system_profiler physical resolutions.

use std::collections::{HashMap, HashSet};
use std::process::Command;

/// Parse `kitty +kitten panel --output-name=listjson` → list of output names.
pub fn fetch_kitty_outputs() -> Vec<String> {
    let raw = Command::new("sh")
        .arg("-c")
        .arg("kitty +kitten panel --output-name=listjson 2>/dev/null")
        .output()
        .ok()
        .and_then(|o| String::from_utf8(o.stdout).ok())
        .unwrap_or_else(|| "[]".to_string());

    serde_json::from_str::<serde_json::Value>(&raw)
        .ok()
        .and_then(|v| v.as_array().cloned())
        .map(|arr| {
            arr.iter()
                .filter_map(|o| o.get("name").and_then(|n| n.as_str()).map(String::from))
                .collect()
        })
        .unwrap_or_default()
}

/// Parse `yabai -m query --displays` → list of display objects.
pub fn fetch_yabai_displays() -> Vec<serde_json::Value> {
    let raw = Command::new("sh")
        .arg("-c")
        .arg("yabai -m query --displays 2>/dev/null")
        .output()
        .ok()
        .and_then(|o| String::from_utf8(o.stdout).ok())
        .unwrap_or_else(|| "[]".to_string());

    serde_json::from_str::<serde_json::Value>(&raw)
        .ok()
        .and_then(|v| v.as_array().cloned())
        .unwrap_or_default()
}

/// Parse `system_profiler SPDisplaysDataType` → name → physical resolution map.
pub fn fetch_physical_resolutions() -> HashMap<String, (u32, u32)> {
    let raw = Command::new("system_profiler")
        .arg("SPDisplaysDataType")
        .output()
        .ok()
        .and_then(|o| String::from_utf8(o.stdout).ok())
        .unwrap_or_default();

    let mut map: HashMap<String, (u32, u32)> = HashMap::new();
    let mut seen: HashSet<String> = HashSet::new();

    for entry in raw.split("Chipset Model:") {
        for line in entry.lines() {
            // Match: 8 spaces + name (no colon) + ":"
            if line.len() >= 9 && &line[..8] == "        " {
                let rest = &line[8..];
                if let Some(raw_name) = rest.strip_suffix(':') {
                    let candidate = raw_name.trim().to_string();

                    // Skip metadata lines (same filter as Ruby)
                    let skip = matches!(
                        candidate.as_str(),
                        "Graphics"
                            | "Display Type"
                            | "Chipset"
                            | "Vendor"
                            | "Type:"
                            | "Bus"
                            | "Total"
                    );
                    if skip || candidate.starts_with("Metal") {
                        continue;
                    }

                    // Skip duplicates from multiple GPU entries
                    if !seen.insert(candidate.clone()) {
                        continue;
                    }

                    // Find Resolution in this entry block (same logic as Ruby)
                    if let Some(res_line) = entry
                        .lines()
                        .find(|l| l.trim_start().starts_with("Resolution:"))
                    {
                        let text = res_line
                            .trim_start()
                            .strip_prefix("Resolution:")
                            .unwrap_or("")
                            .trim();
                        if let Ok((w, h)) = parse_resolution(text) {
                            map.insert(candidate, (w, h));
                        }
                    }
                    break; // One display name per line
                }
            }
        }
    }

    map
}

fn parse_resolution(s: &str) -> Result<(u32, u32), ()> {
    let parts: Vec<&str> = s.split('x').collect();
    if parts.len() != 2 {
        return Err(());
    }
    let w = parts[0].trim().parse::<u32>().map_err(|_| ())?;
    let h = parts[1].trim().parse::<u32>().map_err(|_| ())?;
    Ok((w, h))
}

#[derive(Debug)]
pub struct Display {
    pub name: String,
    pub logical_w: u32,
    pub logical_h: u32,
    pub physical_w: u32,
    pub physical_h: u32,
}

impl Display {
    /// Build a Display from kitty output name + yabai frame data.
    pub fn new(
        name: &str,
        logical_w: u32,
        logical_h: u32,
        sp_map: &HashMap<String, (u32, u32)>,
    ) -> Self {
        let mut physical_w = 0u32;
        let mut physical_h = 0u32;

        if !sp_map.is_empty() {
            // Strategy 1: Direct substring match between kitty name and sp display name
            let candidate = sp_map
                .keys()
                .find(|&sp_name| name.contains(sp_name) || sp_name.contains(name));

            match candidate {
                Some(sp_name) => {
                    (physical_w, physical_h) = *sp_map.get(sp_name).unwrap();
                }
                None => {
                    // Strategy 2: Heuristic — "Retina"/"Liquid" → Color LCD
                    let name_lower = name.to_lowercase();
                    if name_lower.contains("retina") || name_lower.contains("liquid") {
                        for (sp_name, (w, h)) in sp_map.iter() {
                            let sp_lower = sp_name.to_lowercase();
                            if sp_lower.contains("lcd") || sp_lower.contains("color") {
                                physical_w = *w;
                                physical_h = *h;
                                break;
                            }
                        }
                    }
                }
            }
        }

        Self {
            name: name.to_string(),
            logical_w,
            logical_h,
            physical_w: if physical_w > 0 {
                physical_w
            } else {
                logical_w
            },
            physical_h: if physical_h > 0 {
                physical_h
            } else {
                logical_h
            },
        }
    }

    pub fn scale_factor(&self) -> f64 {
        if self.physical_w == 0 || self.logical_w == 0 {
            return 1.0;
        }
        (self.physical_w as f64 / self.logical_w as f64).round()
    }

    pub fn kitty_socket(&self) -> String {
        let slug: String = self
            .name
            .chars()
            .map(|c| if c.is_ascii_alphanumeric() { c } else { '_' })
            .collect();
        format!("unix:/tmp/mykittywallboard_{slug}")
    }
}

/// Match a kitty output name to a yabai display → logical (w, h).
pub fn match_yabai_frame(name: &str, displays: &[serde_json::Value], idx: usize) -> (u32, u32) {
    // Strategy 1: label substring match
    if let Some(found) = displays.iter().find(|d| {
        d.get("label")
            .and_then(|l| l.as_str())
            .is_some_and(|label| {
                !label.is_empty() && (label.contains(name) || name.contains(label))
            })
    }) {
        if let Some(frame) = found.get("frame") {
            return (
                frame["w"].as_f64().unwrap_or(1920.0) as u32,
                frame["h"].as_f64().unwrap_or(1080.0) as u32,
            );
        }
    }
    // Strategy 2: positional index (most common case per Ruby comment)
    if let Some(entry) = displays.get(idx) {
        if let Some(frame) = entry.get("frame") {
            return (
                frame["w"].as_f64().unwrap_or(1920.0) as u32,
                frame["h"].as_f64().unwrap_or(1080.0) as u32,
            );
        }
    }
    // Strategy 3: default
    (1920, 1080)
}

/// Slugify display name for use in filenames.
pub fn slugify(name: &str) -> String {
    name.chars()
        .filter(|c| c.is_ascii_alphanumeric() || *c == '_')
        .collect()
}
