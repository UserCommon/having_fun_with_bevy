use bevy::prelude::*;


pub struct ScenePlugin;

impl Plugin for ScenePlugin {
    fn build(&self, app: &mut App) {
        app.add_systems(Startup, (greeting_system,
                                  spawn_floor,
                                  spawn_light));
    }
}

pub fn greeting_system() {
    println!("hello world!");
}

pub fn spawn_floor(
    mut commands: Commands,
    mut meshes: ResMut<Assets<Mesh>>,
    mut materials: ResMut<Assets<StandardMaterial>>
) {
    let floor = PbrBundle {
        mesh: meshes.add(Mesh::from(shape::Plane::from_size(16.))),
        material: materials.add(StandardMaterial {
            base_color: Color::RED,
            ..default()
        }),
        ..default()
    };

    commands.spawn(floor);
}

pub fn spawn_light(
    mut commands: Commands
) {
    let light = PointLightBundle {
        point_light: PointLight {
            intensity: 50000.0,
            ..default()
        },
        transform: Transform::from_xyz(0., 5., 0.0),
        ..default()
    };

    commands.spawn(light);
}
