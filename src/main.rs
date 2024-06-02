use bevy::prelude::*;
use bevy_kira_audio::prelude::*;

mod cursor;
mod scene;
mod camera;
mod player;
mod music;

use cursor::*;
use scene::*;
use camera::*;
use player::*;
use music::*;

fn main() {
    App::new()
        .add_plugins(DefaultPlugins)
        .add_plugins(ScenePlugin)
        .add_plugins(PlayerPlugin)
        .add_plugins(AudioPlugin)
        .add_systems(Startup, spawn_camera)
        .add_systems(Startup, start_background_audio)
        .run();
}

