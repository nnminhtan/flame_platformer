import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame_platformer/components/Enemies/Enemies_withspells.dart';

class Necromancer extends EnemiesWithspells {
  Necromancer({
    required Vector2 position,
    required Vector2 size,
    required double offNeg,
    required double offPos,
    required double maxHp,
  }) : super(
            position: position,
            size: size,
            offNeg: offNeg,
            offPos: offPos,
            maxHp: maxHp);
  late final SpriteSheet spriteSheet;
  late final SpriteAnimation _idleAnimation;
  late final SpriteAnimation _runAnimation;
  late final SpriteAnimation _spell1Animation;
  late final SpriteAnimation _spell2Animation;
  late final SpriteAnimation _summonAnimation;
  late final SpriteAnimation _teleportAnimation;
  late final SpriteAnimation _dieAnimation;
  
  late final RectangleHitbox skeletonHitbox;

  @override
  Future<void> onLoad() async {
    debugMode = true;
    skeletonHitbox = RectangleHitbox(
      position: Vector2(30, 30), // Vị trí và kích thước riêng cho Skeleton
      size: Vector2(60, 80),
    );
    add(skeletonHitbox); // Thêm hitbox vào component
    await _spriteAnimation();
    _loadAllAnimations();
    current = EnemyState.idle; // Đặt trạng thái ban đầu

    await super.onLoad(); // Đảm bảo gọi onLoad của lớp cha
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  // Ghi đè phương thức getHitbox để trả về skeletonHitbox
  @override
  RectangleHitbox getHitbox() {
    return skeletonHitbox;
  }
  void _loadAllAnimations() {
    _idleAnimation = spriteSheet.createAnimation(row: 0, stepTime: 0.15, from: 0 ,to: 7);
    _runAnimation = spriteSheet.createAnimation(row: 1, stepTime: 0.15, from: 0 ,to: 7);
    _summonAnimation = spriteSheet.createAnimation(row: 2, stepTime: 0.15, from: 0 ,to: 12);
    _spell1Animation = spriteSheet.createAnimation(row: 3, stepTime: 0.15, from: 0 ,to: 12);
    _spell2Animation = spriteSheet.createAnimation(row: 4, stepTime: 0.15, from: 0 ,to: 16);
    _teleportAnimation = spriteSheet.createAnimation(row: 5, stepTime: 0.15, from: 0 ,to: 4);
    _dieAnimation = spriteSheet.createAnimation(row: 6, stepTime: 0.15, from: 0 ,to: 8);


    animations = {
      EnemyState.idle: _idleAnimation,
      EnemyState.run: _runAnimation,
      EnemyState.summon: _summonAnimation,
      EnemyState.spell1: _spell1Animation,
      EnemyState.spell2: _spell2Animation,
      EnemyState.teleport: _teleportAnimation,
      EnemyState.die: _dieAnimation,
    };
  }

  Future<void> _spriteAnimation() async {
    spriteSheet = SpriteSheet(
      image: await game.images.fromCache('Enemies/Monster/Necromancer/Necromancer_Sheet.png'), 
      srcSize: Vector2(160,128));
    // SpriteAnimation idlespriteAnimation = spriteSheet.createAnimation(row: 0, stepTime: 0.1, from: 0 ,to: 7);
  }
}
