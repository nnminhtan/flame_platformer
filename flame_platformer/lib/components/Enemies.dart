import 'dart:async';
import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_platformer/components/player.dart';
import 'package:flame_platformer/flame_platformer.dart';

enum EnemyState { idle, run, attack }

class BaseEnemy extends SpriteAnimationGroupComponent
    with HasGameRef<FlamePlatformer>, CollisionCallbacks {
  final double offNeg;
  final double offPos;

  BaseEnemy({
    super.position,
    super.size,
    this.offNeg = 0,
    this.offPos = 0,
  });

  static const stepTime = 0.1;
  static const runSpeed = 80;
  final Vector2 textureSize = Vector2(150, 100);

  Vector2 velocity = Vector2.zero();
  double rangeNeg = 0;
  double rangePos = 0;
  double moveDirection = 1;
  double targetDirection = -1;
  bool gotStomped = false;
  bool isAttacking = false;

  late final Player player;

  @override
  FutureOr<void> onLoad() {
    debugMode = true;
    player = game.player;

    add(
      RectangleHitbox(
        position: Vector2(12, 3),
        size: Vector2(22, 40),
      ),
    );

    _calculateRange();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (!gotStomped) {
      _updateState();
      _movement(dt);
    }

    super.update(dt);
    checkAndAttackPlayer(player);
  }

  void checkAndAttackPlayer(Player player) {
    double distance = position.distanceTo(player.position);

    if (distance < 50) {
      attackPlayer(player);
    }
  }

  void attackPlayer(Player player) {
    if (!isAttacking) {
      isAttacking = true;
      current = EnemyState.attack; // Chuyển sang trạng thái tấn công

      double attackAnimationDuration =
          (animations?[EnemyState.attack]?.frames.length ?? 0) * stepTime;

      bool playerStillInHitbox = true;

      Future.delayed(
          Duration(milliseconds: (attackAnimationDuration * 1000).toInt()), () {
        if (playerStillInHitbox && playerInHitbox(player)) {
          Vector2 knockbackDirection;
          if (player.position.x > position.x) {
            knockbackDirection = Vector2(1, 0);
          } else {
            knockbackDirection = Vector2(-1, 0);
          }

          double knockbackStrength = 50;
          player.position.add(knockbackDirection * knockbackStrength);
        }

        isAttacking = false;
        current = EnemyState.idle; // Quay lại trạng thái idle
      });

      Future.delayed(
          Duration(milliseconds: (attackAnimationDuration * 1000).toInt()), () {
        playerStillInHitbox = playerInHitbox(player);
      });
    }
  }

  bool playerInHitbox(Player player) {
    return (player.position.x + player.width > position.x) &&
        (player.position.x < position.x + width) &&
        (player.position.y + player.height > position.y) &&
        (player.position.y < position.y + height);
  }

  void _calculateRange() {
    rangeNeg = position.x - offNeg * 16;
    rangePos = position.x + offPos * 16;
  }

  void _movement(double dt) {
    velocity.x = 0;

    double playerOffset = (player.scale.x > 0) ? 0 : -player.width;
    double enemyOffset = (scale.x > 0) ? 0 : -width;

    if (playerInRange()) {
      targetDirection =
          (player.x + playerOffset < position.x + enemyOffset) ? -1 : 1;
      velocity.x = targetDirection * runSpeed;
    }

    moveDirection = lerpDouble(moveDirection, targetDirection, 0.1) ?? 1;
    position.x += velocity.x * dt;
  }

  bool playerInRange() {
    double playerOffset = (player.scale.x > 0) ? 0 : -player.width;

    return player.x + playerOffset >= rangeNeg &&
        player.x + playerOffset <= rangePos &&
        player.y + player.height > position.y &&
        player.y < position.y + height;
  }

  void _updateState() {
    // Nếu enemy đang tấn công thì không thay đổi trạng thái
    if (isAttacking) return;
    current = (velocity.x != 0) ? EnemyState.run : EnemyState.idle;

    if ((moveDirection > 0 && scale.x < 0) ||
        (moveDirection < 0 && scale.x > 0)) {
      flipHorizontallyAroundCenter();
    }
  }
}
