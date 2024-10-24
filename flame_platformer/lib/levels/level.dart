import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_platformer/actors/player.dart';
import 'package:flame_platformer/flame_platformer.dart';
import 'package:flame_tiled/flame_tiled.dart';

class Level extends World {
  final String levelName;
  Level({required this.levelName});
  late TiledComponent level;

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(16));
    late final player;
    add(level);
    // add(Player());
    final spawnPointPlayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');

    for (final spawnpoint in spawnPointPlayer!.objects) {
      switch (spawnpoint.class_) {
        case 'Player':
          player = Player(position: Vector2(spawnpoint.x, spawnpoint.y));
          add(player);
          break;
        default:
      }
    }


    // TODO: implement onLoad
    return super.onLoad();
  }
}
