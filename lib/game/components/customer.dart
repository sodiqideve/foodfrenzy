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

/// Customer on the sidewalk waiting for delivery
class Customer extends PositionComponent
    with HasGameReference<FoodTruckGame>, CollisionCallbacks {
  final List<IngredientType> order;
  final bool isOnLeftSide;

  // Reference to road for positioning
  Road? _road;

  // Delivery zone hitbox
  late RectangleHitbox _deliveryZone;

  // State
  bool _delivered = false;
  bool _inDeliveryRange = false;

  Customer({required this.order, required this.isOnLeftSide})
    : super(size: Vector2(70, 90), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // Find road component
    _road = game.world.children.whereType<Road>().firstOrNull;

    // Set initial position on sidewalk
    _setInitialPosition();

    // Add delivery zone hitbox (larger area for delivery detection)
    // Extend horizontally to reach the truck on the road
    final screenWidth = game.size.x;
    final deliveryWidth = screenWidth * 0.5; // Wide enough to reach truck lanes

    _deliveryZone = RectangleHitbox(
      size: Vector2(deliveryWidth, size.y * 1.5),
      position: isOnLeftSide
          ? Vector2(0, -size.y * 0.25) // Extend right from left customer
          : Vector2(
              -deliveryWidth + size.x,
              -size.y * 0.25,
            ), // Extend left from right customer
      collisionType:
          CollisionType.active, // Active to trigger collision callbacks
    );
    add(_deliveryZone);

    // Add customer visual components
    await _addVisuals();
  }

  void _setInitialPosition() {
    final screenWidth = game.size.x;
    final sidewalkWidth = _road?.sidewalkWidth ?? (screenWidth * 0.12);

    // Position on left or right sidewalk
    double xPosition;
    if (isOnLeftSide) {
      xPosition = sidewalkWidth / 2;
    } else {
      xPosition = screenWidth - (sidewalkWidth / 2);
    }

    // Start above the visible screen
    position = Vector2(xPosition, -size.y);
  }

  Future<void> _addVisuals() async {
    // Random customer sprite
    final random = Random();
    final customerIndex = random.nextInt(3) + 1; // 1, 2, or 3
    final customerSprite = await Sprite.load(
      'customers/customer$customerIndex.png',
    );

    add(
      SpriteComponent(
        sprite: customerSprite,
        size: Vector2(60, 80),
        position: Vector2(5, 5),
      ),
    );

    // Add order bubble
    add(OrderBubble(order: order, isOnLeftSide: isOnLeftSide));
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_delivered) return;

    // Move downward based on game scroll speed (including endless mode bonus)
    final speed = game.currentScrollSpeed;
    position.y += speed * dt;

    // Continuously check for delivery while in range (player may switch lanes)
    if (_inDeliveryRange) {
      _tryDeliver();
    }

    // Remove if passed bottom of screen
    if (position.y > game.size.y + size.y) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (_delivered) return;

    if (other is Truck) {
      _inDeliveryRange = true;
      _tryDeliver();
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);

    if (other is Truck) {
      _inDeliveryRange = false;
    }
  }

  void _tryDeliver() {
    if (_delivered || !_inDeliveryRange) return;

    // Check if truck is in the correct lane for this customer
    // Left customer requires lane 0, right customer requires lane 2
    final requiredLane = isOnLeftSide ? 0 : 2;
    final truckLane = game.truck.currentLane;

    if (truckLane != requiredLane) {
      // Truck is not in the correct lane - don't deliver
      return;
    }

    // Check if player has ingredients before attempting delivery (to avoid unnecessary pauses)
    final canDeliver = game.canDeliverOrder(order);

    if (canDeliver) {
      // Start delivery sequence
      _delivered = true;

      // Pause game movement for delivery animation
      game.startDeliverySequence(this);
    } else {
      // Show feedback that we are missing items
      game.world.add(
        GameMessage(
          type: GameMessageType.missingIngredients,
          position: Vector2(game.size.x / 2, position.y - 60),
        ),
      );
    }
  }

  /// Completes the delivery after animation
  void completeDelivery(
    List<IngredientType> deliveredIngredients,
    bool isFullDelivery,
  ) {
    // Actually remove ingredients and add score
    game.completeDelivery(deliveredIngredients, isFullDelivery: isFullDelivery);

    // Play delivery sound and haptic feedback
    AudioService().playDeliver();
    VibrationService().mediumImpact();

    // Add delivery particle effects (coins/stars)
    game.world.add(DeliveryParticleEffect(position: position.clone()));

    // Calculate points for popup
    final basePoints =
        deliveredIngredients.length * GameConstants.deliveryPointsPerItem;
    final totalPoints = isFullDelivery
        ? basePoints + GameConstants.fullDeliveryBonus
        : basePoints;

    // Add score popup for delivery
    game.world.add(
      ScorePopup(
        points: totalPoints,
        position: position.clone() - Vector2(0, 30),
      ),
    );

    // Show appropriate message based on delivery completeness
    game.world.add(
      GameMessage(
        type: isFullDelivery
            ? GameMessageType.perfect
            : GameMessageType.partialDelivery,
        position: Vector2(game.size.x / 2, position.y - 60),
      ),
    );

    // Visual feedback - fade out and remove
    _showDeliverySuccess();
  }

  void _showDeliverySuccess() {
    // Simple removal after short delay
    Future.delayed(const Duration(milliseconds: 200), () {
      if (isMounted) {
        removeFromParent();
      }
    });
  }
}

/// Order bubble showing required ingredients
class OrderBubble extends PositionComponent {
  final List<IngredientType> order;
  final bool isOnLeftSide;

  OrderBubble({required this.order, required this.isOnLeftSide})
    : super(
        size: Vector2(100, 60), // Increased size for text
      );

  @override
  Future<void> onLoad() async {
    // Position bubble above customer, offset based on side
    if (isOnLeftSide) {
      position = Vector2(40, -30);
    } else {
      position = Vector2(-40, -30);
    }

    // Calculate bubble width based on items
    final bubbleWidth = 20.0 + (order.length * 60.0);

    // Bubble background
    add(
      RectangleComponent(
        size: Vector2(bubbleWidth, 50),
        position: Vector2.zero(),
        paint: Paint()..color = Colors.white,
      )..add(
        RectangleComponent(
          size: Vector2(bubbleWidth - 2, 48),
          position: Vector2(1, 1),
          paint: Paint()..color = const Color(0xFFFFF8E1), // Light cream
        ),
      ),
    );

    // Add ingredient icons with text
    for (int i = 0; i < order.length; i++) {
      add(IngredientItem(type: order[i], position: Vector2(10 + (i * 60), 5)));
    }
  }
}

/// Ingredient icon with text for order bubble
class IngredientItem extends PositionComponent {
  final IngredientType type;

  IngredientItem({required this.type, required Vector2 position})
    : super(position: position, size: Vector2(50, 40));

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

    final sprite = await Sprite.load(spriteName);

    // Draw ingredient sprite
    add(
      SpriteComponent(
        sprite: sprite,
        size: Vector2(24, 24),
        position: Vector2(13, 0),
      ),
    );

    // Add text label
    final textName = switch (type) {
      IngredientType.tomato => 'Tomato',
      IngredientType.cheese => 'Cheese',
      IngredientType.lettuce => 'Lettuce',
      IngredientType.patty => 'Patty',
      IngredientType.bun => 'Bun',
    };

    add(
      TextComponent(
        text: textName,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.black,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        position: Vector2(25, 26),
        anchor: Anchor.topCenter,
      ),
    );
  }
}
