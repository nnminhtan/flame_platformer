import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_platformer/components/Enemies.dart';

class Skeleton extends Enemies {
  Skeleton({
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

  late final SpriteAnimation _idleAnimation;
  late final SpriteAnimation _runAnimation;
  late final SpriteAnimation _attackAnimation;
  late final RectangleHitbox skeletonHitbox;

  @override
  Future<void> onLoad() async {
    skeletonHitbox = RectangleHitbox(
      position: Vector2(45, 55), // Vị trí và kích thước riêng cho Skeleton
      size: Vector2(40, 55),
    );
    add(skeletonHitbox); // Thêm hitbox vào component

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
    _idleAnimation = _spriteAnimation('Skeleton/Idle', 4);
    _runAnimation = _spriteAnimation('Skeleton/Walk', 4);
    _attackAnimation = _spriteAnimation('Skeleton/Attack', 8)..loop = false;

    animations = {
      EnemyState.idle: _idleAnimation,
      EnemyState.run: _runAnimation,
      EnemyState.attack: _attackAnimation,
    };
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Enemies/Monster/$state.png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: Enemies.stepTime,
        textureSize: textureSize,
      ),
    );
  }
}
