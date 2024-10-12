import 'package:flame/components.dart';
import 'package:flame_platformer/flame_platformer.dart';
import 'package:flutter/material.dart';

class HealthBar extends PositionComponent with HasGameRef<FlamePlatformer> {
  late SpriteComponent background;
  late RectangleComponent healthBar;
  late SpriteComponent heartIcon;

  final double barWidth = 250;
  final double barHeight = 20;

  @override
  Future<void> onLoad() async {
    background = SpriteComponent()
      ..sprite = await gameRef.loadSprite('HealthBar/Bar.png')
      ..size = Vector2(barWidth, barHeight)
      ..position = Vector2(10, 10);

    add(background);

    // print(
    //     'Background loaded: ${background.size} at position ${background.position}');

    healthBar = RectangleComponent(
      position: Vector2(10, 10),
      size: Vector2(barWidth, barHeight),
      paint: Paint()..color = Colors.green,
    );
    add(healthBar);

    heartIcon = SpriteComponent()
      ..sprite = await gameRef.loadSprite('HealthBar/Heart.png')
      ..size = Vector2(20, 20)
      ..position = Vector2(10, 10);

    add(heartIcon);
  }
}
