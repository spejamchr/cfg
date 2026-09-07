use std::{io, process::Command, thread};

use serde::Deserialize;
use termion::{color, terminal_size};

fn main() -> io::Result<()> {
    // print!("{}{}", termion::clear::All, termion::cursor::Goto(1, 1),);

    let (columns, rows) = terminal_size()?;

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
            .and_then(|s| serde_json::from_slice(&s).map_err(Into::into))
    });

    let getting_displays = thread::spawn(|| -> io::Result<Vec<Display>> {
        Command::new("yabai")
            .arg("-m")
            .arg("query")
            .arg("--displays")
            .output()
            .map(|o| o.stdout)
            .and_then(|s| serde_json::from_slice(&s).map_err(Into::into))
    });

    let spaces = getting_spaces.join().expect("Couldn't get spaces")?;
    let windows = getting_windows.join().expect("Couldn't get windows")?;
    let displays = getting_displays.join().expect("Couldn't get displays")?;

    let s = format!(
        "Columns: {}{}{}, Rows: {}{}{}, spaces: {:?}",
        color::Fg(color::Cyan),
        columns,
        color::Fg(color::Reset),
        color::Fg(color::Magenta),
        rows,
        color::Fg(color::Reset),
        spaces
    );
    println!("Windows: {:?}", windows);
    println!("Displays: {:?}", displays);
    println!("{}", s);
    println!("String length: {}", s.len());

    Ok(())
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
