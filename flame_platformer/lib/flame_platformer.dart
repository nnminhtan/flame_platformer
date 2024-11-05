import 'dart:async';
import 'dart:convert';
import 'dart:io';
// import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_platformer/components/ControlButton/slide_button.dart';
import 'package:flame_platformer/components/game%20data/gamedata.dart';
import 'package:flame_platformer/components/healthbar/health_bar.dart';
import 'package:flame_platformer/components/healthbar/player_health_bar.dart';
import 'package:flame_platformer/components/ControlButton/Jump_Button.dart';
import 'package:flame_platformer/components/ControlButton/attack_button.dart';
import 'package:flame_platformer/components/player.dart';
import 'package:flame_platformer/components/level.dart';
import 'package:flutter/painting.dart';
import 'package:path_provider/path_provider.dart';

class FlamePlatformer extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection {
  //from save data
  double hp;
  double x;
  double y;
  String level;
  String bonfireName;
  bool inCave;

  bool playSounds;
  double soundVolume;
  bool isloadfromsavefile;

  FlamePlatformer({
    this.hp = 100.0,
    this.x = 272,
    this.y = 416,
    this.level = 'forestmap',
    this.bonfireName = 'Bonfire_Ground',
    this.inCave = false,
    this.playSounds = true, // Optional, default to true
    this.soundVolume = 1.0,
    this.isloadfromsavefile = false, // Optional, default to 1.0
  });

  late CameraComponent cam;
  Player player = Player();
  late JoystickComponent joystick;
  bool isPaused = false;
  //sound

  late HealthBar healthBar;
  double zoomScale = 5.0;

  List<String> levelNames = ['forestmap', 'castlemap'];
  int currentLevelIndex = 0;

  @override
  FutureOr<void> onLoad() async {
    isPaused = true;
    // load images to cache
    await images.loadAllImages();

    print(
        'Sound volume: $soundVolume, Sound is on: $playSounds, incave: $inCave');

    // _loadLevel();
    Future.delayed(const Duration(seconds: 1), () async {
      addJoystick();

      for (int i = 0; i < levelNames.length; i++) {
        if (level == levelNames[i]) {
          currentLevelIndex = i;
        }
      }
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
    add(SLideButton());
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
      //stop
      default:
        // player.horizontalMovement = 0;
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

  // Save game data
  Future<void> saveGameData(GameData gameData) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      print('Directory path: ${directory.path}');
      final path = '${directory.path}/game_data.json'; // Save in one file
      print('save: $path');
      final file = File(path);
      final jsonData =
          jsonEncode(gameData.toJson()); // Convert GameData to JSON
      await file.writeAsString(jsonData);
    } catch (e, stacktrace) {
      print('Error saving game data: $e');
      print('Stacktrace: $stacktrace');
    }

    // Then save to Firebase if the user is signed in
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final db = FirebaseFirestore.instance;
        await db.collection('game_data').doc(user.uid).set(gameData.toJson());
        print('Game data saved to Firebase for user ${user.uid}');
      } else {
        print('No user signed in; Firebase save skipped.');
      }
    } catch (e, stacktrace) {
      print('Error saving game data to Firebase: $e');
      print('Stacktrace: $stacktrace');
    }
  }
}
