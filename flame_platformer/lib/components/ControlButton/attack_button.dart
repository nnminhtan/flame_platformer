import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_platformer/flame_platformer.dart';

class AttackButton extends SpriteComponent
    with HasGameRef<FlamePlatformer>, TapCallbacks {
  AttackButton();

  final margin = 32;
  final buttonSize = 64;
  final offsetX = 80;

  @override
  FutureOr<void> onLoad() {
    sprite = Sprite(game.images.fromCache('HUD/AttackButton.png'));
    position = Vector2(
      game.size.x - margin - buttonSize - offsetX,
      game.size.y - margin - buttonSize,
    );
    priority = 10;
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!game.player.isAttacking) {
      game.player.UpdateAttackButton();
    }
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
  }
}
