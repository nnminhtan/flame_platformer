import 'package:flame/components.dart';
import 'package:flame_platformer/components/Enemies.dart';

class Skeleton extends BaseEnemy {
  Skeleton({
    required Vector2 position,
    required Vector2 size,
    required double offNeg,
    required double offPos,
  }) : super(position: position, size: size, offNeg: offNeg, offPos: offPos);

  late final SpriteAnimation _idleAnimation;
  late final SpriteAnimation _runAnimation;
  late final SpriteAnimation _attackAnimation;

  @override
  Future<void> onLoad() async {
    await super.onLoad(); // Đảm bảo gọi onLoad của lớp cha

    _loadAllAnimations();
    current = EnemyState.idle; // Đặt trạng thái ban đầu
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
        stepTime: BaseEnemy.stepTime,
        textureSize: textureSize,
      ),
    );
  }
}
