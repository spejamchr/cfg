use std::fs;
use std::iter::repeat_n;
use std::num::NonZero;
use std::{io, process::Command, thread};

use chrono::{Datelike, Local, Timelike, Weekday};
use clap::Parser;
use serde::Deserialize;
use sysinfo::{LoadAvg, System};
use termion::color::Color;
use termion::{color, style, terminal_size, terminal_size_pixels};
use unicode_ellipsis::truncate_str;
use unicode_width::UnicodeWidthStr;

#[derive(Parser, Debug)]
#[command(version, about, long_about = None)]
struct Args {
    /// Name of the display
    #[arg(short, long)]
    display_name: String,
}

fn main() -> io::Result<()> {
    let args = Args::parse();

    let (columns, _rows) = terminal_size()?;
    let (width_px, _height_px) = terminal_size_pixels()?;

    let getting_pianobar_on = sysinfo::System::new_all()
        .processes_by_exact_name("pianobar".as_ref())
        .count()
        > 0;

    let getting_pianobar_song = last_pianobar_track();

    let getting_battery_info = thread::spawn(get_battery_info);

    let getting_spaces = thread::spawn(|| -> io::Result<Vec<Space>> {
        Command::new("yabai")
            .arg("-m")
            .arg("query")
            .arg("--spaces")
            .output()
            .map(|o| o.stdout)
            .and_then(|s| serde_json::from_slice(&s).map_err(Into::into))
    });

    let getting_windows = thread::spawn(|| -> io::Result<Vec<Window>> {
        Command::new("yabai")
            .arg("-m")
            .arg("query")
            .arg("--windows")
            .output()
            .map(|o| o.stdout)
            .and_then(|s| serde_json::from_slice::<Vec<Window>>(&s).map_err(Into::into))
    });

    let getting_cpus = std::thread::available_parallelism();

    let getting_percent_cpu = thread::spawn(|| -> Option<f64> {
        let output = Command::new("ps")
            .arg("-A")
            .arg("-o")
            .arg("%cpu")
            .output()
            .expect("Could not run ps");

        String::from_utf8_lossy(&output.stdout)
            .lines()
            .skip(1)
            .map(str::trim)
            .try_fold(0.0, |sum, s| s.parse::<f64>().ok().map(|num| num + sum))
    });

    let getting_loadavg = System::load_average();

    let getting_audio_out = thread::spawn(|| -> io::Result<AudioIO> {
        Command::new("SwitchAudioSource")
            .arg("-c")
            .arg("-t")
            .arg("output")
            .arg("-f")
            .arg("json")
            .output()
            .map(|o| o.stdout)
            .and_then(|s| serde_json::from_slice(&s).map_err(Into::into))
    });

    let battery_info = getting_battery_info
        .join()
        .expect("Couldn't get battery_info");
    let cpus = getting_cpus;
    let percent_cpu = getting_percent_cpu
        .join()
        .expect("Couldn't get percent_cpu");
    let loadavg = getting_loadavg;
    let audio_out = getting_audio_out.join().expect("Couldn't get audio_out");
    let pianobar_on = getting_pianobar_on;
    let pianobar_song = getting_pianobar_song;
    let spaces = getting_spaces
        .join()
        .expect("Couldn't get spaces")
        .unwrap_or_default();
    let windows = getting_windows
        .join()
        .expect("Couldn't get windows")
        .unwrap_or_default();

    print!("{}{}\n\n", termion::clear::All, termion::cursor::Goto(1, 1));

    let (spaces_width, spaces_item) = make_spaces_item(&args, &spaces);
    let (audio_width, audio_item) = make_audio_item(&audio_out);
    let (loadavg_width, loadavg_item) = make_loadavg_item(&loadavg, &cpus);
    let (cpu_percent_width, cpu_percent_item) = make_cpu_percent_item(percent_cpu, &cpus);
    let (battery_width, battery_item) = make_battery_item(&battery_info);
    let (date_width, date_item) = make_date_item();
    let (time_width, time_item) = make_time_item();

    let top_right_corner_items: Vec<_> = [
        audio_item,
        Some(loadavg_item),
        cpu_percent_item,
        Some(battery_item),
        Some(date_item),
        Some(time_item),
    ]
    .into_iter()
    .flatten()
    .collect();
    let top_right_corner_str = top_right_corner_items.join(" ");

    let top_right_corner_width = audio_width
                + loadavg_width
                + cpu_percent_width
                + battery_width
                + date_width
                + time_width
                // Account for the joining spaces
                + (top_right_corner_items.len() - 1);

    let notch_pixels = 450.0;
    let notch_columns = (notch_pixels / (width_px as f64) * (columns as f64)) as usize;

    // Reserve the outer 2 columns as a buffer
    let columns = columns - 2;

    match args.display_name.as_str() {
        "Built-in Retina Display" => {
            let notch_str: String = repeat_n(" ", notch_columns).collect();

            let columns_per_side = (columns as usize - notch_columns) / 2;
            let (pianobar_width, pianobar_item) = make_pianobar_item(
                pianobar_on,
                &pianobar_song,
                // Subtract 1 to reserve space for a gap
                columns_per_side - spaces_width - 1,
            );

            let left_joiner: String =
                repeat_n(" ", columns_per_side - spaces_width - pianobar_width).collect::<String>();

            let left_side_str = [spaces_item, pianobar_item.unwrap_or_default()].join(&left_joiner);

            let (current_app_width, current_app_item) =
                make_current_app_item(&windows, columns_per_side - top_right_corner_width - 1);

            let right_joiner: String = repeat_n(
                " ",
                columns_per_side - top_right_corner_width - current_app_width,
            )
            .collect::<String>();

            let right_side_str =
                [current_app_item.unwrap_or_default(), top_right_corner_str].join(&right_joiner);

            println!(" {}{}{} ", left_side_str, notch_str, right_side_str);
        }
        _ => {
            let (current_app_width, current_app_item) = make_current_app_item(
                &windows,
                columns as usize - spaces_width - 3 - top_right_corner_width,
            );

            let (pianobar_width, pianobar_item) = make_pianobar_item(
                pianobar_on,
                &pianobar_song,
                columns as usize - spaces_width - 3 - current_app_width - top_right_corner_width,
            );

            let all_but_last_pieces: Vec<_> = [Some(spaces_item), pianobar_item, current_app_item]
                .into_iter()
                .flatten()
                .collect();

            let pieces_width =
                spaces_width + pianobar_width + current_app_width + top_right_corner_width;
            let gaps_width = (columns as usize - pieces_width) / (all_but_last_pieces.len());
            let last_gap_width =
                columns as usize - pieces_width - gaps_width * (all_but_last_pieces.len() - 1);

            let gap: String = repeat_n(" ", gaps_width).collect();
            let last_gap: String = repeat_n(" ", last_gap_width).collect();

            println!(
                " {}{}{} ",
                all_but_last_pieces.join(&gap),
                last_gap,
                top_right_corner_str
            );
        }
    };

    Ok(())
}

