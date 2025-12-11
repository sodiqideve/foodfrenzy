import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../../utils/constants.dart';
import '../food_truck_game.dart';

/// Ingredient that flies from truck to customer during delivery
class FlyingIngredient extends SpriteComponent with HasGameReference<FoodTruckGame> {
  final IngredientType type;
  final Vector2 startPosition;
  final Vector2 endPosition;
  final double delay;
  
  FlyingIngredient({
    required this.type,
    required this.startPosition,
    required this.endPosition,
    required this.delay,
  }) : super(
    size: Vector2(32, 32),
    anchor: Anchor.center,
  );
  
  @override
  Future<void> onLoad() async {
    // Load sprite
    final spriteName = switch (type) {
      IngredientType.tomato => 'tomato.png',
      IngredientType.cheese => 'cheese.png',
      IngredientType.lettuce => 'lettuce.png',
      IngredientType.patty => 'burger.png',
      IngredientType.bun => 'cooked-burger.png',
    };
    sprite = await Sprite.load(spriteName);
    
    // Start invisible
    position = startPosition;
    scale = Vector2.zero();
    
    // Add animation sequence
    add(
      SequenceEffect([
        // Wait for delay
        ScaleEffect.to(
          Vector2.zero(),
          EffectController(duration: delay),
        ),
        // Pop out
        ScaleEffect.to(
          Vector2.all(1.0),
          EffectController(duration: 0.2, curve: Curves.elasticOut),
        ),
        // Fly to customer
        MoveEffect.to(
          endPosition,
          EffectController(duration: 0.5, curve: Curves.easeInOut),
        ),
        // Fade out
        OpacityEffect.fadeOut(
          EffectController(duration: 0.1),
          onComplete: () => removeFromParent(),
        ),
      ]),
    );
  }
}

