use bevy::prelude::*;
use bevy_kira_audio::prelude::*;

mod scene;
mod camera;
mod player;
mod music;

use scene::*;
use camera::*;
use player::*;
use music::*;

fn main() {
    App::new()
        .add_plugins(DefaultPlugins)
        .add_plugins((ScenePlugin, PlayerPlugin))
        .add_plugins(AudioPlugin)
        .add_systems(Startup, spawn_camera)
        .add_systems(Startup, start_background_audio)
        .run();
}

