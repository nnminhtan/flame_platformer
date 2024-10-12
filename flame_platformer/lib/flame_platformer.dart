import 'dart:async';
// import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_platformer/components/health_bar.dart';
import 'package:flame_platformer/components/player.dart';
import 'package:flame_platformer/components/level.dart';
import 'package:flutter/painting.dart';

class FlamePlatformer extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection {
  late final CameraComponent cam;
  Player player = Player();
  late JoystickComponent joystick;
  bool isPaused = false;
  late HealthBar healthBar;

  @override
  FutureOr<void> onLoad() async {
    // load images to cache
    await images.loadAllImages();

    final world = Level(
      levelName: 'forestmap',
      player: player,
    );
    await add(world);

    // Get map dimensions
    final mapWidth = world.getMapWidth();
    final mapHeight = world.getMapHeight();
    print('map width x height: $mapWidth x $mapHeight');

    // castle: 1920, forest: 2544
    cam = CameraComponent.withFixedResolution(
        world: world, width: mapWidth, height: mapHeight);
    cam.viewfinder.anchor = Anchor.center;
    cam.viewfinder.zoom = 4.0;
    add(cam);
    healthBar = HealthBar();
    add(healthBar);
    // addAll([cam, world]);
    addJoystick();
    // TODO: implement onLoad
    return super.onLoad();
  }

  //calc zoom
  double calculateZoom(double viewportWidth, double viewportHeight,
      {required double desiredWidth, required double desiredHeight}) {
    final zoomX = viewportWidth / desiredWidth;
    final zoomY = viewportHeight / desiredHeight;

    // Return the smaller zoom factor to maintain the aspect ratio
    return zoomX < zoomY ? zoomX : zoomY;
  }

  @override
  void update(double dt) {
    if (!isPaused) {
      updateJoystick(); // Call this only if the game is not paused
      super.update(dt); // Update the game logic
    }
  }

  void togglePause() {
    isPaused = !isPaused; // Toggle the paused state
    // You might want to also show/hide the pause menu here
  }

  void addJoystick() {
    joystick = JoystickComponent(
      priority: 100,
      knob: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/Knob.png'),
        ),
      ),
      background: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/Joystick.png'),
        ),
      ),
      margin: const EdgeInsets.only(left: 64, bottom: 32),
    );
    add(joystick);
  }

  void updateJoystick() {
    switch (joystick.direction) {
      //side and down
      case JoystickDirection.left:
      case JoystickDirection.downLeft:
        // print('Joystick Dir: ${joystick.direction}');
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.downRight:
        // print('Joystick Dir: ${joystick.direction}');
        player.horizontalMovement = 1;
        break;
      //change this later to jump
      case JoystickDirection.upLeft:
        player.horizontalMovement = -1;
        player.hasJumped = true;
        // print('Joystick Dir: ${joystick.direction}');
        // Player().playerDirection = PlayerDirection.left;
        break;
      case JoystickDirection.upRight:
        player.horizontalMovement = 1;
        player.hasJumped = true;
        // print('Joystick Dir: ${joystick.direction}');
        // Player().playerDirection = PlayerDirection.right;
        break;

      //stop
      default:
        // player.horizontalMovement = 0;
        // player.hasJumped = false;
        break;
    }
  }
}
