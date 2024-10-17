import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_platformer/components/Enemies/Enemies.dart';
import 'package:flame_platformer/components/Enemies/Skeleton.dart';
import 'package:flame_platformer/components/checkpoint.dart';
import 'package:flame_platformer/components/collision_block.dart';
import 'package:flame_platformer/components/custom_hitbox.dart';
import 'package:flame_platformer/components/item.dart';
import 'package:flame_platformer/components/traps/spear.dart';
import 'package:flame_platformer/components/traps/thorn.dart';
import 'package:flame_platformer/components/utils.dart';
import 'package:flame_platformer/flame_platformer.dart';
import 'package:flutter/services.dart';

enum PlayerState {
  idle,
  run,
  jump,
  fall,
  normalAttack,
  upAttack,
  hurt,
  die,
}

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<FlamePlatformer>, KeyboardHandler, CollisionCallbacks {
  Player({position}) : super(position: position);
  //default PlayerState
  PlayerState playerState = PlayerState.idle;
  // hp
  double hp = 100.0;
  final double maxHp = 100.0;

  // for attack logic
  double attackTimer = 0.0;
  final double attackDuration = 0.75;
  bool isAttacking = false;
  bool isUpAttack = false;

  //spawn point default
  Vector2 startingPosition = Vector2.zero();

  // for animation
  final double stepTime = 0.15;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runAnimation;
  late final SpriteAnimation jumpAnimation;
  late final SpriteAnimation fallAnimation;
  late final SpriteAnimation normalAttackAnimation;
  late final SpriteAnimation upAttackAnimation;
  late final SpriteAnimation hurtAnimation;
  late final SpriteAnimation dieAnimation;

  // for movement
  double horizontalMovement = 0;
  double moveSpeed = 110;
  Vector2 velocity = Vector2.zero();

  // for environment interaction
  List<CollisionBlock> collisionBlocks = [];
  final double _gravity = 9.8;
  final double _jumpForce = 250; //460
  final double _terminalVelocity = 300;

  //checkpoint
  bool reachedCheckpoint = false;

  double hurtCooldown = 2.0; // 2-second cooldown
  double _cooldownTimer = 0.0; // Track remaining cooldown time
  bool gotHit = false;
  bool isAttacked = false;
  // int _hitTime = 0;

  bool isOnGround = false;
  bool hasJumped = false;
  CustomHitbox hitbox = CustomHitbox(
    offsetX: 14,
    offsetY: 4,
    width: 21,
    height: 30,
  );

  @override
  FutureOr<void> onLoad() async {
    //set player spawnpoint
    startingPosition = Vector2(position.x, position.y);

    await _loadAllAnimations();
    debugMode = true;
    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height),
    ));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (!gotHit && !reachedCheckpoint) {
      _updatePlayerState();
      _updatePlayerMovement(dt);
      // will add logic to fix attack movement is seperated
      if (attackTimer > 0) {
        attackTimer -= dt;
        if (attackTimer <= 0) {
          isAttacking = false;
        }
      }
      _checkHorizontalCollisions();
      _applyGravity(dt);
      _checkVerticalCollisions();
    }
    if (_cooldownTimer > 0) {
      _cooldownTimer -= dt;
    }
    if(hp <= 0){
      _respawn();
    }

    super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // TODO: implement onKeyEvent
    horizontalMovement = 0;
    //Set the which key is pressed
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);
    // final isUpKeyPressed = keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
    //     keysPressed.contains(LogicalKeyboardKey.keyW);
    final isAttackKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyJ);

    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;

    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);

    // still got error with up attack so add more later
    if (isAttackKeyPressed && !isAttacking) {
      isAttacking = true;
      attackTimer = attackDuration;
    }

    return super.onKeyEvent(event, keysPressed);
  }

  Future<void> _loadAllAnimations() async {
    // Load animations state
    idleAnimation = await _loadAnimation('Main Character/Idle', 3);
    runAnimation = await _loadAnimation('Main Character/Run', 6);
    jumpAnimation = await _loadAnimation('Main Character/Jump', 4);
    fallAnimation = await _loadAnimation('Main Character/Fall', 2);
    normalAttackAnimation =
        await _loadAnimation('Main Character/Normal_Attack', 6);
    upAttackAnimation = await _loadAnimation('Main Character/Up_Attack', 5);
    hurtAnimation = await _loadAnimation('Main Character/Hurt', 6);
    dieAnimation = await _loadAnimation('Main Character/Die', 10)
      ..loop = false;

    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.run: runAnimation,
      PlayerState.jump: jumpAnimation,
      PlayerState.fall: fallAnimation,
      PlayerState.normalAttack: normalAttackAnimation,
      PlayerState.upAttack: upAttackAnimation,
      PlayerState.hurt: hurtAnimation,
      PlayerState.die: dieAnimation,
    };

    // Set current animation
    current = PlayerState.idle;
  }

  // func to load animation
  Future<SpriteAnimation> _loadAnimation(String folder, int frameCount) async {
    // have to gameref each pic so have to rename the pic the folder to number for easier load
    final frames = await Future.wait(
      List.generate(frameCount, (i) => gameRef.images.load('$folder/$i.png')),
    );

    return SpriteAnimation.spriteList(
      frames.map((image) => Sprite(image)).toList(),
      stepTime: stepTime,
    );
  }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;

    // check flip animation first
    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }

    // check logic attack
    if (isAttacking) {
      playerState = PlayerState.normalAttack;
    } else {
      // check if running, set run
      if (velocity.x > 0 || velocity.x < 0) {
        playerState = PlayerState.run;
      }

      // check if falling, set fall
      if (velocity.y > 0 && !gotHit) {
        playerState = PlayerState.fall;
      }

      // check if jumping, set jump
      if (velocity.y < 0) {
        playerState = PlayerState.jump;
      }
    }

    current = playerState;
  }

  void _updatePlayerMovement(double dt) {
    if (hasJumped && isOnGround) {
      _playerJump(dt);
    }
    // double timer = 0.0;
    // // if dont want jump while falling
    // if (velocity.y > _gravity) {
    //   isOnGround = false;
    // }

    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
  }

  void _playerJump(double dt) {
    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    isOnGround = false;
    hasJumped = false;
  }

  void attack() {
    if (!isAttacking) {
      // Kiểm tra nếu player chưa đang tấn công
      isAttacking = true;
      attackTimer = attackDuration; // Đặt thời gian tấn công
      playerState = PlayerState.normalAttack; // Đặt trạng thái tấn công
    }
  }

  //player collied with object
  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    
    if(!reachedCheckpoint){
      if (other is Enemies && isAttacking) {
        other.takeDamage(20);
      }

      if (other is Item) {
        other.collidedwithPlayer();
      }

      if (((other is Skeleton) && other.attackHitbox.isColliding) && 
          (_cooldownTimer <= 0 && gotHit == false && isAttacked == false)) {
        isAttacked = true;
        // Future.delayed(const Duration(milliseconds: 1300), () {
          takeDamage(20);
          _cooldownTimer = hurtCooldown;
        // });
        Future.delayed(const Duration(milliseconds: 1000), () { 
          isAttacked = false;
        });
      }
      

      if ((other is Thorn || other is Spear) &&
          (_cooldownTimer <= 0 && gotHit == false)) {
        if (hp > 0) {
          takeDamage(10);
          _cooldownTimer = hurtCooldown;
        }
      }
      if(other is Checkpoint) _reachedCheckpoint();
    }
    super.onCollision(intersectionPoints, other);
  }

  // void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
  //   if (!reachedCheckpoint) {
  //     // Determine the type of the 'other' object
  //     switch (other.runtimeType) {
  //       // Case 1: Collision with Enemies
  //       case Enemies:
  //         if (isAttacking) {
  //           (other as Enemies).takeDamage(20);
  //         }
  //         break;

  //       // Case 2: Collision with an Item
  //       case Item:
  //         (other as Item).collidedwithPlayer();
  //         break;

  //       // Case 3: Collision with Skeleton's attack hitbox
  //       case Skeleton:
  //         if ((!(other as Skeleton).attackHitbox.isColliding) && 
  //         (_cooldownTimer <= 0 && gotHit == false && isAttacked == false)) {
  //             isAttacked = true;
  //             // Future.delayed(const Duration(milliseconds: 1300), () {
  //               // takeDamage(20);
  //               _cooldownTimer = hurtCooldown;
  //             // });
  //             Future.delayed(const Duration(milliseconds: 1000), () { 
  //               isAttacked = false;
  //             });
  //         }
  //         break;
        
  //       // Case 4: Collision with Thorn or Spear
  //       case Thorn:
  //       case Spear:
  //         if (_cooldownTimer <= 0 && gotHit == false) {
  //           if (hp > 0) {
  //             takeDamage(10);
  //             _cooldownTimer = hurtCooldown;
  //           }
  //         }
  //         break;

  //       // Case 5: Collision with Checkpoint
  //       case Checkpoint:
  //         _reachedCheckpoint();
  //         break;

  //       // Default case: No specific action for other object types
  //       default:
  //         break;
  //     }
  //     if (other is Checkpoint) _reachedCheckpoint();
  //   }
  //   super.onCollision(intersectionPoints, other);
  // }

  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      // handle collision
      if (!block.isPlatform) {
        // "this" is Player() cause we're in Player class
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - hitbox.offsetX - hitbox.width;
            break;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + hitbox.width + hitbox.offsetX;
            break;
          }
        }
      }
    }
  }

  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _checkVerticalCollisions() {
    for (final block in collisionBlocks) {
      if (block.isPlatform) {
        if (checkCollision(this, block)) {
          velocity.y = 0;
          position.y = block.y - hitbox.height - hitbox.offsetY;
          isOnGround = true;
          break;
        }
      } else {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height - hitbox.offsetY;
          }
        }
      }
    }
  }

  void _respawn() async {
    // const hitDuration = Duration(milliseconds: 100 * 10);
    // const canmoveDuration = Duration(milliseconds: 100 * 10);

    gotHit = true;
    current = PlayerState.die;
    await animationTicker?.completed;
    animationTicker?.reset();

    scale.x = 1;
    position = startingPosition;
    hp = maxHp;
    current = PlayerState.idle;
    gotHit = false;
    _updatePlayerState();

    // final dieAnimation = animationTickers![PlayerState.die]!;
    // dieAnimation.completed.whenComplete( () {
    //   current = PlayerState.appearing;
    //   print(startingPosition);
    //   dieAnimation.reset();
    // });
    // Future.delayed(hitDuration, () {
    //   Future.delayed(canmoveDuration, () {
    //     scale.x = 1;
    //     position = startingPosition;
    //     current = PlayerState.idle;
    //     gotHit = false;
    //   });
    // });)
  }

  void takeDamage(double damage) {
    //6 frame so * 6
    const hitDuration = Duration(milliseconds: 30 * 6);
    const canmoveDuration = Duration(milliseconds: 40 * 6);

    gotHit = true;
    current = PlayerState.hurt;
    position.x = position.x - 15;
    // position.y = position.y - 5;
    // _hitTime = _hitTime + 1;
    // print(_hitTime);

    hp -= damage;
    hp = hp.clamp(0, 100); // keep the value stay in range
    print("hp: $hp");
    if (hp <= 0) {
      print("you deer");
    }

    Future.delayed(hitDuration, () {
      Future.delayed(canmoveDuration, () {
        gotHit = false;
      });
    });

    // gotHit = true;
    // current = PlayerState.hurt;
    // position.x = position.x - 3;
    // // position.y = position.y - 5;
    // final hitAnimation = animationTickers![PlayerState.hurt]!;
    // hitAnimation.completed.whenComplete(() {
    //   gotHit = false;
    //   hitAnimation.reset();
    // });
  }

  // void takeDamage(double damage) {
  //   hp -= damage;
  //   hp = hp.clamp(0, 100);
  //   print("hp: $hp");
  //   if (hp <= 0) {
  //     print("you deer");
  //   }
  // }

  void _reachedCheckpoint() {
    reachedCheckpoint = true;
    const waitforAnimation = Duration(milliseconds: 400);
    Future.delayed(waitforAnimation, () {
      //add the disappear animation
      reachedCheckpoint = false;
      position = Vector2(position.x + 1000, position.y);

      const waitToChangeDuration = Duration(seconds: 2);
      Future.delayed(waitToChangeDuration, () => game.loadNextLevel());
    });
  }
}
