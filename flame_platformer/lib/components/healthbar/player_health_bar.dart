import 'package:flame/components.dart';
import 'package:flame_platformer/components/healthbar/health_bar.dart';
import 'package:flame_platformer/components/player.dart';
import 'package:flutter/material.dart';

class PlayerHealthBar extends HealthBar {
  late SpriteComponent background;
  late SpriteComponent heartIcon;
  late TextComponent hpNumber;

  PlayerHealthBar(Player player)
      : super(
          entity: player,
          barWidth: 250,
          barHeight: 20,
          barColor: Colors.green,
        );

  @override
  Future<void> onLoad() async {
    super.onLoad();

    background = SpriteComponent()
      ..sprite = await gameRef.loadSprite('HealthBar/Bar.png')
      ..size = Vector2(barWidth, barHeight)
      ..position = Vector2(30, 20);
    add(background);

    heartIcon = SpriteComponent()
      ..sprite = await gameRef.loadSprite('HealthBar/Heart.png')
      ..size = Vector2(20, 20)
      ..position = Vector2(30, 20);
    add(heartIcon);

    hpNumber = TextComponent(
      text: '${entity.hp.toInt()}',
      position: Vector2(barWidth - 30, 20),
      textRenderer:
          TextPaint(style: const TextStyle(color: Colors.white, fontSize: 15)),
    );
    add(hpNumber);
  }

  @override
  void update(double dt) {
    super.update(dt);
    hpNumber.text = '${entity.hp.toInt()}'; // Update the displayed HP number
  }

  @override
  void setHealthBarPosition() {
    healthBar.position = Vector2(30, 20);
  }
}
