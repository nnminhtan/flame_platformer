import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_platformer/levels/level.dart';

class flameplatformer extends FlameGame {

  late final CameraComponent cam;
  final world = Level();

  
  @override
  FutureOr<void> onLoad() {
    cam = CameraComponent.withFixedResolution(world: world, width: 1920, height: 1024);
    cam.viewfinder.anchor = Anchor.topLeft;
    addAll([cam, world]);
    // TODO: implement onLoad
    return super.onLoad();
  }
}