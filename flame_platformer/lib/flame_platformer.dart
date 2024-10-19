import 'dart:async';
// import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_platformer/components/healthbar/health_bar.dart';
import 'package:flame_platformer/components/healthbar/player_health_bar.dart';
import 'package:flame_platformer/components/ControlButton/Jump_Button.dart';
import 'package:flame_platformer/components/ControlButton/attack_button.dart';
import 'package:flame_platformer/components/player.dart';
import 'package:flame_platformer/components/level.dart';
import 'package:flutter/painting.dart';

class FlamePlatformer extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection {
  late CameraComponent cam;
  Player player = Player();
  late JoystickComponent joystick;
  bool isPaused = false;
  late HealthBar healthBar;
  double zoomScale = 5.0;

  List<String> levelNames = ['forestmap', 'castlemap'];
  int currentLevelIndex = 0;
  

  @override
  FutureOr<void> onLoad() async {
    
    isPaused = true;
    // load images to cache
    await images.loadAllImages();
    
    // _loadLevel();
    Future.delayed(const Duration(seconds: 1), () async {
      addJoystick();
      final world = Level(
        levelName: levelNames[currentLevelIndex],
        player: player,
      )..priority = 0;
      await add(world);

    

      // Get map dimensions
      final mapWidth = world.getMapWidth();
      final mapHeight = world.getMapHeight();
      print('map width x height: $mapWidth x $mapHeight');

      // castle: 1920, forest: 2544
      cam = CameraComponent.withFixedResolution(
          world: world, width: mapWidth, height: mapHeight)
        ..priority = 1;
      cam.viewfinder.anchor = Anchor.center;
      cam.viewfinder.zoom = zoomScale;
      await add(cam);

      healthBar = PlayerHealthBar(player)..priority = 5;
      await add(healthBar);

      add(FpsTextComponent(
        position: Vector2(40, 40), // Position in the top-left corner
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Color(0xFFFFFFFF), // White color for the FPS text
            fontSize: 24,
          ),
        ),
      ));
      // addAll([cam, world]);
      // children.sort((a, b) => a.priority.compareTo(b.priority));
      // TODO: implement onLoad
      isPaused = false;
    });
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
      priority: 5,
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
    add(AttackButton());
    add(JumpButton());
  }

  void updateJoystick() {
    switch (joystick.direction) {
      //side and down
      case JoystickDirection.left:
      case JoystickDirection.downLeft:
      case JoystickDirection.upLeft:
        // print('Joystick Dir: ${joystick.direction}');
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.downRight:
      case JoystickDirection.upRight:
        // print('Joystick Dir: ${joystick.direction}');
        player.horizontalMovement = 1;
        break;
      //change this later to jump

      //stop
      default:
        // player.horizontalMovement = 0;
        // player.hasJumped = false;
        break;
    }
  }

  void loadNextLevel() {
    removeWhere((component) => component is Level);

    if (currentLevelIndex < levelNames.length - 1) {
      currentLevelIndex++;
      _loadLevel();
    } else {
      // no more levels
      currentLevelIndex = 0;
      _loadLevel();
    }
  }

  void _loadLevel() async {
    Future.delayed(const Duration(seconds: 1), () async {
      // addJoystick();
      final world = Level(
        levelName: levelNames[currentLevelIndex],
        player: player,
      )..priority = 0;
      await add(world);

      // Get map dimensions
      final mapWidth = world.getMapWidth();
      final mapHeight = world.getMapHeight();
      print('map width x height: $mapWidth x $mapHeight');

      // castle: 1920, forest: 2544
      cam = CameraComponent.withFixedResolution(
          world: world, width: mapWidth, height: mapHeight)
        ..priority = 1;
      cam.viewfinder.anchor = Anchor.center;
      cam.viewfinder.zoom = zoomScale;
      await add(cam);

      healthBar = PlayerHealthBar(player)..priority = 5;
      await add(healthBar);
      // addAll([cam, world]);
      // children.sort((a, b) => a.priority.compareTo(b.priority));
      // TODO: implement onLoad
    });
  }
}