fn make_pianobar_item(
    pianobar_on: bool,
    pianobar_song: &Option<TrackInfo>,
    max_width: usize,
) -> (usize, Option<String>) {
    if !pianobar_on {
        return (0, None);
    }
    match pianobar_song {
        Some(s) => {
            let by = " by ";
            let on = " on ";

            let (used_width, pieces) = vec![
                (s.title.as_str(), fg_colorer(&color::Green, false)),
                (by, fg_colorer(&color::White, false)),
                (s.artist.as_str(), fg_colorer(&color::Blue, false)),
                (on, fg_colorer(&color::White, false)),
                (s.album.as_str(), fg_colorer(&color::White, true)),
            ]
            .into_iter()
            .fold(
                (0, Vec::<String>::new()),
                |(width, mut pieces), (piece, formatter)| {
                    if width < max_width {
                        let piece = truncate_str(piece, max_width - width);
                        pieces.push(formatter(&piece));
                        (width + piece.width(), pieces)
                    } else {
                        (width, pieces)
                    }
                },
            );

            (
                used_width + QUOTE_WIDTH_ADDITION,
                Some(quote(&pieces.join(""))),
            )
        }
        None => {
            let msg = "音楽を始めます...";
            (msg.width() + QUOTE_WIDTH_ADDITION, Some(quote(msg)))
        }
    }
}

