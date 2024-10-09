import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_platformer/components/Enemies.dart';
import 'package:flame_platformer/components/background_tile.dart';
import 'package:flame_platformer/components/collision_block.dart';
import 'package:flame_platformer/components/player.dart';
import 'package:flame_platformer/components/Skeleton.dart';
import 'package:flame_platformer/components/thorn.dart';
import 'package:flame_platformer/flame_platformer.dart';
import 'package:flame_tiled/flame_tiled.dart';

class Level extends World with HasGameRef<FlamePlatformer> {
  final String levelName;
  final Player player;
  Level({required this.levelName, required this.player});
  late TiledComponent level;
  List<CollisionBlock> collisionBlocks = [];

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(16));
    add(level);

    _addBackground();
    _spawnObject();
    _addCollision();
    
    // add(Player());
    player.collisionBlocks = collisionBlocks;
    gameRef.cam.follow(
      player,   // Reference to your Player component
      maxSpeed: 500,  // Set a speed limit for camera movement
      horizontalOnly: false,  // Whether to follow horizontally only
      verticalOnly: false,    // Whether to follow vertically only
      snap: true,  // If true, the camera snaps to the player instead of moving smoothly
    );

    // TODO: implement onLoad
    return super.onLoad();
  }

  void _addBackground() {
    final backgroundLayer = level.tileMap.getLayer('Background');
    if(backgroundLayer != null){
      // final backgroundColor = backgroundLayer.properties.getValue('BackgroundTile');
      final backgroundTile = BackgroundTile(
        // tiles:  ?? 'forest',
        position: Vector2(0, 0)
      );
      add(backgroundTile);
    } 
  }

  void _spawnObject() {
    final spawnPointPlayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');

    if (spawnPointPlayer != null) {
      for (final spawnpoint in spawnPointPlayer.objects) {
        switch (spawnpoint.class_) {
          case 'Player':
            player.position = Vector2(spawnpoint.x, spawnpoint.y);
            add(player);
            break;
          case 'Skeleton':
            final offNeg = spawnpoint.properties.getValue('offNeg');
            final offPos = spawnpoint.properties.getValue('offPos');
            final skeleton = Skeleton(
              position: Vector2(spawnpoint.x, spawnpoint.y),
              size: Vector2(spawnpoint.width, spawnpoint.height),
              offNeg: offNeg,
              offPos: offPos,
            );
            add(skeleton);
            break;

          case 'Thorn':
            final thorn = Thorn(
              position: Vector2(spawnpoint.x, spawnpoint.y),
              size: Vector2(spawnpoint.width, spawnpoint.height),
            );
            add(thorn);
          break;
          default:
        }
      }
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
    gameRef.cam.follow(
      player, // Reference to your Player component
      maxSpeed: 500, // Set a speed limit for camera movement
      horizontalOnly: false, // Whether to follow horizontally only
      verticalOnly: false, // Whether to follow vertically only
      snap:
          true, // If true, the camera snaps to the player instead of moving smoothly
    );

    // // TODO: implement onLoad
    // return super.onLoad();
  }
}
