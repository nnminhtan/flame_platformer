import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_platformer/flame_platformer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  flameplatformer game = flameplatformer();
  runApp(
    GameWidget(game: kDebugMode ? flameplatformer() : game),
  );
}
