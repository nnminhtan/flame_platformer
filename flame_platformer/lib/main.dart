import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_platformer/flame_platformer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  FlamePlatformer game = FlamePlatformer();
  runApp(
    GameWidget(game: kDebugMode ? FlamePlatformer() : game,
    ),
  );
}
