import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_platformer/components/custom_hitbox.dart';
import 'package:flame_platformer/components/player.dart';
import 'package:flame_platformer/flame_platformer.dart';

class Checkpoint extends SpriteAnimationComponent with HasGameRef<FlamePlatformer>, CollisionCallbacks{
  Checkpoint({position, size}) : super(position: position, size: size,);
  final hitbox = CustomHitbox(offsetX: 10, offsetY: 20, width: 40, height: 40);

  bool reachedCheckpoint = false;
  static const double stepTime = 0.2;
  @override
  FutureOr<void> onLoad() {
    debugMode = true;

    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height),
      collisionType: CollisionType.passive,
    ));

    // TODO: implement onLoad
    // animation = SpriteAnimation.fromFrameData(game.images.fromCache('Trap and Weapon/Spike_B.png'), 
    // SpriteAnimationData.sequenced(amount: 20, stepTime: stepTime, textureSize: Vector2(16, 32)));
    return super.onLoad();
  }
  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player && !reachedCheckpoint) _reachedCheckpoint();
    super.onCollisionStart(intersectionPoints, other);
  }
  
  void _reachedCheckpoint() {
    reachedCheckpoint = true;
  }

}