fn make_audio_item(audio_out: &io::Result<AudioIO>) -> (usize, Option<String>) {
    match audio_out {
        Ok(a) if a.uid == "BuiltInSpeakerDevice" => (0, None),
        Err(_) => (0, None),
        Ok(_) => {
            let msg = "󰋋";
            let msg_colored = fg_color(&color::Yellow, msg);
            (
                msg.width() + QUOTE_WIDTH_ADDITION,
                Some(quote(&msg_colored)),
            )
        }
    }
}

fn make_time_item() -> (usize, String) {
    let now = Local::now();
    let msg = format!("{:0>2}:{:0>2}", now.hour(), now.minute());
    (msg.width() + QUOTE_WIDTH_ADDITION, quote(&msg))
}

fn make_date_item() -> (usize, String) {
    let msg = japanese_date();

    // Add 4 to account for the double-width characters in the date
    (msg.width() + QUOTE_WIDTH_ADDITION, quote(&msg))
}

fn japanese_date() -> String {
    let now = Local::now();

    let weekday_short = match now.weekday() {
        Weekday::Mon => "月",
        Weekday::Tue => "火",
        Weekday::Wed => "水",
        Weekday::Thu => "木",
        Weekday::Fri => "金",
        Weekday::Sat => "土",
        Weekday::Sun => "日",
    };

    format!(
        "{}年{}月{}日({})",
        now.year(),
        now.month(),
        now.day(),
        weekday_short
    )
}

fn make_battery_item(battery_info: &BatteryInfo) -> (usize, String) {
    let icon = match battery_info.is_plugged_in {
        true => "",
        false => "",
    };
    let percent = battery_info
        .charged_percent
        .map(|p| format!(" {}%", p))
        .unwrap_or_default();
    let msg = format!("{}{}", icon, percent);

    let msg_colored = match battery_info.is_plugged_in {
        true => fg_color(&color::Yellow, &msg),
        false => fg_color(&color::Magenta, &msg),
    };

    (msg.width() + QUOTE_WIDTH_ADDITION, quote(&msg_colored))
}

fn fg_color(color: &dyn Color, msg: &str) -> String {
    format!("{}{}{}", color::Fg(color), msg, color::Fg(color::Reset))
}

fn fg_colorer(color: &dyn Color, underlined: bool) -> impl FnOnce(&str) -> String {
    move |msg: &str| {
        let msg = match underlined {
            true => underline(msg),
            false => msg.to_string(),
        };
        fg_color(color, &msg)
    }
}

fn underline(msg: &str) -> String {
    format!("{}{}{}", style::Underline, msg, style::NoUnderline)
}

const QUOTE_WIDTH_ADDITION: usize = 4;

fn quote(msg: &str) -> String {
    format!(
        "{}{}｢{}｣{}{}",
        fg_color(&color::Black, ""),
        color::Bg(color::AnsiValue::grayscale(0)),
        msg,
        color::Bg(color::Reset),
        fg_color(&color::Black, ""),
    )
}

/// Return a two-width representation of the current space index
fn index_to_str(index: usize) -> String {
    [
        "0", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十",
    ]
    .get(index)
    .map(|s| s.to_string())
    .unwrap_or_else(|| index.to_string())
}

fn make_spaces_item(args: &Args, spaces: &[Space]) -> (usize, String) {
    let display_id = match args.display_name.as_str() {
        "Built-in Retina Display" => 1,
        _ => 2,
    };

    let spaces_on_display: Vec<_> = spaces.iter().filter(|s| s.display == display_id).collect();
    let current_space = spaces_on_display
        .iter()
        .find(|s| s.has_focus || s.is_visible);
    let current_space_number = current_space
        .map(|s| index_to_str(s.index))
        .unwrap_or_else(|| "?".to_string());

    let total_spaces = index_to_str(spaces_on_display.len());

    let msg = &format!("{}/{}", current_space_number, total_spaces);

    (
        msg.width() + QUOTE_WIDTH_ADDITION,
        quote(&fg_color(&color::Cyan, msg)),
    )
}

