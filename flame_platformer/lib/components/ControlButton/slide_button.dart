import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_platformer/flame_platformer.dart';

class SLideButton extends SpriteComponent
    with HasGameRef<FlamePlatformer>, TapCallbacks {
  SLideButton();

  final margin = 32;
  final buttonSize = 36;
  final spacing = 16;
  final offsetX = 20;

  @override
  FutureOr<void> onLoad() {
    sprite = Sprite(game.images.fromCache('HUD/SlideButton.png'));
    position = Vector2(
      game.size.x - margin - buttonSize - offsetX,
      game.size.y - margin - buttonSize - 10,
    );
    priority = 10;
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.player.isSliding = true;
    Future.delayed(Duration(milliseconds: 700), () {
      game.player.isSliding = false;
    });
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
  }
}
