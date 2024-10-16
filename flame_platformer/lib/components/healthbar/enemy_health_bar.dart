import 'package:flame/components.dart';
import 'package:flame_platformer/components/Enemies.dart';
import 'package:flame_platformer/components/healthbar/health_bar.dart';
import 'package:flutter/material.dart';

class EnemyHealthBar extends HealthBar {
  EnemyHealthBar(Enemies enemy)
      : super(
          entity: enemy,
          barWidth: 30,
          barHeight: 4,
          barColor: Colors.red,
        );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    setHealthBarPosition();
  }

  @override
  void setHealthBarPosition() {
    final hitbox = entity.getHitbox();
    // final offset = Vector2(-40, -20);
    if (entity.scale.x < 0) {
      // flipHorizontallyAroundCenter();
      healthBar.position =
          entity.position - hitbox.position + Vector2(-30, 100);
      print('left');
    } else {
      // flipHorizontallyAroundCenter();
      healthBar.position = entity.position + hitbox.position + Vector2(0, -10);
      print('right');
    }
    // healthBar.position = entity.position;
    // print('Enemy position: ${entity.position}');
    // print('Enemy hitbox position: ${hitbox.position}');
    // print('Health bar position: ${healthBar.position}');
  }
}