fn make_current_app_item(windows: &[Window], max_width: usize) -> (usize, Option<String>) {
    let app = windows
        .iter()
        .find(|w| w.has_focus)
        .and_then(|w| match w.app.is_empty() {
            true => None,
            false => Some(w.app.clone()),
        });
    match app {
        Some(a) => {
            let msg = truncate_str(&a, max_width);
            (
                msg.width() + QUOTE_WIDTH_ADDITION,
                Some(quote(&fg_color(&color::White, &msg))),
            )
        }
        None => (0, None),
    }
}

fn make_loadavg_item(loadavg: &LoadAvg, cpus: &io::Result<NonZero<usize>>) -> (usize, String) {
    let msg = format!("{:.2}", loadavg.one);

    let colored_msg = match (
        &cpus
            .as_ref()
            .map(|c| loadavg.one > c.get() as f64)
            .unwrap_or(false),
        loadavg.one > loadavg.five,
    ) {
        (true, true) => fg_color(&color::Red, &msg),
        (true, false) => fg_color(&color::Magenta, &msg),
        (false, true) => fg_color(&color::Yellow, &msg),
        (false, false) => fg_color(&color::Green, &msg),
    };

    (msg.width() + QUOTE_WIDTH_ADDITION, quote(&colored_msg))
}

fn make_cpu_percent_item(
    percent_cpu: Option<f64>,
    cpus: &io::Result<NonZero<usize>>,
) -> (usize, Option<String>) {
    match cpus.as_ref().ok().zip(percent_cpu) {
        Some((cpus, percent_cpu)) => {
            let ratio = percent_cpu / cpus.get() as f64 / 100.0;
            let msg = match ratio {
                r if r < 0.333 => ".",
                r if r < 0.666 => "?",
                _ => "!",
            };
            let colored_msg = match ratio {
                r if r < 1.0 / 5.0 => fg_color(&color::LightBlack, msg),
                r if r < 2.0 / 5.0 => fg_color(&color::White, msg),
                r if r < 3.0 / 5.0 => fg_color(&color::Blue, msg),
                r if r < 4.0 / 5.0 => fg_color(&color::Yellow, msg),
                _ => fg_color(&color::Red, msg),
            };

            (
                msg.width() + QUOTE_WIDTH_ADDITION,
                Some(quote(&colored_msg)),
            )
        }
        None => (0, None),
    }
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "kebab-case")]
enum SpaceType {
    Bsp,
    Float,
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "kebab-case")]
#[allow(dead_code)]
struct Space {
    id: usize,
    uuid: String,
    index: usize,
    label: String,
    r#type: SpaceType,
    display: usize,
    windows: Vec<usize>,
    first_window: usize,
    last_window: usize,
    has_focus: bool,
    is_visible: bool,
    is_native_fullscreen: bool,
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "kebab-case")]
#[allow(dead_code)]
struct Frame {
    x: f64,
    y: f64,
    w: f64,
    h: f64,
}

#[derive(Debug, Deserialize)]
enum WindowRole {
    AXWindow,
    #[serde(rename = "")]
    Empty,
}

#[derive(Debug, Deserialize)]
enum WindowSubRole {
    AXStandardWindow,
    AXDialog,
    #[serde(rename = "")]
    Empty,
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "kebab-case")]
enum WindowLayer {
    Normal,
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "kebab-case")]
enum WindowSubLayer {
    Normal,
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "kebab-case")]
enum WindowSplitType {
    None,
    Vertical,
    Horizontal,
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "snake_case")]
enum WindowSplitChild {
    FirstChild,
    SecondChild,
    None,
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "kebab-case")]
#[allow(dead_code)]
struct Window {
    id: usize,
    pid: usize,
    app: String,
    title: String,
    scratchpad: String,
    frame: Frame,
    role: WindowRole,
    subrole: WindowSubRole,
    root_window: bool,
    display: usize,
    space: usize,
    level: usize,
    sub_level: usize,
    layer: WindowLayer,
    sub_layer: WindowSubLayer,
    opacity: f64,
    split_type: WindowSplitType,
    split_child: WindowSplitChild,
    stack_index: usize,
    can_move: bool,
    can_resize: bool,
    has_focus: bool,
    has_shadow: bool,
    has_parent_zoom: bool,
    has_fullscreen_zoom: bool,
    has_ax_reference: bool,
    is_native_fullscreen: bool,
    is_visible: bool,
    is_minimized: bool,
    is_hidden: bool,
    is_floating: bool,
    is_sticky: bool,
    is_grabbed: bool,
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "kebab-case")]
#[allow(dead_code)]
struct Display {
    id: usize,
    uuid: String,
    index: usize,
    label: String,
    frame: Frame,
    spaces: Vec<usize>,
    has_focus: bool,
}

