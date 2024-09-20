import 'dart:async';
// import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_platformer/levels/level.dart';

class flameplatformer extends FlameGame with HasKeyboardHandlerComponents{
  late final CameraComponent cam;
  final world = Level(levelName: 'forestmap');

  @override
  FutureOr<void> onLoad() async {
    // load images to cache
    await images.loadAllImages();

    cam = CameraComponent.withFixedResolution(
        world: world, width: 1920, height: 1024);
    cam.viewfinder.anchor = Anchor.topLeft;
    cam.viewfinder.zoom = 2.2;
    // = calculateZoom(1920, 1024, desiredWidth: 800, desiredHeight: 600);  // Example: Zoom to 800x600 area around the player
    addAll([cam, world]);
    
    // TODO: implement onLoad
    return super.onLoad();
  }
  //calc zoom
  double calculateZoom(double viewportWidth, double viewportHeight, {required double desiredWidth, required double desiredHeight}) {
    final zoomX = viewportWidth / desiredWidth;
    final zoomY = viewportHeight / desiredHeight;

    // Return the smaller zoom factor to maintain the aspect ratio
    return zoomX < zoomY ? zoomX : zoomY;
  }
}
