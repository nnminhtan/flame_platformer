import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_platformer/components/custom_hitbox.dart';
import 'package:flame_platformer/flame_platformer.dart';

class BgmCheckpoint extends SpriteAnimationComponent with HasGameRef<FlamePlatformer>{
  final String spot;
  BgmCheckpoint({this.spot = 'Ground', position, size}) : super(position: position, size: size,);
  final hitbox = CustomHitbox.fromPreset('Bgm_Loader');

  @override
  FutureOr<void> onLoad() {
    // priority = -1;
    // debugMode = true;

    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height),
      collisionType: CollisionType.active,
    ));
    return super.onLoad();
  }
  
}