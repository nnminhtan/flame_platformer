import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_platformer/components/Enemies/Flyingeye.dart';
import 'package:flame_platformer/components/Enemies/Mushroom.dart';
import 'package:flame_platformer/components/Enemies/Skeleton.dart';
import 'package:flame_platformer/components/Enemies/Spells/spell.dart';
import 'package:flame_platformer/components/Enemies/necromancer.dart';
import 'package:flame_platformer/components/custom_hitbox.dart';
import 'package:flame_platformer/components/level.dart';
import 'package:flame_platformer/components/player.dart';
import 'package:flame_platformer/flame_platformer.dart';

enum EnemyState { idle, run, summon, spell1, spell2, teleport, die}


abstract class EnemiesWithspells extends SpriteAnimationGroupComponent
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
  // = CustomHitbox.fromPreset(enemyHitbox);


  EnemiesWithspells({
    super.position,
    super.size,
    this.offNeg = 0,
    this.offPos = 0,
    required this.maxHp,
  }) : hp = maxHp;

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

  Level get level => gameRef.children.firstWhere((component) => component is Level) as Level;
  late final Player player;
  late Spell spell;
  RectangleHitbox getHitbox(); //lấy hitbox từ lớp con

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    player = game.player;
    if (enemyHitbox.isEmpty) {
      // Initialize to a default value if it hasn’t been set
      enemyHitbox = ''; // Optional: Set a reasonable default here
    }
    hitbox = CustomHitbox.fromPreset(enemyHitbox);
    addAttackHitbox();
    remove(attackHitbox);
    _calculateRange();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    hitbox = CustomHitbox.fromPreset(enemyHitbox);
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
  if (attacker is Necromancer) {
    return 'skeletonAttack1';
  }
}
  EnemyState getRandomState() {
    final random = Random();
    int index = random.nextInt(5);  // Generates a random integer between 0 and 2

    switch (index) {
      case 0:
      case 3:
        return EnemyState.spell1;
      case 1:
      case 4:
        return EnemyState.spell2;
      case 2:
        return EnemyState.summon;
      default:
        return EnemyState.spell1;  // Fallback, although it won't reach here
    }
  }

  //Tấn công người chơi
  void attackPlayer(Player player) {
    if (!isAttacking) {
      isAttacking = true;
      current = getRandomState();
      switch (current) {
        //Spear drop
        case EnemyState.spell1:
            // hitbox = CustomHitbox.fromPreset(enemyHitboxMap[current]!);
            enemyHitbox = checkWhoIsAttacking(this, player);

            double attackAnimationDuration =
                (animations?[EnemyState.spell1]?.frames.length ?? 0) * stepTime;
            Future.delayed(
                Duration(milliseconds: (attackAnimationDuration * 1000).toInt()), () async {
              level.addSpell('Spear', Vector2(player.position.x-32, player.position.y-32), Vector2(32, 16*4), null, null);
              isAttacking = false;
              cooldownTimer = attackCooldown;
              current = EnemyState.idle;
            });
            Future.delayed(
                Duration(milliseconds: (attackAnimationDuration * 3000).toInt()), () async {
              level.removeSpell('Spear');
            });
          break;
        //Fire ball
        case EnemyState.spell2:
          enemyHitbox = checkWhoIsAttacking(this, player);
            double attackAnimationDuration =
                (animations?[EnemyState.spell1]?.frames.length ?? 0) * stepTime;
            Future.delayed(
                Duration(milliseconds: (attackAnimationDuration * 1000).toInt()), () async {
              level.addSpell('FireBall', Vector2(position.x+50, position.y+80), Vector2(16*4, 32), 20, 20);
              isAttacking = false;
              cooldownTimer = attackCooldown;
              current = EnemyState.idle;
            });
            Future.delayed(
                Duration(milliseconds: (attackAnimationDuration * 4000).toInt()), () async {
              level.removeSpell('FireBall');
            });
          break;
        //summoning a mob
        case EnemyState.summon:
          enemyHitbox = checkWhoIsAttacking(this, player);

            double attackAnimationDuration =
                (animations?[EnemyState.spell1]?.frames.length ?? 0) * stepTime;
            Future.delayed(
                Duration(milliseconds: (attackAnimationDuration * 1000).toInt()), () async {
              level.summonEntities('Skeleton', 30, 30, Vector2(position.x+32, position.y+16), Vector2(40*2, 55*2));
              isAttacking = false;
              cooldownTimer = attackCooldown;
              current = EnemyState.idle;
            });
          break;
        default:
      }
    }
  }

  //Kiểm tra hitbox của người chơi và quái
  bool enemyHitboxIntersectsPlayer(Player player) {
    // Lấy hitbox của người chơi
    final playerHitbox =
        player.children.whereType<RectangleHitbox>().firstOrNull;
    if (attackHitbox == null) {
      return false; // Return false if the hitbox is not initialized
    }
    // Lấy hitbox của enemy từ phương thức getHitbox (do lớp con cung cấp)
    final enemyHitbox = attackHitbox;

    // Kiểm tra nếu hitbox của người chơi tồn tại và nó giao nhau với hitbox của enemy
    if (playerHitbox != null && enemyHitbox != null) {
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