#[derive(Debug)]
#[allow(dead_code)]
struct TrackInfo {
    url: String,
    title: String,
    artist: String,
    album: String,
    is_loved: bool,
}

fn last_pianobar_track() -> Option<TrackInfo> {
    let path = dirs::home_dir()?.join(".config/pianobar/out");

    let content = fs::read_to_string(&path).ok()?;

    let line = content
        .lines()
        .rfind(|l| l.contains(" by ") || l.contains(" on "))?
        .to_owned();

    parse_track(line.trim())
}

fn parse_track(input: &str) -> Option<TrackInfo> {
    const URL_START: &str = "\u{1b}]8;;";
    const BELL: char = '\u{7}';
    const RESET: &str = "\u{1b}[0m";
    const UNDERLINE: &str = "\u{1b}[4m";
    const RED: &str = "\u{1b}[31m";
    const GREEN: &str = "\u{1b}[32m";
    const BLUE: &str = "\u{1b}[34m";

    let url_start = input.find(URL_START)? + URL_START.len();
    let url_end = input[url_start..].find(BELL)? + url_start;
    let url = input[url_start..url_end].to_string();

    let rest = &input[url_end + 1..];

    let title_start = rest.find(GREEN)? + GREEN.len();
    let title_end = rest[title_start..].find(RESET)? + title_start;
    let title = rest[title_start..title_end].to_string();

    let rest = &rest[title_end + RESET.len()..];

    let artist_start = rest.find(BLUE)? + BLUE.len();
    let artist_end = rest[artist_start..].find(RESET)? + artist_start;
    let artist = rest[artist_start..artist_end].to_string();

    let rest = &rest[artist_end + RESET.len()..];

    let album_start = rest.find(UNDERLINE)? + UNDERLINE.len();
    let album_end = rest[album_start..].find(RESET)? + album_start;
    let album = rest[album_start..album_end].to_string();

    let rest = &rest[album_end + RESET.len()..];

    let is_loved = rest.find(&format!("{}<3{}", RED, RESET)).is_some();

    Some(TrackInfo {
        url,
        title,
        artist,
        album,
        is_loved,
    })
}

#[derive(Debug)]
#[allow(dead_code)]
struct BatteryInfo {
    is_plugged_in: bool,
    charged_percent: Option<usize>,
}

fn get_battery_info() -> BatteryInfo {
    let output = Command::new("pmset")
        .arg("-g")
        .arg("ps")
        .output()
        .expect("Failed to run pmset");
    let stdout = String::from_utf8_lossy(&output.stdout);
    let mut lines = stdout.lines();
    let first_line = lines.next().unwrap_or("");
    let second_line = lines.next().unwrap_or("");

    let is_plugged_in = first_line.contains("AC");
    let charged_percent: Option<usize> = regex::Regex::new(r"\d+\%")
        .expect("Invalid Regex!")
        .find(second_line)
        .map(|m| m.as_str().trim_matches('%'))
        .and_then(|s| s.parse().ok());

    BatteryInfo {
        is_plugged_in,
        charged_percent,
    }
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "snake_case")]
#[allow(dead_code)]
enum AudioIOType {
    Input,
    Output,
}

#[derive(Debug, Deserialize)]
#[allow(dead_code)]
struct AudioIO {
    name: String,
    r#type: AudioIOType,
    id: String,
    uid: String,
}
