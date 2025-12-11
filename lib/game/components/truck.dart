import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';

import '../../utils/constants.dart';
import '../food_truck_game.dart';
import 'road.dart';

/// The player's food truck component
class Truck extends SpriteComponent with HasGameReference<FoodTruckGame>, CollisionCallbacks {
  int currentLane = 1; // 0 = left, 1 = center, 2 = right
  bool _isMoving = false;
  
  // Speed penalty state
  bool hasSpeedPenalty = false;
  double _penaltyTimer = 0;
  
  // Reference to road for lane positions
  Road? _road;
  
  // Idle animation state
  double _idleTime = 0;
  static const double _idleBounceMagnitude = 2.0; // Subtle bounce
  static const double _idleBounceSpeed = 3.0;
  double _baseY = 0;
  
  Truck() : super(
    size: Vector2(GameConstants.truckWidth, GameConstants.truckHeight),
    anchor: Anchor.center,
  );
  
  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('truck.png');
    
    // Add hitbox for collision detection
    add(RectangleHitbox(
      size: Vector2(size.x * 0.8, size.y * 0.9), // Slightly smaller than sprite
      position: Vector2(size.x * 0.1, size.y * 0.05),
    ));
    
    // Find road component to get lane positions
    _road = game.world.children.whereType<Road>().firstOrNull;
    
    // Set initial position
    _setInitialPosition();
  }
  
  void _setInitialPosition() {
    final screenHeight = game.size.y;
    _baseY = screenHeight * GameConstants.truckYPosition;
    
    // Get lane X position from road, or calculate fallback
    double xPosition;
    if (_road != null) {
      xPosition = _road!.getLaneX(currentLane);
    } else {
      // Fallback calculation
      final screenWidth = game.size.x;
      final sidewalkWidth = screenWidth * 0.12;
      final roadWidth = screenWidth - (sidewalkWidth * 2);
      final laneWidth = roadWidth / GameConstants.laneCount;
      xPosition = sidewalkWidth + (laneWidth * currentLane) + (laneWidth / 2);
    }
    
    position = Vector2(xPosition, _baseY);
  }
  
  /// Switch to the lane in the given direction (-1 = left, 1 = right)
  void switchLane(int direction) {
    // Don't allow lane change during active transition
    if (_isMoving) return;
    
    final newLane = currentLane + direction;
    
    // Check lane bounds
    if (newLane < 0 || newLane >= GameConstants.laneCount) return;
    
    // Get target X position
    double targetX;
    if (_road != null) {
      targetX = _road!.getLaneX(newLane);
    } else {
      // Fallback calculation
      final screenWidth = game.size.x;
      final sidewalkWidth = screenWidth * 0.12;
      final roadWidth = screenWidth - (sidewalkWidth * 2);
      final laneWidth = roadWidth / GameConstants.laneCount;
      targetX = sidewalkWidth + (laneWidth * newLane) + (laneWidth / 2);
    }
    
    _isMoving = true;
    currentLane = newLane;
    
    // Animate to new position
    add(
      MoveToEffect(
        Vector2(targetX, _baseY),
        EffectController(
          duration: GameConstants.laneSwitchDuration,
          curve: Curves.easeInOut,
        ),
        onComplete: () {
          _isMoving = false;
        },
      ),
    );
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Update penalty timer
    if (hasSpeedPenalty) {
      _penaltyTimer -= dt;
      if (_penaltyTimer <= 0) {
        hasSpeedPenalty = false;
        _penaltyTimer = 0;
      }
    }
    
    // Idle bounce animation (only when not moving lanes)
    if (!_isMoving) {
      _idleTime += dt * _idleBounceSpeed;
      final bounceOffset = sin(_idleTime) * _idleBounceMagnitude;
      position.y = _baseY + bounceOffset;
    }
  }
  
  /// Apply speed penalty after hitting obstacle
  void applySpeedPenalty() {
    hasSpeedPenalty = true;
    _penaltyTimer = GameConstants.penaltyDuration;
    
    // Visual feedback - red tint flash
    add(
      ColorEffect(
        const Color(0xFFFF0000),
        EffectController(
          duration: 0.1,
          alternate: true,
          repeatCount: 3,
        ),
        opacityFrom: 0,
        opacityTo: 0.5,
      ),
    );
  }
  
  /// Get the current effective speed multiplier
  double get speedMultiplier => hasSpeedPenalty ? GameConstants.obstacleSpeedPenalty : 1.0;
  
  /// Whether truck is currently changing lanes
  bool get isChangingLanes => _isMoving;
  
  /// Update road reference (called from game)
  void setRoad(Road road) {
    _road = road;
  }
}
