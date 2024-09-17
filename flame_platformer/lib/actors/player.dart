import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_platformer/flame_platformer.dart';

enum PlayerState { idle, run, jump }

enum PlayerDirection {
  left,
  right,
  none,
}

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<flameplatformer> {
  Player({required position}) : super(position: position);

  // for animation
  late final SpriteAnimation idleAnimation;
  final double stepTime = 0.5;
  Vector2 velocity = Vector2.zero();

  // for movement
  PlayerDirection playerDirection = PlayerDirection.none;
  double moveSpeed = 100;

  @override
  FutureOr<void> onLoad() async {
    await _loadAllAnimations();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updatePlayerMovement(dt);
    super.update(dt);
  }

  Future<void> _loadAllAnimations() async {
    // Load animations state
    final idleAnimation = await _loadAnimation('Main Character/Idle', 3);
    final runAnimation = await _loadAnimation('Main Character/Run', 5);
    final jumpAnimation = await _loadAnimation('Main Character/Jump', 4);

    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.run: runAnimation,
      PlayerState.jump: jumpAnimation,
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

  void _updatePlayerMovement(double dt) {
    double dirX = 0.0;
    switch (playerDirection) {
      case PlayerDirection.left:
        current = PlayerState.run;
        dirX -= moveSpeed;
        break;
      case PlayerDirection.right:
        current = PlayerState.run;
        dirX += moveSpeed;
        break;
      case PlayerDirection.none:
        current = PlayerState.idle;
        break;
    }

    velocity = Vector2(dirX, 0.0);
    position += velocity * dt;
  }
}
