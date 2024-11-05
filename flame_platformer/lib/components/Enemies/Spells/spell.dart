import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_platformer/components/custom_hitbox.dart';
import 'package:flame_platformer/flame_platformer.dart';


class Spell extends SpriteAnimationComponent with HasGameRef<FlamePlatformer>, CollisionCallbacks {
  final String spell;
  final double? offNeg;
  final double? offPos;
  Spell({
    this.spell = 'Spear', position, size,
    this.offNeg,
    this.offPos,
  }) : super(position: position, size: size);

  // bool _collected = false;
  static const double stepTime = 0.15;

  late final SpriteAnimation _spearAnimation;
  late final SpriteAnimation _fireballAnimation;
  // late final SpriteAnimation _attackAnimation;
  // late var spellHitbox;
  late var hitbox = CustomHitbox.fromPreset('spell_spear');
  //spell movespeed
  static const moveSpeed = 50;
  static const tileSize = 16;
  double moveDirection = 1;
  double rangeNeg = 0;
  double rangePos = 0;
  
  @override
  Future<void> onLoad() async {
    debugMode = true;
    await _loadAllAnimations();
    if(spell == 'Spear'){
      hitbox = CustomHitbox.fromPreset('spell_spear');
    }else{
      hitbox = CustomHitbox.fromPreset('spell_fireball');
    }
    //movement of the fireball
    if(offNeg != null && offPos != null){
      rangeNeg = position.x - offNeg! * tileSize;
      rangePos = position.x + offPos! * tileSize;
    }
    // spellHitbox = CustomHitbox.fromPreset('skeletonAttack1');
    // add(spellHitbox); // Thêm hitbox vào component
    animation = getSpellAnimation(spell);
    int frameCount = animation!.frames.length;
    double attackAnimationDuration = frameCount * stepTime;

    Future.delayed(
          Duration(milliseconds: (attackAnimationDuration * 200).toInt()), () async {
      await add(RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height),
        collisionType: CollisionType.passive,
      ));
    });
    // priority = 0;
    // TODO: implement onLoad
    // animation = SpriteAnimation.fromFrameData(game.images.fromCache('Trap and Weapon/Arrow_Double_Jump.png'), 
    // SpriteAnimationData.sequenced(amount: 4, stepTime: stepTime, textureSize: Vector2.all(64)));
    return super.onLoad();
  }
  getSpellAnimation(String spellName) {
    switch (spellName) {
      case 'Spear':
          return _spearAnimation;
      case 'FireBall':
        return _fireballAnimation;
      // case 'Summon':
        
      //   break;
      default:
        return _spearAnimation;
    }
  }
  @override
  void update(double dt) {
    if(spell == 'FireBall'){
      _moveHorizontally(dt);
    }
    super.update(dt);
  }
  //currently there is no vertical spells yet
  // void _moveVertically(double dt) {
  //   if (position.y >= rangePos) {
  //     moveDirection = -1;
  //   } else if (position.y <= rangeNeg) {
  //     moveDirection = 1;
  //   }
  //   position.y += moveDirection * moveSpeed * dt;
  // }

  void _moveHorizontally(double dt) {
    if (position.x >= rangePos) {
      moveDirection = -1;
    } else if (position.x <= rangeNeg) {
      moveDirection = 1;
    }
    position.x += moveDirection * moveSpeed * dt;
  }
  
  Future<void> _loadAllAnimations() async {
    _fireballAnimation = await _loadAnimation('Fire_Ball', 10);
    _spearAnimation =  await _loadAnimation('Molten_Spear', 13)..loop = false;
  }
  // void collidedwithPlayer() {
  //   if(!_collected){
  //     if(game.playSounds) {
  //       FlameAudio.play('Pick item.mp3', volume: game.soundVolume);
  //     }
  //     animation = SpriteAnimation.fromFrameData(game.images.fromCache('Trap and Weapon/Collected.png'), 
  //     SpriteAnimationData.sequenced(amount: 6, stepTime: 0.05, textureSize: Vector2.all(32), loop: false));
  //     _collected = true;
  //     Future.delayed(const Duration(milliseconds: 500), () => removeFromParent());
  //     // removeFromParent();
  //   }
  // }

  Future<SpriteAnimation> _loadAnimation(String folder, int frameCount) async {
    // have to gameref each pic so have to rename the pic the folder to number for easier load
    final frames = await Future.wait(
      List.generate(frameCount, (i) => gameRef.images.load('Enemies/Monster/Spells/$folder/$i.png')),
    );

    return SpriteAnimation.spriteList(
      frames.map((image) => Sprite(image)).toList(),
      stepTime: stepTime,
      
    );
  }

}