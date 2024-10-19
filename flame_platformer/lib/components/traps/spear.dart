import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_platformer/components/custom_hitbox.dart';
import 'package:flame_platformer/flame_platformer.dart';

class Spear extends SpriteAnimationComponent with HasGameRef<FlamePlatformer>{
  Spear({position, size}) : super(position: position, size: size,);
  final hitbox = CustomHitbox.fromPreset('Spear');

  static const double stepTime = 0.2;
  @override
  FutureOr<void> onLoad() {
    // priority = -1;
    // debugMode = true;
    angle = 1.5708;

    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height),
      collisionType: CollisionType.active,
    ));

    // TODO: implement onLoad
    animation = SpriteAnimation.fromFrameData(game.images.fromCache('Trap and Weapon/Spear.png'), 
    SpriteAnimationData.sequenced(amount: 12, stepTime: stepTime, textureSize: Vector2(16, 64)));
    return super.onLoad();
  }
  
}