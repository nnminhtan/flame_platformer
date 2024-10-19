import 'package:flame/components.dart';
import 'package:flame_platformer/components/Enemies/Enemies.dart';
import 'package:flame_platformer/components/healthbar/health_bar.dart';
import 'package:flutter/material.dart';

class EnemyHealthBar extends HealthBar {
  static Map<String, Map<String, Vector2>> healthBarOffsets = {
    'Skeleton': {
      'left': Vector2(-30, 100),
      'right': Vector2(0, -10),
    },
    'Mushroom': {
      'left': Vector2(-25, 65),
      'right': Vector2(0, 0),
    },
    'Flyingeye': {
      'left': Vector2(-25, 60),
      'right': Vector2(0, 0),
    },
  };

  EnemyHealthBar(Enemies enemy)
      : super(
          entity: enemy,
          barWidth: 25,
          barHeight: 3,
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
    final offsets = healthBarOffsets[entity.runtimeType.toString()];
    if (entity.scale.x < 0) {
      healthBar.position = entity.position - hitbox.position + offsets!['left'];
      // print('left');
    } else {
      healthBar.position =
          entity.position + hitbox.position + offsets!['right'];
      // print('right');
    }
    // print('Enemy position: ${entity.position}');
    // print('Enemy hitbox position: ${hitbox.position}');
    // print('Health bar position: ${healthBar.position}');
  }
}
