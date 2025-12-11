import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../services/audio_service.dart';
import '../../services/vibration_service.dart';
import '../../utils/constants.dart';
import '../food_truck_game.dart';
import 'game_messages.dart';
import 'particle_effects.dart';
import 'road.dart';
import 'truck.dart';

/// Collectible ingredient component
class Ingredient extends SpriteComponent with HasGameReference<FoodTruckGame>, CollisionCallbacks {
  final IngredientType type;
  final int lane;
  
  // Reference to road for lane positions
  Road? _road;
  
  bool _collected = false;
  
  // Bobbing animation state
  double _bobTime = 0;
  static const double _bobAmplitude = 3.0; // Pixels to bob up/down
  static const double _bobSpeed = 4.0; // Speed of bobbing
  double _baseY = 0; // Store the base Y position for bobbing
  
  Ingredient({
    required this.type,
    required this.lane,
  }) : super(
    size: Vector2(50, 50),
    anchor: Anchor.center,
  );
  
  @override
  Future<void> onLoad() async {
    // Load sprite based on ingredient type
    final spriteName = switch (type) {
      IngredientType.tomato => 'tomato.png',
      IngredientType.cheese => 'cheese.png',
      IngredientType.lettuce => 'lettuce.png',
      IngredientType.patty => 'burger.png',
      IngredientType.bun => 'cooked-burger.png',
    };
    sprite = await Sprite.load(spriteName);
    
    // Add hitbox for collision detection
    add(RectangleHitbox());
    
    // Find road component to get lane positions
    _road = game.world.children.whereType<Road>().firstOrNull;
    
    // Set initial position at top of screen in correct lane
    _setInitialPosition();
  }
  
  void _setInitialPosition() {
    // Get lane X position
    double xPosition;
    if (_road != null) {
      xPosition = _road!.getLaneX(lane);
    } else {
      // Fallback calculation
      final screenWidth = game.size.x;
      final sidewalkWidth = screenWidth * 0.12;
      final roadWidth = screenWidth - (sidewalkWidth * 2);
      final laneWidth = roadWidth / GameConstants.laneCount;
      xPosition = sidewalkWidth + (laneWidth * lane) + (laneWidth / 2);
    }
    
    // Start above the visible screen
    _baseY = -size.y;
    position = Vector2(xPosition, _baseY);
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    if (_collected) return;
    
    // Move downward based on game scroll speed (including endless mode bonus)
    final speed = game.currentScrollSpeed;
    _baseY += speed * dt;
    
    // Bobbing animation
    _bobTime += dt * _bobSpeed;
    final bobOffset = sin(_bobTime) * _bobAmplitude;
    position.y = _baseY + bobOffset;
    
    // Remove if passed bottom of screen
    if (_baseY > game.size.y + size.y) {
      removeFromParent();
    }
  }
  
  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    
    if (_collected) return;
    
    if (other is Truck) {
      _onCollected();
    }
  }
  
  void _onCollected() {
    _collected = true;
    
    // Try to add to inventory
    final added = game.addIngredient(type);
    
    if (added) {
      // Play collection sound and haptic feedback
      AudioService().playCollect();
      VibrationService().lightImpact();
      
      // Add sparkle particle effect
      game.world.add(CollectionParticleEffect(
        position: position.clone(),
        color: _getIngredientColor(),
      ));
      
      // Add score popup
      game.world.add(ScorePopup(
        points: GameConstants.ingredientPoints,
        position: position.clone() - Vector2(0, 20),
      ));
      
      // Show "NICE!" message on every 5th collection
      if (game.comboCount > 0 && game.comboCount % 5 == 0) {
        game.world.add(GameMessage(
          type: GameMessageType.nice,
          position: Vector2(game.size.x / 2, position.y - 40),
        ));
      }
      
      // Add score for collection
      game.addScore(GameConstants.ingredientPoints);
      game.incrementCombo();
    } else {
      // Inventory full message
      game.world.add(GameMessage(
        type: GameMessageType.inventoryFull,
        position: Vector2(game.size.x / 2, position.y - 40),
      ));
    }
    
    // Remove from game
    removeFromParent();
  }
  
  Color _getIngredientColor() {
    return switch (type) {
      IngredientType.tomato => const Color(0xFFE53935),
      IngredientType.cheese => const Color(0xFFFFCA28),
      IngredientType.lettuce => const Color(0xFF4CAF50),
      IngredientType.patty => const Color(0xFF795548),
      IngredientType.bun => const Color(0xFFFFB74D),
    };
  }
}
