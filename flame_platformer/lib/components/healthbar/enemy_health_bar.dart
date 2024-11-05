import 'package:flame/components.dart';
import 'package:flame_platformer/components/Enemies/Boss.dart';
import 'package:flame_platformer/components/Enemies/Enemies.dart';
import 'package:flame_platformer/components/Enemies/Shit.dart';
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
    'Boss': {
      'left': Vector2(-40, 120),
      'right': Vector2(10, -15),
    },
    'Shit': {
      'left': Vector2(-20, 50),
      'right': Vector2(5, -5),
    },
  };

  // Constructor nhận một đối tượng `PositionComponent` chung.
  EnemyHealthBar(PositionComponent entity)
      : super(
          entity: entity,
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
    // Lấy hitbox của entity
    final hitbox = entity is Enemies || entity is Boss || entity is Shit
        ? (entity as dynamic).getHitbox()
        : entity.position;

    // Lấy offsets dựa trên loại của entity
    final offsets = healthBarOffsets[entity.runtimeType.toString()];
    if (offsets != null) {
      if (entity.scale.x < 0) {
        healthBar.position =
            entity.position - hitbox.position + offsets['left']!;
      } else {
        healthBar.position =
            entity.position + hitbox.position + offsets['right']!;
      }
    }
  }
}
