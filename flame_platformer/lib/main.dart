import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_platformer/flame_platformer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding();
  Flame.device.fullScreen();
  Flame.device.setLandscape();

  flameplatformer game = flameplatformer();
  runApp(
    GameWidget(game: kDebugMode ? flameplatformer() : game),
  );
}
