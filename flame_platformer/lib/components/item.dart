import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_platformer/components/custom_hitbox.dart';
import 'package:flame_platformer/flame_platformer.dart';

class Item extends SpriteAnimationComponent with HasGameRef<FlamePlatformer>, CollisionCallbacks {
  final String item;
  Item({
    this.item = 'Coin', position, size,
  }) : super(position: position, size: size);

  bool _collected = false;
  static const double stepTime = 0.15;
  final hitbox = CustomHitbox(offsetX: 4, offsetY: 4, width: 24, height: 24);


  @override
  FutureOr<void> onLoad() {
    // debugMode = true;

    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height),
      collisionType: CollisionType.passive,
    ));

    // priority = 0;
    // TODO: implement onLoad
    animation = SpriteAnimation.fromFrameData(game.images.fromCache('Trap and Weapon/Arrow_Double_Jump.png'), 
    SpriteAnimationData.sequenced(amount: 4, stepTime: stepTime, textureSize: Vector2.all(16)));
    return super.onLoad();
  }
  
  void collidedwithPlayer() {
    if(!_collected){
      if(game.playSounds) {
        FlameAudio.play('Pick item.mp3', volume: game.soundVolume);
      }
      animation = SpriteAnimation.fromFrameData(game.images.fromCache('Trap and Weapon/Collected.png'), 
      SpriteAnimationData.sequenced(amount: 6, stepTime: 0.05, textureSize: Vector2.all(32), loop: false));
      _collected = true;
      Future.delayed(const Duration(milliseconds: 500), () => removeFromParent());
      // removeFromParent();
    }
  }
}