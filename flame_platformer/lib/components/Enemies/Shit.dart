import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_platformer/components/custom_hitbox.dart';
import 'package:flame_platformer/components/player.dart';
import 'package:flame_platformer/flame_platformer.dart';

enum State {
  idle,
  run,
  attack,
  attack2,
  attack3,
}

class Shit extends SpriteAnimationGroupComponent
    with HasGameRef<FlamePlatformer>, CollisionCallbacks {
  final double offNeg;
  final double offPos;

  double hp = 100.0;
  final double maxHp;
  //hitbox for enemies
  // Map<EnemyState, String> enemyHitboxMap = {
  //   EnemyState.attack: 'skeletonAttack1',
  // };
  String enemyHitbox = '';
  late RectangleHitbox attackHitbox; // Store the hitbox to remove it later
  late var hitbox;
  Shit({
    super.position,
    super.size,
    this.offNeg = 0,
    this.offPos = 0,
    required this.maxHp,
  }) : hp = maxHp;

  static const stepTime = 0.1;
  static const runSpeed = 50;
  final Vector2 textureSize = Vector2(100, 90);

  Vector2 velocity = Vector2.zero();
  double rangeNeg = 0;
  double rangePos = 0;
  double moveDirection = 1;
  double targetDirection = -1;
  bool gotStomped = false;
  bool isAttacking = false;
  late final RectangleHitbox BossHitbox;

  double attackCooldown = 1.5;
  double cooldownTimer = 0.0;

  late final Player player;
  late final SpriteAnimation _idleAnimation;
  late final SpriteAnimation _runAnimation;
  late final SpriteAnimation _attackAnimation;
  late final SpriteAnimation _attackAnimation2;
  late final SpriteAnimation _attackAnimation3;

  @override
  FutureOr<void> onLoad() async {
    debugMode = true;
    player = game.player;

    BossHitbox = RectangleHitbox(
      position: Vector2(30, 35), // Vị trí và kích thước riêng
      size: Vector2(25, 30),
    );
    await _loadAllAnimations();
    if (enemyHitbox.isEmpty) {
      // Initialize to a default value if it hasn’t been set
      enemyHitbox = ''; // Optional: Set a reasonable default here
    }
    hitbox = CustomHitbox.fromPreset(enemyHitbox);
    addAttackHitbox();
    remove(attackHitbox);
    _calculateRange();
    add(getHitbox());
    return super.onLoad();
  }

  @override
  void update(double dt) {
    hitbox = CustomHitbox.fromPreset(enemyHitbox);
    if (!gotStomped) {
      if (cooldownTimer > 0) {
        cooldownTimer -= dt;
        current = State.idle;
      } else {
        _updateState();
        _movement(dt);
      }
    }
    super.update(dt);
    checkAndAttackPlayer(player);
  }

  @override
  RectangleHitbox getHitbox() {
    return BossHitbox;
  }

  Future<void> _loadAllAnimations() async {
    _idleAnimation = await _loadAnimation('Shit/Idle', 4, 0.1);
    _runAnimation = await _loadAnimation('Shit/Run', 4, 0.1);
    _attackAnimation = await _loadAnimation('Shit/Attacks', 10, 0.1)
      ..loop = false;
    _attackAnimation2 = await _loadAnimation('Shit/Attacks2', 11, 0.1)
      ..loop = false;
    _attackAnimation3 = await _loadAnimation('Shit/Attacks3', 8, 0.1)
      ..loop = false;

    animations = {
      State.idle: _idleAnimation,
      State.run: _runAnimation,
      State.attack: _attackAnimation,
      State.attack2: _attackAnimation2,
      State.attack3: _attackAnimation3,
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

  //Kiểm tra hết Cooldown và người chơi có trong hitbox không để thực hiện attack
  void checkAndAttackPlayer(Player player) {
    // Tính khoảng cách giữa quái vật và người chơi
    double attackRange = 10.0; // Định nghĩa khoảng cách tấn công

    // Kiểm tra xem người chơi có nằm trong khoảng cách tấn công không
    bool isInAttackRange =
        (player.position.x + player.width >= position.x - attackRange &&
                player.position.x <= position.x + width + attackRange) &&
            (player.position.y + player.height >= position.y - attackRange &&
                player.position.y <= position.y + height + attackRange);

    if (cooldownTimer <= 0 && isInAttackRange) {
      if (player.position.x > position.x) {
        // Người chơi ở bên phải
        if (scale.x < 0) {
          flipHorizontallyAroundCenter();
        }
      } else {
        // Người chơi ở bên trái
        if (scale.x > 0) {
          flipHorizontallyAroundCenter();
        }
      }

      // Thực hiện tấn công
      attackPlayer(player);
    }
  }

  checkWhoIsAttacking(PositionComponent attacker, Player player) {
    if (attacker is Shit) {
      if (current == State.attack) {
        return 'shitAttack1';
      } else if (current == State.attack2) {
        return 'shitAttack2';
      } else if (current == State.attack3) {
        return 'shitAttack3';
      }
    }
  }

  //Tấn công người chơi
  void attackPlayer(Player player) {
    if (!isAttacking) {
      isAttacking = true;

      final attackAnimationKey =
          State.values[Random().nextInt(3) + 2]; // attack2 đến attack5
      current = attackAnimationKey;

      enemyHitbox = checkWhoIsAttacking(this, player);

      double attackAnimationDuration =
          (animations?[attackAnimationKey]?.frames.length ?? 0) * stepTime;
      Future.delayed(
        Duration(milliseconds: (attackAnimationDuration * 700).toInt()),
        () async {
          // Chỉ thực hiện khi frame cuối của hoạt ảnh tấn công
          await addAttackHitbox();

          Future.delayed(const Duration(milliseconds: 50), () {
            if (enemyHitboxIntersectsPlayer(player)) {
              Vector2 knockbackDirection;
              if (player.position.x > position.x) {
                knockbackDirection = Vector2(1, 0);
              } else {
                knockbackDirection = Vector2(-1, 0);
              }
              double knockbackStrength = 50;
              player.position.add(knockbackDirection * knockbackStrength);
              // player.takeDamage(20);
            }
          });

          isAttacking = false;

          // Tạo cooldown ngẫu nhiên trong khoảng từ 1 đến 3 giây (hoặc theo ý bạn muốn)
          cooldownTimer = cooldownTimer =
              (Random().nextInt(1001) + 500).toDouble() /
                  1000; // tính theo giây
          current = State.idle;

          Future.delayed(const Duration(milliseconds: 200), () {
            remove(attackHitbox);
          });
        },
      );
    }
  }

  //Kiểm tra hitbox của người chơi và quái
  bool enemyHitboxIntersectsPlayer(Player player) {
    // Lấy hitbox của người chơi
    final playerHitbox =
        player.children.whereType<RectangleHitbox>().firstOrNull;
    // Lấy hitbox của enemy từ phương thức getHitbox (do lớp con cung cấp)
    final enemyHitbox = attackHitbox;

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
    current = (velocity.x != 0) ? State.run : State.idle;

    if ((moveDirection > 0 && scale.x < 0) ||
        (moveDirection < 0 && scale.x > 0)) {
      flipHorizontallyAroundCenter();
    }
  }

  void takeDamage(double damage) {
    hp -= damage;
    hp = hp.clamp(0, 150);
    print("Enemy HP: $hp");
    if (hp <= 0) {
      die();
    }
  }

  addAttackHitbox() {
    attackHitbox = RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height),
      // collisionType: CollisionType.passive,
    );
    add(attackHitbox);
  }

  void die() {
    removeFromParent();
  }
}
