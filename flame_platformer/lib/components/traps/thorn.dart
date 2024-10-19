import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_platformer/components/custom_hitbox.dart';
import 'package:flame_platformer/flame_platformer.dart';

class Thorn extends SpriteAnimationComponent with HasGameRef<FlamePlatformer>{
  Thorn({position, size}) : super(position: position, size: size,);
  final hitbox = CustomHitbox.fromPreset('Thorn');

  static const double stepTime = 0.2;
  @override
  FutureOr<void> onLoad() {
    // priority = -1;
    // debugMode = true;

    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height),
      collisionType: CollisionType.active,
    ));

    // TODO: implement onLoad
    animation = SpriteAnimation.fromFrameData(game.images.fromCache('Trap and Weapon/Spike_B.png'), 
    SpriteAnimationData.sequenced(amount: 20, stepTime: stepTime, textureSize: Vector2(16, 32)));
    return super.onLoad();
  }
  
}