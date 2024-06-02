use bevy::prelude::*;
use bevy::window::{CursorGrabMode, PrimaryWindow};

struct CursorPlugin;

impl Plugin for CursorPlugin {
    fn build(&self, app: &mut App) {
        app.add_systems(Startup, cursor_grab);
    }
}


fn cursor_grab(
    mut q_windows: Query<&mut Window, With<PrimaryWindow>>,
) {
    let mut primary_window = q_windows.single_mut();

    // if you want to use the cursor, but not let it leave the window,
    // use `Confined` mode:
    primary_window.cursor.grab_mode = CursorGrabMode::Confined;

    // for a game that doesn't use the cursor (like a shooter):
    // use `Locked` mode to keep the cursor in one place
    primary_window.cursor.grab_mode = CursorGrabMode::Locked;

    // also hide the cursor
    primary_window.cursor.visible = false;
}

fn cursor_ungrab(
    mut q_windows: Query<&mut Window, With<PrimaryWindow>>,
) {
    let mut primary_window = q_windows.single_mut();

    primary_window.cursor.grab_mode = CursorGrabMode::None;
    primary_window.cursor.visible = true;
}
