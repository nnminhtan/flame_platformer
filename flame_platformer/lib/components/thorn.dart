import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_platformer/flame_platformer.dart';

class Thorn extends SpriteAnimationComponent with HasGameRef<FlamePlatformer>{
  Thorn({position, size}) : super(position: position, size: size,);

  static const double stepTime = 0.5;
  @override
  FutureOr<void> onLoad() {
    // TODO: implement onLoad
    animation = SpriteAnimation.fromFrameData(game.images.fromCache('Trap and Weapon/Spear.png'), 
    SpriteAnimationData.sequenced(amount: 12, stepTime: stepTime, textureSize: Vector2(16, 64)));
    return super.onLoad();
  }
  
}