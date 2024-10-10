import 'dart:async';
import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_platformer/components/player.dart';
import 'package:flame_platformer/flame_platformer.dart';

enum EnemyState { idle, run, attack }

class Enemies extends SpriteAnimationGroupComponent
    with HasGameRef<FlamePlatformer>, CollisionCallbacks {
  final double offNeg;
  final double offPos;

  Enemies({
    super.position,
    super.size,
    this.offNeg = 0,
    this.offPos = 0,
  });

  static const stepTime = 0.1;
  static const runSpeed = 50;
  final Vector2 textureSize = Vector2(150, 100);

  Vector2 velocity = Vector2.zero();
  double rangeNeg = 0;
  double rangePos = 0;
  double moveDirection = 1;
  double targetDirection = -1;
  bool gotStomped = false;
  bool isAttacking = false;

  double attackCooldown = 1.5;
  double cooldownTimer = 0.0;

  late final Player player;
  late final RectangleHitbox enemyHitbox;

  @override
  FutureOr<void> onLoad() {
    debugMode = true;
    player = game.player;

    enemyHitbox = RectangleHitbox(
      position: Vector2(30, 30),
      size: Vector2(26, 30),
    );

    add(enemyHitbox);

    _calculateRange();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (!gotStomped) {
      if (cooldownTimer > 0) {
        cooldownTimer -= dt;
        current = EnemyState.idle;
      } else {
        _updateState();
        _movement(dt);
      }
    }

    super.update(dt);
    checkAndAttackPlayer(player);
  }

  void checkAndAttackPlayer(Player player) {
    if (cooldownTimer <= 0 && enemyHitboxIntersectsPlayer(player)) {
      attackPlayer(player);
    }
  }

  void attackPlayer(Player player) {
    if (!isAttacking) {
      isAttacking = true;
      current = EnemyState.attack;

      double attackAnimationDuration =
          (animations?[EnemyState.attack]?.frames.length ?? 0) * stepTime;

      Future.delayed(
          Duration(milliseconds: (attackAnimationDuration * 1000).toInt()), () {
        // Chỉ thực hiện khi frame cuối của hoạt ảnh tấn công
        if (enemyHitboxIntersectsPlayer(player)) {
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
        cooldownTimer = attackCooldown;
        current = EnemyState.idle;
      });
    }
  }

  bool enemyHitboxIntersectsPlayer(Player player) {
    // Lấy hitbox của người chơi
    final playerHitbox =
        player.children.whereType<RectangleHitbox>().firstOrNull;

    // Kiểm tra nếu hitbox của người chơi tồn tại và nó giao nhau với hitbox của enemy
    if (playerHitbox != null) {
      return enemyHitbox.possiblyIntersects(playerHitbox);
    }
    return false;
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
    if (isAttacking) return;
    current = (velocity.x != 0) ? EnemyState.run : EnemyState.idle;

    if ((moveDirection > 0 && scale.x < 0) ||
        (moveDirection < 0 && scale.x > 0)) {
      flipHorizontallyAroundCenter();
    }
  }
}
