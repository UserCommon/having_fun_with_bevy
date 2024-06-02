use bevy::prelude::*;



pub fn spawn_camera(
    mut commands: Commands
) {
    let camera = Camera3dBundle {
        transform: Transform::from_xyz(-3.5, 2.5, 7.)
            .looking_at(Vec3::ZERO, Vec3::Y),
        ..default()
    };

    commands.spawn(camera);
}
