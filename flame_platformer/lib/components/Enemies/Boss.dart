import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_platformer/components/Enemies/Enemies.dart';

class Boss extends Enemies {
  Boss({
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
  late final RectangleHitbox BossHitbox;
  final Vector2 textureSize = Vector2(80, 80);

  @override
  Future<void> onLoad() async {
    BossHitbox = RectangleHitbox(
      position: Vector2(25, 15), // Vị trí và kích thước riêng
      size: Vector2(40, 100),
    );
    add(BossHitbox); // Thêm hitbox vào component

    await _loadAllAnimations();
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
    return BossHitbox;
  }

  Future<void> _loadAllAnimations() async {
    _idleAnimation = await _loadAnimation('Boss/Idle', 6, 0.1);
    _runAnimation = await _loadAnimation('Boss/Run', 12, 0.1);
    _attackAnimation = await _loadAnimation('Boss/Attacks', 7, 0.1)
      ..loop = false;

    animations = {
      EnemyState.idle: _idleAnimation,
      EnemyState.run: _runAnimation,
      EnemyState.attack: _attackAnimation,
    };
  }

  Future<SpriteAnimation> _loadAnimation(
      String folder, int frameCount, double stepTime) async {
    // have to gameref each pic so have to rename the pic the folder to number for easier load
    final frames = await Future.wait(
      List.generate(frameCount, (i) => gameRef.images.load('$folder/$i.png')),
    );
    return SpriteAnimation.spriteList(
      frames.map((image) => Sprite(image, srcSize: textureSize)).toList(),
      stepTime: stepTime,
    );
  }
}
