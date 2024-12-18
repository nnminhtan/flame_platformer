import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame_platformer/components/Enemies/Boss.dart';
import 'package:flame_platformer/components/Enemies/Flyingeye.dart';
import 'package:flame_platformer/components/Enemies/Mushroom.dart';
import 'package:flame_platformer/components/Enemies/Shit.dart';
import 'package:flame_platformer/components/Enemies/Spells/spell.dart';
import 'package:flame_platformer/components/Enemies/necromancer.dart';
import 'package:flame_platformer/components/background_tile.dart';
import 'package:flame_platformer/components/bgm_checkpoint.dart';
import 'package:flame_platformer/components/bonfire.dart';
import 'package:flame_platformer/components/checkpoint.dart';
import 'package:flame_platformer/components/collision_block.dart';
import 'package:flame_platformer/components/healthbar/enemy_health_bar.dart';
import 'package:flame_platformer/components/item.dart';
import 'package:flame_platformer/components/player.dart';
import 'package:flame_platformer/components/Enemies/Skeleton.dart';
import 'package:flame_platformer/components/traps/saw.dart';
import 'package:flame_platformer/components/traps/spear.dart';
import 'package:flame_platformer/components/traps/thorn.dart';
import 'package:flame_platformer/flame_platformer.dart';
import 'package:flame_tiled/flame_tiled.dart';

