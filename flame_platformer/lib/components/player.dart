import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_platformer/components/collision_block.dart';
import 'package:flame_platformer/components/player_hitbox.dart';
import 'package:flame_platformer/components/utils.dart';
import 'package:flame_platformer/flame_platformer.dart';
import 'package:flutter/services.dart';

enum PlayerState { idle, run, jump, fall }

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<FlamePlatformer>, KeyboardHandler {
  Player({position}) : super(position: position);

  // for animation
  final double stepTime = 0.15;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runAnimation;
  late final SpriteAnimation jumpAnimation;
  late final SpriteAnimation fallAnimation;

  // for movement
  double horizontalMovement = 0;
  double moveSpeed = 110;
  Vector2 velocity = Vector2.zero();

  // for environment interaction
  List<CollisionBlock> collisionBlocks = [];
  final double _gravity = 9.8;
  final double _jumpForce = 250; //460
  final double _terminalVelocity = 300;
  bool isOnGround = false;
  bool hasJumped = false;
  PlayerHitBox hitbox = PlayerHitBox(
    offsetX: 14,
    offsetY: 4,
    width: 21,
    height: 30,
  );

  @override
  FutureOr<void> onLoad() async {
    await _loadAllAnimations();
    debugMode = true;
    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height),
    ));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updatePlayerState();
    _updatePlayerMovement(dt);
    _checkHorizontalCollisions();
    _applyGravity(dt);
    _checkVerticalCollisions();
    super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // TODO: implement onKeyEvent
    horizontalMovement = 0;
    //Set the which key is pressed
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);

    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;

    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);

    return super.onKeyEvent(event, keysPressed);
  }

  Future<void> _loadAllAnimations() async {
    // Load animations state
    idleAnimation = await _loadAnimation('Main Character/Idle', 3);
    runAnimation = await _loadAnimation('Main Character/Run', 6);
    jumpAnimation = await _loadAnimation('Main Character/Jump', 4);
    fallAnimation = await _loadAnimation('Main Character/Fall', 2);

    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.run: runAnimation,
      PlayerState.jump: jumpAnimation,
      PlayerState.fall: fallAnimation,
    };

    // Set current animation
    current = PlayerState.idle;
  }

  // func to load animation
  Future<SpriteAnimation> _loadAnimation(String folder, int frameCount) async {
    // have to gameref each pic so have to rename the pic the folder to number for easier load
    final frames = await Future.wait(
      List.generate(frameCount, (i) => gameRef.images.load('$folder/$i.png')),
    );

    return SpriteAnimation.spriteList(
      frames.map((image) => Sprite(image)).toList(),
      stepTime: stepTime,
    );
  }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;

    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }

    // check if running, set run
    if (velocity.x > 0 || velocity.x < 0) {
      playerState = PlayerState.run;
    }

    // check if falling, set fall
    if (velocity.y > 0) {
      playerState = PlayerState.fall;
    }

    // check if jumping, set jump
    if (velocity.y < 0) {
      playerState = PlayerState.jump;
    }

    current = playerState;
  }

  void _updatePlayerMovement(double dt) {
    if (hasJumped && isOnGround) {
      _playerJump(dt);
    }
    // double timer = 0.0;
    // // if dont want jump while falling
    // if (velocity.y > _gravity) {
    //   isOnGround = false;
    // }

    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
  }

  void _playerJump(double dt) {
    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    isOnGround = false;
    hasJumped = false;
  }

  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      // handle collision
      if (!block.isPlatform) {
        // "this" is Player() cause we're in Player class
        if (checkCollsion(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - hitbox.offsetX - hitbox.width;
            break;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + hitbox.width + hitbox.offsetX;
            break;
          }
        }
      }
    }
  }

  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _checkVerticalCollisions() {
    for (final block in collisionBlocks) {
      if (block.isPlatform) {
        if (checkCollsion(this, block)) {
          velocity.y = 0;
          position.y = block.y - hitbox.height - hitbox.offsetY;
          isOnGround = true;
          break;
        }
      } else {
        if (checkCollsion(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height - hitbox.offsetY;
          }
        }
      }
    }
  }
}
