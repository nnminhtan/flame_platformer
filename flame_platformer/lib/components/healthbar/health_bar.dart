import 'package:flame/components.dart';
import 'package:flame_platformer/flame_platformer.dart';
import 'package:flutter/material.dart';

class HealthBar extends PositionComponent with HasGameRef<FlamePlatformer> {
  late RectangleComponent healthBar;
  final double barWidth;
  final double barHeight;
  final Color barColor;
  final dynamic entity;

  HealthBar({
    required this.entity,
    required this.barWidth,
    required this.barHeight,
    required this.barColor,
    super.priority = 5,
  });

  @override
  Future<void> onLoad() async {
    super.onLoad();

    healthBar = RectangleComponent(
      size: Vector2(barWidth, barHeight),
      paint: Paint()..color = barColor,
      // position: Vector2(20, 10),
    );

    add(healthBar);
  }

  @override
  void update(double dt) {
    super.update(dt);
    updateHealthBar();
    setHealthBarPosition();
  }

  void updateHealthBar() {
    healthBar.size.x =
        (entity.hp / entity.maxHp) * barWidth; // Update based on current HP
  }

  void setHealthBarPosition() {}
}
