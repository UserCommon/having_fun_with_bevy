use bevy::prelude::*;
use bevy::input::mouse::MouseMotion;

pub struct PlayerPlugin;

impl Plugin for PlayerPlugin {
    fn build(&self, app: &mut App) {
        app.add_systems(Startup, spawn_player)
           .add_systems(Update, player_keyboard)
           .add_systems(Update, player_mouse_motion);
    }
}

#[derive(Component)]
struct Player;

#[derive(Component)]
struct Speed(f32);

fn player_keyboard(
    time: Res<Time>,
    keys: Res<ButtonInput<KeyCode>>,
    mut player_query: Query<(&mut Transform, &Speed), With<Player>>,
    cam_query: Query<&Transform, (With<Camera3d>, Without<Player>)>
) {
    for ( mut player_t, player_speed ) in player_query.iter_mut() {
        let cam = match cam_query.get_single() {
            Ok(c) => c,
            Err(e) => Err(format!("error retrieving camera: {}", e)).unwrap()
        };

        let mut direction = Vec3::ZERO;

        if keys.pressed(KeyCode::KeyW) {
            direction += Into::<Vec3>::into(cam.forward());
        }

        if keys.pressed(KeyCode::KeyA) {
            direction += Into::<Vec3>::into(cam.left());
        }

        if keys.pressed(KeyCode::KeyS) {
            direction += Into::<Vec3>::into(cam.back());
        }

        if keys.pressed(KeyCode::KeyD) {
            direction += Into::<Vec3>::into(cam.right());
        }

        direction.y = 0.;
        let movement = direction.normalize_or_zero() * player_speed.0 * time.delta_seconds();
        player_t.translation += movement;
    }
}

fn player_mouse_motion(
    mut motion: EventReader<MouseMotion>
) {
    for m in motion.read() {
        println!("Mouse moved: X: {} px, Y: {} px", m.delta.x, m.delta.y);
    }
}

fn spawn_player(
    mut commands: Commands,
    assets: Res<AssetServer>
) {
    let player_model = SceneBundle {
        scene: assets.load("zombak.gltf#Scene0"),
        transform: Transform::from_xyz(0., 0.5, 0.),
        ..default()
    };

    let player_component = Player;

    let player_speed = Speed(2.0);

    let player = (player_model, player_component, player_speed);

    commands.spawn(player);
}
