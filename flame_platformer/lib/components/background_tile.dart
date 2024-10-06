import 'dart:async';
import 'dart:collection';
// import 'dart:ffi';

import 'package:flame/components.dart';
// import 'package:flame/parallax.dart';
import 'package:flame_platformer/flame_platformer.dart';

class BackgroundTile extends SpriteComponent with HasGameRef<FlamePlatformer>{
  final String tiles;
  BackgroundTile({this.tiles = 'forest', position}) : super(position: position);
  
  HashMap<String, int> forest = HashMap<String, int>.from({
    'DarkForest1.2/bgrd_tree3.png': -1,
    'DarkForest1.2/main_background.png': -4,
  });
  final double scrollSpeed = 0.4;

  @override
  FutureOr<void> onLoad() async {
    forest.forEach((imagePath, priorityValue) {
      // Load sprite from the image path
      sprite = Sprite(game.images.fromCache(imagePath));

      // Set priority
      priority = priorityValue;
    });
    return await super.onLoad();
  }

  @override
  void update(double dt) {
    // TODO: implement update
    // position.x += scrollSpeed;
    super.update(dt);
  }
}

// class BackgroundTile extends Component with HasGameRef<FlamePlatformer> {
//   final String tiles;
//   BackgroundTile({this.tiles = 'forest', required this.position});

//   final HashMap<String, int> forest = HashMap<String, int>.from({
//     'DarkForest1.2/bgrd_tree3.png': -10,
//     'DarkForest1.2/main_background.png': -20,
//   });

//   final Vector2 position;
//   final double scrollSpeed = 0.4;

//   @override
//   FutureOr<void> onLoad() async {
//     // Create separate components for each sprite
//     for (var entry in forest.entries) {
//       String imagePath = entry.key;
//       int priorityValue = entry.value;

//       final spriteComponent = SpriteComponent(
//         sprite: Sprite(game.images.fromCache(imagePath)),
//         priority: priorityValue, // Set the priority for this sprite
//         position: position,
//       );

//       // Add the sprite component to the game world
//       add(spriteComponent);
//     }

//     return super.onLoad();
//   }

//   @override
//   void update(double dt) {
//     // Scroll the background
//     position.x += scrollSpeed;
//     super.update(dt);
//   }
// }
