import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Obstacle extends PositionComponent with CollisionCallbacks {
  Obstacle({
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    add(RectangleHitbox()); // Thêm RectangleHitbox để enemy có thể va chạm
    debugMode =
        true; // Bật chế độ debug để thấy hitbox trong quá trình phát triển
  }
}