class Level extends World with HasGameRef<FlamePlatformer> {
  final String levelName;
  final Player player;
  Level({required this.levelName, required this.player});
  late TiledComponent level;
  List<CollisionBlock> collisionBlocks = [];
  late Rect _levelBounds;

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(16));
    add(level);

    _addBackground();
    _spawnObject();
    _addCollision();
    // TODO: implement onLoad
    return super.onLoad();
  }

  @override
  void onMount() {
    super.onMount();
    _calculateCameraBounds();
    _setCameraFollow();
  }

  double getMapWidth() {
    return (level.tileMap.map.width * level.tileMap.map.tileWidth).toDouble();
  }

  double getMapHeight() {
    return (level.tileMap.map.height * level.tileMap.map.tileHeight).toDouble();
  }

  void _addBackground() {
    final backgroundLayer = level.tileMap.getLayer('Background');
    if (backgroundLayer != null) {
      // final backgroundColor = backgroundLayer.properties.getValue('BackgroundTile');
      final backgroundTile = BackgroundTile(
          // tiles:  ?? 'forest',
          position: Vector2(0, 0));
      add(backgroundTile);
    }
  }

  void _spawnObject() {
    final spawnPointPlayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');

    if (spawnPointPlayer != null) {
      for (final spawnpoint in spawnPointPlayer.objects) {
        switch (spawnpoint.class_) {
          //player
          case 'Player':
            if (game.isloadfromsavefile) {
              player.position = Vector2(game.x, game.y);
            } else {
              player.position = Vector2(spawnpoint.x, spawnpoint.y);
            }
            // player.anchor = Anchor.center;
            add(player);
            break;
          //items
          case 'Item':
            final item = Item(
              item: spawnpoint.name,
              position: Vector2(spawnpoint.x, spawnpoint.y),
              size: Vector2(spawnpoint.width, spawnpoint.height),
            );
            add(item);
            break;
          //enemies
          case 'Skeleton':
            final offNeg = spawnpoint.properties.getValue('offNeg');
            final offPos = spawnpoint.properties.getValue('offPos');
            final skeleton = Skeleton(
                position: Vector2(spawnpoint.x, spawnpoint.y),
                size: Vector2(spawnpoint.width, spawnpoint.height),
                offNeg: offNeg,
                offPos: offPos,
                maxHp: 150);
            add(skeleton);
            add(EnemyHealthBar(skeleton));
            break;
          case 'Mushroom':
            final offNeg = spawnpoint.properties.getValue('offNeg');
            final offPos = spawnpoint.properties.getValue('offPos');
            final mushroom = Mushroom(
              position: Vector2(spawnpoint.x, spawnpoint.y),
              size: Vector2(spawnpoint.width, spawnpoint.height),
              offNeg: offNeg,
              offPos: offPos,
              maxHp: 100,
            );
            add(mushroom);
            add(EnemyHealthBar(mushroom));
            break;
          case 'Flying eye':
            final offNeg = spawnpoint.properties.getValue('offNeg');
            final offPos = spawnpoint.properties.getValue('offPos');
            final flyingeye = Flyingeye(
              position: Vector2(spawnpoint.x, spawnpoint.y),
              size: Vector2(spawnpoint.width, spawnpoint.height),
              offNeg: offNeg,
              offPos: offPos,
              maxHp: 150,
            );
            add(flyingeye);
            add(EnemyHealthBar(flyingeye));
            break;

          case 'Necromancer':
            final offNeg = spawnpoint.properties.getValue('offNeg');
            final offPos = spawnpoint.properties.getValue('offPos');
            final necro = Necromancer(
                position: Vector2(spawnpoint.x, spawnpoint.y),
                size: Vector2(spawnpoint.width, spawnpoint.height),
                offNeg: offNeg,
                offPos: offPos,
                maxHp: 300);
            add(necro);
            // add(EnemyHealthBar(necro));
            break;

          case 'Shit':
            final offNeg = spawnpoint.properties.getValue('offNeg');
            final offPos = spawnpoint.properties.getValue('offPos');
            final shit = Shit(
              position: Vector2(spawnpoint.x, spawnpoint.y),
              size: Vector2(spawnpoint.width, spawnpoint.height),
              offNeg: offNeg,
              offPos: offPos,
              maxHp: 100,
            );
            add(shit);
            add(EnemyHealthBar(shit));
            break;

          case 'Boss':
            final offNeg = spawnpoint.properties.getValue('offNeg');
            final offPos = spawnpoint.properties.getValue('offPos');
            final boss = Boss(
                position: Vector2(spawnpoint.x, spawnpoint.y),
                size: Vector2(spawnpoint.width, spawnpoint.height),
                offNeg: offNeg,
                offPos: offPos,
                maxHp: 150);
            add(boss);
            add(EnemyHealthBar(boss));
            break;
            
          //traps
          case 'Thorn':
            final thorn = Thorn(
              position: Vector2(spawnpoint.x, spawnpoint.y),
              size: Vector2(spawnpoint.width, spawnpoint.height),
            );
            add(thorn);
            break;

          case 'Spear':
            final spear = Spear(
              position: Vector2(spawnpoint.x, spawnpoint.y),
              size: Vector2(spawnpoint.width, spawnpoint.height),
            );
            add(spear);
            break;

          case 'Saw':
            final isVertical = spawnpoint.properties.getValue('isVertical');
            final offNeg = spawnpoint.properties.getValue('offNeg'); //go left
            final offPos = spawnpoint.properties.getValue('offPos'); //go right
            final saw = Saw(
              isVertical: isVertical,
              offNeg: offNeg,
              offPos: offPos,
              position: Vector2(spawnpoint.x, spawnpoint.y),
              size: Vector2(spawnpoint.width, spawnpoint.height),
            );
            add(saw);
            break;

          //bgm change
          case 'BGM_Checkpoint':
            final bgmCheckpoint = BgmCheckpoint(
              spot: spawnpoint.name,
              position: Vector2(spawnpoint.x, spawnpoint.y),
              size: Vector2(spawnpoint.width, spawnpoint.height),
            );
            add(bgmCheckpoint);
            break;

          //bonfire
          case 'Bonfire':
            final bonfire = Bonfire(
              spot: spawnpoint.name,
              position: Vector2(spawnpoint.x, spawnpoint.y),
              size: Vector2(spawnpoint.width, spawnpoint.height),
            );
            add(bonfire);
            break;

          //checkpoint
          case 'Checkpoint':
            final checkpoint = Checkpoint(
              position: Vector2(spawnpoint.x, spawnpoint.y),
              size: Vector2(spawnpoint.width, spawnpoint.height),
            );
            add(checkpoint);
            break;

          default:
        }
      }
    }
  }
  final Map<String, Spell> _spells = {};
  void addSpell(String spellName, Vector2 position, Vector2 size, double? offNeg, double? offPos){
    final spell = Spell(
      spell: spellName,
      offNeg: offNeg,
      offPos: offPos,
      position: position,
      size: size,
    );
    add(spell);
    _spells[spellName] = spell;
    add(spell);
  }
  void removeSpell(String spellName) {
    final spell = _spells[spellName];
    if (spell != null) {
      spell.removeFromParent(); // This removes the spell from the game world
      _spells.remove(spellName); // Remove it from the map
    }
  }
  void summonEntities(String enemyName, double offNeg, double offPos, Vector2 position, Vector2 size){  
    switch (enemyName) {
      case 'Flying eye':
            final flyingeye = Flyingeye(
              position: position,
              size: size,
              offNeg: offNeg,
              offPos: offPos,
              maxHp: 150,
            );
            add(flyingeye);
            add(EnemyHealthBar(flyingeye));
        break;
      case 'Mushroom':
            final mushroom = Mushroom(
              position: position,
              size: size,
              offNeg: offNeg,
              offPos: offPos,
              maxHp: 100,
            );
            add(mushroom);
            add(EnemyHealthBar(mushroom));
        break;   
        case 'Skeleton':
        default:
            final skeleton = Skeleton(
                position: position,
                size: size,
                offNeg: offNeg,
                offPos: offPos,
                maxHp: 150);
            add(skeleton);
            add(EnemyHealthBar(skeleton));
        break;         
    }
  }

  void _addCollision() {
    final collisionLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');

    if (collisionLayer != null) {
      for (final collision in collisionLayer.objects) {
        switch (collision.class_) {
          case 'Platform':
            final platform = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isPlatform: true,
            );
            collisionBlocks.add(platform);
            add(platform);
            break;
          default:
            final block = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
            );
            collisionBlocks.add(block);
            add(block);
        }
      }
    }
    player.collisionBlocks = collisionBlocks;
  }

  void _calculateCameraBounds() {
    // Define the level bounds based on the tile map size
    _levelBounds = Rect.fromLTWH(
      0,
      0,
      (level.tileMap.map.width * level.tileMap.map.tileWidth).toDouble(),
      (level.tileMap.map.height * level.tileMap.map.tileHeight).toDouble(),
    );
    print('Level bounds: ${_levelBounds.width} x ${_levelBounds.height}');

    // Get the size of the viewport, considering zoom
    final adjustedViewportSize =
        gameRef.cam.viewport.size / gameRef.cam.viewfinder.zoom;
    print('Viewport size: ${gameRef.cam.viewport.size}');
    print(
        'Adjusted viewport size with zoom: ${adjustedViewportSize.x} x ${adjustedViewportSize.y}');

    // Scaling factor, approximately 2.5 (just calculate somehow) for correct bounds
    const scalingFactor = 2.5;

    final cameraBounds = Rectangle.fromLTRB(
        0 + (adjustedViewportSize.x / 2) * scalingFactor, // Left boundary
        0 + (adjustedViewportSize.y / 2) * scalingFactor, // Top boundary
        _levelBounds.width -
            (adjustedViewportSize.x / 2) * scalingFactor, // Right boundary
        _levelBounds.height -
            (adjustedViewportSize.y / 2) * scalingFactor // Bottom boundary
        );
    gameRef.cam.setBounds(cameraBounds);
    print(
        'Adjusted Camera bounds: ${cameraBounds.left}, ${cameraBounds.top}, ${cameraBounds.right}, ${cameraBounds.bottom}');
  }

  void _setCameraFollow() {
    gameRef.cam.follow(
      player, // Reference to your Player component
      maxSpeed: 300, // Set a speed limit for camera movement
      horizontalOnly: false, // Whether to follow horizontally only
      verticalOnly: false, // Whether to follow vertically only
      snap:
          true, // If true, the camera snaps to the player instead of moving smoothly
    );
  }
}
