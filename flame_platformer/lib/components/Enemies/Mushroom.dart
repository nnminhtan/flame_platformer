import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_platformer/components/Enemies/Enemies.dart';

class Mushroom extends Enemies {
  Mushroom({
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
  late final RectangleHitbox mushroomHitbox;

  @override
  Future<void> onLoad() async {
    _loadAllAnimations();
    current = EnemyState.idle; // Đặt trạng thái ban đầu

    mushroomHitbox = RectangleHitbox(
      position: Vector2(25, 33),
      size: Vector2(22, 30),
    );

    add(mushroomHitbox); // Thêm hitbox vào component

    await super.onLoad(); // Đảm bảo gọi onLoad của lớp cha
  }

  // Ghi đè phương thức getHitbox để trả về skeletonHitbox
  @override
  RectangleHitbox getHitbox() {
    return mushroomHitbox;
  }

  void _loadAllAnimations() {
    _idleAnimation = _spriteAnimation('Mushroom/Idle', 4);
    _runAnimation = _spriteAnimation('Mushroom/Run', 8);
    _attackAnimation = _spriteAnimation('Mushroom/Attack', 8)..loop = false;

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
