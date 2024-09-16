import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_platformer/flame_platformer.dart';

enum PlayerState { idle }

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<flameplatformer> {
  Player({required position}) : super(position: position);

  late final SpriteAnimation idleAnimation;
  final double stepTime = 0.05;

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimation(); // TODO: implement onLoad
    return super.onLoad();
  }

  void _loadAllAnimation() {
    idleAnimation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Character/adventurer-v1.5-Sheet.png'),
      SpriteAnimationData.sequenced(
        amount: 3,
        stepTime: stepTime,
        textureSize: Vector2.all(16),
      ),
    );

    // list of animations
    animations = {PlayerState.idle: idleAnimation};

    // current animation
    current = PlayerState.idle;
  }
}
