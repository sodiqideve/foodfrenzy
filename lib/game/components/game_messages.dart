import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../utils/constants.dart';

/// Types of game messages that can be displayed
enum GameMessageType {
  perfect, // Perfect delivery (all items)
  partialDelivery, // Partial delivery (some items)
  nice, // Good collection streak
  speedDown, // Hit obstacle, speed reduced
  comboLost, // Lost combo streak
  inventoryFull, // Can't pick up more
  missingIngredients, // Tried to deliver but missing items
}

/// Temporary message that appears in the game
class GameMessage extends TextComponent {
  final GameMessageType type;
  double _elapsed = 0;
  static const double _duration = 1.2;
  final Vector2 _startPosition;

  GameMessage({required this.type, required Vector2 position})
    : _startPosition = position.clone(),
      super(
        text: _getText(type),
        position: position,
        anchor: Anchor.center,
        textRenderer: _getTextPaint(type),
      );

  static String _getText(GameMessageType type) {
    return switch (type) {
      GameMessageType.perfect => 'PERFECT!',
      GameMessageType.partialDelivery => 'DELIVERED!',
      GameMessageType.nice => 'NICE!',
      GameMessageType.speedDown => '-SPEED',
      GameMessageType.comboLost => 'COMBO LOST',
      GameMessageType.inventoryFull => 'INVENTORY FULL!',
      GameMessageType.missingIngredients => 'MISSING ITEMS!',
    };
  }

  static TextPaint _getTextPaint(GameMessageType type) {
    final color = switch (type) {
      GameMessageType.perfect => GameColors.starFilled,
      GameMessageType.partialDelivery => GameColors.success,
      GameMessageType.nice => GameColors.success,
      GameMessageType.speedDown => GameColors.error,
      GameMessageType.comboLost => GameColors.warning,
      GameMessageType.inventoryFull => GameColors.warning,
      GameMessageType.missingIngredients => GameColors.error,
    };

    return TextPaint(
      style: TextStyle(
        color: color,
        fontSize: 32,
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
        shadows: const [
          Shadow(color: Colors.black87, blurRadius: 8, offset: Offset(2, 2)),
          Shadow(color: Colors.black54, blurRadius: 16, offset: Offset(0, 0)),
        ],
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;

    final progress = _elapsed / _duration;

    // Move up
    position.y = _startPosition.y - (progress * 60);

    // Scale effect: grow then shrink
    double scale;
    if (progress < 0.15) {
      scale = 0.5 + (progress / 0.15) * 0.7; // Grow to 1.2
    } else if (progress < 0.3) {
      scale = 1.2 - ((progress - 0.15) / 0.15) * 0.2; // Shrink to 1.0
    } else {
      scale = 1.0;
    }

    // Fade out in last third
    final opacity = progress > 0.6
        ? (1 - (progress - 0.6) / 0.4).clamp(0.0, 1.0)
        : 1.0;

    final color = switch (type) {
      GameMessageType.perfect => GameColors.starFilled,
      GameMessageType.partialDelivery => GameColors.success,
      GameMessageType.nice => GameColors.success,
      GameMessageType.speedDown => GameColors.error,
      GameMessageType.comboLost => GameColors.warning,
      GameMessageType.inventoryFull => GameColors.warning,
      GameMessageType.missingIngredients => GameColors.error,
    };

    textRenderer = TextPaint(
      style: TextStyle(
        color: color.withValues(alpha: opacity),
        fontSize: 32 * scale,
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
        shadows: [
          Shadow(
            color: Colors.black87.withValues(alpha: opacity),
            blurRadius: 8,
            offset: const Offset(2, 2),
          ),
          Shadow(
            color: Colors.black54.withValues(alpha: opacity),
            blurRadius: 16,
            offset: Offset.zero,
          ),
        ],
      ),
    );

    if (_elapsed >= _duration) {
      removeFromParent();
    }
  }
}

/// Level start countdown message
class LevelStartMessage extends TextComponent {
  int _countdown = 3;
  double _elapsed = 0;
  static const double _intervalDuration = 1.0;
  final VoidCallback? onComplete;

  LevelStartMessage({required Vector2 position, this.onComplete})
    : super(
        text: '3',
        position: position,
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: GameColors.textPrimary,
            fontSize: 72,
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(
                color: Colors.black87,
                blurRadius: 12,
                offset: Offset(3, 3),
              ),
            ],
          ),
        ),
      );

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;

    final intervalProgress = (_elapsed % _intervalDuration) / _intervalDuration;

    // Update countdown
    if (_elapsed >= _intervalDuration && _countdown > 1) {
      _countdown--;
      _elapsed = 0;
      text = _countdown == 0 ? 'GO!' : '$_countdown';
    } else if (_countdown == 1 && _elapsed >= _intervalDuration) {
      text = 'GO!';
      _countdown = 0;
    }

    // Scale animation within each interval
    double scale;
    if (intervalProgress < 0.2) {
      scale = 0.5 + (intervalProgress / 0.2) * 0.7;
    } else {
      scale = 1.2 - ((intervalProgress - 0.2) / 0.8) * 0.2;
    }

    final color = _countdown == 0 ? GameColors.success : GameColors.textPrimary;

    textRenderer = TextPaint(
      style: TextStyle(
        color: color,
        fontSize: 72 * scale,
        fontWeight: FontWeight.w900,
        shadows: const [
          Shadow(color: Colors.black87, blurRadius: 12, offset: Offset(3, 3)),
        ],
      ),
    );

    // Remove after "GO!" is shown
    if (_countdown == 0 && _elapsed >= 0.8) {
      onComplete?.call();
      removeFromParent();
    }
  }
}
