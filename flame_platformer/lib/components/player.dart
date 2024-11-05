import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_platformer/components/Enemies/Enemies.dart';
import 'package:flame_platformer/components/bgm_checkpoint.dart';
import 'package:flame_platformer/components/bonfire.dart';
import 'package:flame_platformer/components/checkpoint.dart';
import 'package:flame_platformer/components/collision_block.dart';
import 'package:flame_platformer/components/custom_hitbox.dart';
import 'package:flame_platformer/components/game%20data/gamedata.dart';
import 'package:flame_platformer/components/game%20data/playerdata.dart';
import 'package:flame_platformer/components/game%20data/settingdata.dart';
import 'package:flame_platformer/components/item.dart';
import 'package:flame_platformer/components/respawn_screen.dart';
import 'package:flame_platformer/components/traps/saw.dart';
import 'package:flame_platformer/components/traps/spear.dart';
import 'package:flame_platformer/components/traps/thorn.dart';
import 'package:flame_platformer/components/utils.dart';
import 'package:flame_platformer/flame_platformer.dart';
import 'package:flame_platformer/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum PlayerState {
  idle,
  run,
  jump,
  fall,
  normalAttack,
  upAttack,
  airAttack,
  plungeAttack,
  plungeAttackEnd,
  crouch,
  slide,
  hurt,
  die,
}

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<FlamePlatformer>, KeyboardHandler, CollisionCallbacks {
  Player({position}) : super(position: position);
  //default PlayerState
  PlayerState playerState = PlayerState.idle;
  // hp
  late double hp;
  final double maxHp = 100.0;

  // for attack logic
  double attackTimer = 0.0;
  final double attackDuration = 0.75;
  bool isAttacking = false;
  bool isUpAttack = false;
  bool isAirAttack = false;
  bool isPlungeAttack = false;
  bool isSliding = false;
  bool isCrouching = false;
  RectangleHitbox? attackHitbox;
  CustomHitbox? currentAttackHitbox;

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
  late final SpriteAnimation airAttackAnimation;
  late final SpriteAnimation plungeAttackAnimation;
  late final SpriteAnimation plungeAttackEndAnimation;
  late final SpriteAnimation crouchAnimation;
  late final SpriteAnimation slideAnimation;
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
  bool isAttackCdPlayer = false;
  bool isAttackCdEnemy = false;
  // int _hitTime = 0;

  bool isOnGround = false;
  bool hasJumped = false;
  CustomHitbox hitbox = CustomHitbox(
    offsetX: 14,
    offsetY: 4,
    width: 21,
    height: 30,
  );

  //music
  late String currentLevel;
  late String bgmSpot;
  late bool inCave;
  bool inCaveCheck = false;
  late String currentPlaying = 'Life and Legacy';

  //save game
  bool isnearBonfire = false;
  late String currentBonfire;

  @override
  FutureOr<void> onLoad() async {
    hp = game.hp;
    inCave = game.inCave;
    currentLevel = gameRef.levelNames[gameRef.currentLevelIndex];
    //set player spawnpoint
    if (game.isloadfromsavefile) {
      startingPosition = Vector2(game.x, game.y);
      changeBGM();
      game.isloadfromsavefile = false;
    } else {
      startingPosition = Vector2(position.x, position.y);
    }
    currentBonfire = game.bonfireName;
    await _loadAllAnimations();
    // debugMode = true;
    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height),
    ));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    // print('0: $currentPlaying, $inCave, ${game.isloadfromsavefile}');
    print('${game.level}, $currentLevel, $inCave');
    if (!gotHit && !reachedCheckpoint) {
      _updatePlayerState();
      if (isAttacking) {
        _updateAttackHitbox();
      }
      // will add logic to fix attack movement is seperated
      if (attackTimer > 0) {
        attackTimer -= dt;
        if (attackTimer <= 0 && !isPlungeAttack) {
          isAttacking = false;
          isUpAttack = false;
          isAirAttack = false;
          // isPlungeAttack = false;
          // isSliding = false;
        }
      }
      _updatePlayerMovement(dt);
      _checkHorizontalCollisions();
      _applyGravity(dt);
      _checkVerticalCollisions();
    } else if (reachedCheckpoint) {
      Future.delayed(const Duration(seconds: 3), () {
        currentLevel = gameRef.levelNames[gameRef.currentLevelIndex];
        changeBGM();
      });
    }

    if (_cooldownTimer > 0) {
      _cooldownTimer -= dt;
    }
    if (hp <= 0 && gotHit == false) {
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
    final isUpKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyW) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp);
    final isDownKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyS) ||
        keysPressed.contains(LogicalKeyboardKey.arrowDown);
    final isAttackKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyJ);
    final isCrouchKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyG);
    final isSlideKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyH);
    final isInteractKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyE);

    // make sure cant move while normal attack
    if (!isAttacking || isAirAttack) {
      horizontalMovement += isLeftKeyPressed ? -1 : 0;
      horizontalMovement += isRightKeyPressed ? 1 : 0;
    }

    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);

    if (isCrouchKeyPressed && isOnGround && !isAttacking && !isSliding) {
      isCrouching = true;
    } else {
      isCrouching = false;
    }

    if (isSlideKeyPressed && isOnGround && !isAttacking && !isSliding) {
      isSliding = true;
      // reset the slide after a duration
      Future.delayed(Duration(milliseconds: 700), () {
        isSliding = false; // Slide duration
      });
    }
    if (isInteractKeyPressed && isnearBonfire) {
      saveGameData();
      // print('incave: $inCave');
      // loadGameData();
    }

    // still got error with up attack so add more later
    if (isAttackKeyPressed && !isAttacking) {
      isAttacking = true;
      attackTimer = attackDuration;
      // check plunge
      if ((current == PlayerState.jump || current == PlayerState.fall) &&
          isDownKeyPressed) {
        isPlungeAttack = true;
        isAirAttack = false;
        isUpAttack = false;
      }
      // check air
      else if ((current == PlayerState.jump || current == PlayerState.fall) &&
          (isLeftKeyPressed || isRightKeyPressed)) {
        isAirAttack = true;
        isPlungeAttack = false;
        isUpAttack = false;
      }
      // check up
      else if (isUpKeyPressed || !isOnGround) {
        isUpAttack = true;
        isAirAttack = false;
        isPlungeAttack = false;
      } else {
        // else normal
        isUpAttack = false;
        isAirAttack = false;
        isPlungeAttack = false;
      }
    }

    return super.onKeyEvent(event, keysPressed);
  }

  void saveGameData() async {
    PlayerData playerData = PlayerData(
      x: position.x,
      y: position.y,
      hp: hp,
      level: currentLevel,
      bonfireName: currentBonfire,
      inCave: inCave,
    );

    SettingsData settingsData = SettingsData(
      soundVolume: soundVolume,
      playSounds: playSounds,
    );
    GameData gameData =
        GameData(playerData: playerData, settingsData: settingsData);
    await game.saveGameData(gameData);
  }

  // void loadGameData() async {
  //   GameData? gameData = await game.loadGameData();
  //   if (gameData != null) {
  //     print('Player HP: ${gameData.playerData.hp}');
  //     print('Player Position: (${gameData.playerData.x}, ${gameData.playerData.y})');
  //     print('Sound Volume: ${gameData.settingsData.soundVolume}');
  //     print('Play Sounds: ${gameData.settingsData.playSounds}, inCave: ${gameData.playerData.inCave}');
  //   }
  // }

  Future<void> _loadAllAnimations() async {
    // Load animations state
    idleAnimation = await _loadAnimation('Main Character/Idle', 3);
    runAnimation = await _loadAnimation('Main Character/Run', 6);
    jumpAnimation = await _loadAnimation('Main Character/Jump', 4);
    fallAnimation = await _loadAnimation('Main Character/Fall', 2);
    normalAttackAnimation =
        await _loadAnimation('Main Character/Normal_Attack', 6);
    upAttackAnimation = await _loadAnimation('Main Character/Up_Attack', 5);
    airAttackAnimation = await _loadAnimation('Main Character/Air_Attack', 4)
      ..loop = false;
    plungeAttackAnimation =
        await _loadAnimation('Main Character/Plunge_Attack/Loop', 2)
          ..loop = true;
    plungeAttackEndAnimation =
        await _loadAnimation('Main Character/Plunge_Attack/End', 3);
    crouchAnimation = await _loadAnimation('Main Character/Crouch', 4);
    slideAnimation = await _loadAnimation('Main Character/Slide', 5);
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
      PlayerState.airAttack: airAttackAnimation,
      PlayerState.plungeAttack: plungeAttackAnimation,
      PlayerState.plungeAttackEnd: plungeAttackEndAnimation,
      PlayerState.crouch: crouchAnimation,
      PlayerState.slide: slideAnimation,
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
      if (isPlungeAttack) {
        if (isOnGround) {
          playerState = PlayerState.plungeAttackEnd;
          isPlungeAttack = false;
          isAttacking = false;
        } else {
          playerState = PlayerState.plungeAttack;
        }
      } else if (isAirAttack) {
        playerState = PlayerState.airAttack;
      } else if (isUpAttack) {
        playerState = PlayerState.upAttack;
      } else {
        playerState = PlayerState.normalAttack;
      }
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
      // Check for sliding
      if (isSliding) {
        playerState = PlayerState.slide;
      }
      // check for crouching
      if (isCrouching) {
        playerState = PlayerState.crouch;
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

    // if slide, a bit faster
    if (isSliding) {
      velocity.x = (scale.x > 0 ? 1 : -1) * moveSpeed * 1.5;
    } else if (isCrouching) {
      // could make it move while crouch but no animtion for that
      velocity.x = 0;
    } else {
      velocity.x = horizontalMovement * moveSpeed;
    }
    position.x += velocity.x * dt;
  }

  void _playerJump(double dt) {
    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    isOnGround = false;
    hasJumped = false;
  }

  void _updateAttackHitbox() {
    String attackType;
    if (isAttacking) {
      switch (current) {
        case PlayerState.normalAttack:
          attackType = 'playerNormalAttack';
          break;
        case PlayerState.upAttack:
          attackType = 'playerUpAttack';
          break;
        case PlayerState.airAttack:
          attackType = 'playerAirAttack';
          break;
        case PlayerState.plungeAttack:
          attackType = 'playerPlungeAttack';
          break;
        default:
          attackType = 'playerNormalAttack';
          break;
      }

      currentAttackHitbox = CustomHitbox.fromPreset(attackType);

      // print('playerState: $current, attackType: $attackType');
      // print('Attack Hitbox: offsetX: ${currentAttackHitbox!.offsetX}, '
      //     'offsetY: ${currentAttackHitbox!.offsetY}, '
      //     'width: ${currentAttackHitbox!.width}, '
      //     'height: ${currentAttackHitbox!.height}');

      if (attackHitbox == null || attackHitbox!.parent == null) {
        attackHitbox = RectangleHitbox(
          position: Vector2(
              currentAttackHitbox!.offsetX, currentAttackHitbox!.offsetY),
          size:
              Vector2(currentAttackHitbox!.width, currentAttackHitbox!.height),
        );
      }

      // print("Adding attack hitbox: ${attackHitbox.toString()}");
      add(attackHitbox!);

      Future.delayed(const Duration(milliseconds: 750), () {
        if (attackHitbox != null && attackHitbox!.parent != null) {
          // print("Removing attack hitbox: ${attackHitbox.toString()}");
          remove(attackHitbox!);
          attackHitbox = null;
        } else {
          // print("AttackHitbox has no parent, skipping removal");
        }
      });
    }
  }

  void UpdateAttackButton() {
    if (!isAttacking) {
      isAttacking = true;
      attackTimer = attackDuration;

      if (current == PlayerState.jump || current == PlayerState.fall) {
        isAirAttack = true;
        playerState = PlayerState.airAttack;
      } else if (isUpAttack) {
        playerState = PlayerState.upAttack;
      } else {
        playerState = PlayerState.normalAttack;
      }
    }
  }

  //player collied with object
  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (!reachedCheckpoint) {
      // if (other is Enemies && isAttacking && isAttackCdPlayer == false) {
      //   isAttackCdPlayer = true;
      //   other.takeDamage(20);
      //   Future.delayed(const Duration(milliseconds: 1000), () {
      //     isAttackCdPlayer = false;
      //   });
      // }

      // Collision with Player's Attack Hitbox
      if (attackHitbox != null &&
          other is Enemies &&
          attackHitbox!.isColliding) {
        if (isAttacking && !isAttackCdPlayer) {
          isAttackCdPlayer = true;
          other.takeDamage(20);
          Future.delayed(const Duration(milliseconds: 1000), () {
            isAttackCdPlayer = false;
          });
        }
      }

      if (other is Item) {
        other.collidedwithPlayer();
      }

      if (((other is Enemies) && other.attackHitbox.isColliding) &&
          (_cooldownTimer <= 0 &&
              gotHit == false &&
              isAttackCdEnemy == false)) {
        isAttackCdEnemy = true;
        // Future.delayed(const Duration(milliseconds: 1300), () {
        takeDamage(50);
        _cooldownTimer = hurtCooldown;
        // });
        Future.delayed(const Duration(milliseconds: 1000), () {
          isAttackCdEnemy = false;
        });
      }

      if ((other is Thorn || other is Spear || other is Saw) &&
          (_cooldownTimer <= 0 && gotHit == false)) {
        if (hp > 0) {
          takeDamage(10);
          _cooldownTimer = hurtCooldown;
        }
      }
      if (other is Checkpoint) _reachedCheckpoint();

      if (other is BgmCheckpoint && game.playSounds && inCaveCheck == false) {
        // print(game.level);
        // forestBGM();
        inCave = true;
        changeBGM();
      } else {
        // forestBGM();
        inCave = false;
        changeBGM();
        // inCaveCheck = false;
      }
      // }
      if (other is Bonfire && !isnearBonfire) {
        isnearBonfire = true;
        currentBonfire = other.spot;
        print('currentBonfire: $currentBonfire');
      } else {
        isnearBonfire = false;
      }
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
    // print('jump: $_jumpForce, $_terminalVelocity, $_gravity, $velocity, $dt');
  }

  void _checkVerticalCollisions() {
    for (final block in collisionBlocks) {
      if (block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
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
    FlameAudio.bgm.pause();
    // scale.x = 1;
    // position = startingPosition;
    // hp = maxHp;
    // Future.delayed(canmoveDuration, () {
    //     gotHit = false;
    // });

    // current = PlayerState.idle;

    // _updatePlayerState();
    // Push the respawn screen onto the navigator
    await navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => RespawnScreen(
          onContinue: () {
            // Logic to continue the game
            hp = maxHp; // Reset HP
            scale.x = 1;
            current = PlayerState.idle;
            position = startingPosition; // Reset position
            gotHit = false;
            // print('1: $currentPlaying, $inCave');
            inCave = true;
            changeBGM();
            // print('2: $currentPlaying, $inCave');
            // Remove the respawn screen and reset player state
            navigatorKey.currentState?.pop(); // Go back to the game
            // Reset hit state
          },
          onBackToMainMenu: () {
            FlameAudio.bgm.stop();
            // Logic to go back to the main menu
            navigatorKey.currentState?.pop(); // Close respawn screen
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) =>
                    MenuScreen(), // Ensure this is your main menu widget
              ),
            );
            FlameAudio.bgm.play('He is.mp3', volume: soundVolume);
            // Implement main menu logic here
          },
        ),
      ),
    );

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
    if (game.playSounds) {
      FlameAudio.play('OOF.mp3', volume: game.soundVolume);
    }
    // position.x = position.x - 15;
    if (scale.x > 0) {
      position.x = position.x - 5;
    } else if (scale.x < 0) {
      position.x = position.x + 5;
    }
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

  void changeBGM() async {
    // inCave = false;
    switch (currentLevel) {
      case 'forestmap':
        if (game.playSounds) {
          await forestBGM();
          //   FlameAudio.bgm.stop();
          //   FlameAudio.bgm.play('Life and Legacy.mp3', volume: game.soundVolume * .5);
        }
        break;

      case 'castlemap':
        if (game.playSounds) {
          FlameAudio.bgm.stop();
          await FlameAudio.bgm
              .play('Sis Puella Magica.mp3', volume: game.soundVolume * .5);
        }
        break;
      default:
    }
  }

  Future<void> forestBGM() async {
    // switch (inCave) {
    //   case false:
    //     if(currentPlaying == 'Things That Scheme in the Dark'){
    //         FlameAudio.bgm.resume();
    //         inCave = true;
    //     }else if(game.isloadfromsavefile && game.level == 'forestmap'){
    //       FlameAudio.bgm.stop();
    //       FlameAudio.bgm.play('Life and Legacy.mp3', volume: game.soundVolume * .5);
    //       inCave = false;
    //     }else{
    //       FlameAudio.bgm.stop();
    //       FlameAudio.bgm.play('Things That Scheme in the Dark.mp3', volume: game.soundVolume * .5);
    //       Future.delayed(const Duration(seconds: 3), () {
    //         inCave = true;
    //         currentPlaying = 'Things That Scheme in the Dark';
    //       });
    //     }
    //     // print('forestbgm: $inCave');
    //     break;

    //   case true:
    //     if(currentPlaying == 'Life and Legacy'){
    //       FlameAudio.bgm.resume();
    //       inCave = false;
    //     }else if(game.isloadfromsavefile && game.level == 'forestmap'){
    //       FlameAudio.bgm.stop();
    //       FlameAudio.bgm.play('Things That Scheme in the Dark.mp3', volume: game.soundVolume * .5);
    //       inCave = true;
    //     }else{
    //       FlameAudio.bgm.stop();
    //       FlameAudio.bgm.play('Life and Legacy.mp3', volume: game.soundVolume * .5);
    //       Future.delayed(const Duration(seconds: 3), () {
    //         inCave = false;
    //         currentPlaying = 'Life and Legacy';
    //       });
    //     }
    //     break;
    //   default:
    // }

    if (inCave == false) {
      FlameAudio.bgm.stop();
      await FlameAudio.bgm
          .play('Life and Legacy.mp3', volume: game.soundVolume * .5);
      inCaveCheck = false;
    } else {
      FlameAudio.bgm.stop();
      await FlameAudio.bgm.play('Things That Scheme in the Dark.mp3',
          volume: game.soundVolume * .5);
      inCaveCheck = true;
    }
  }
}
