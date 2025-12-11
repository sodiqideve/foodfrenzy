import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../../services/audio_service.dart';
import '../../services/vibration_service.dart';
import '../../utils/constants.dart';
import '../food_truck_game.dart';
import 'game_messages.dart';
import 'road.dart';
import 'truck.dart';

/// Obstacle component that slows down the truck
class Obstacle extends SpriteComponent with HasGameReference<FoodTruckGame>, CollisionCallbacks {
  final ObstacleType type;
  final int lane;
  
  // Reference to road for lane positions
  Road? _road;
  
  bool _hitByTruck = false;
  
  Obstacle({
    required this.type,
    required this.lane,
  }) : super(
    size: _getSizeForType(type),
    anchor: Anchor.center,
  );
  
  static Vector2 _getSizeForType(ObstacleType type) {
    return switch (type) {
      ObstacleType.cone => Vector2(40, 50),
      ObstacleType.pothole => Vector2(60, 40),
      ObstacleType.barrier => Vector2(70, 50),
    };
  }
  
  @override
  Future<void> onLoad() async {
    // Load sprite based on obstacle type
    final spriteName = switch (type) {
      ObstacleType.cone => 'traffic-cone.png',
      ObstacleType.pothole => 'pothole.png',
      ObstacleType.barrier => 'wooden-construction-barrier.png',
    };
    sprite = await Sprite.load(spriteName);
    
    // Add hitbox for collision detection
    add(RectangleHitbox(
      size: Vector2(size.x * 0.8, size.y * 0.8),
      position: Vector2(size.x * 0.1, size.y * 0.1),
    ));
    
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
    position = Vector2(xPosition, -size.y);
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Move downward based on game scroll speed (including endless mode bonus)
    final speed = game.currentScrollSpeed;
    position.y += speed * dt;
    
    // Remove if passed bottom of screen
    if (position.y > game.size.y + size.y) {
      removeFromParent();
    }
  }
  
  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    
    if (_hitByTruck) return;
    
    if (other is Truck) {
      _onHitByTruck(other);
    }
  }
  
  void _onHitByTruck(Truck truck) {
    _hitByTruck = true;
    
    // Play hit sound and haptic feedback
    AudioService().playHit();
    VibrationService().heavyImpact();
    
    // Apply speed penalty to truck
    truck.applySpeedPenalty();
    
    // Show -SPEED message
    game.world.add(GameMessage(
      type: GameMessageType.speedDown,
      position: position.clone() - Vector2(0, 30),
    ));
    
    // Reset combo (this will show COMBO LOST if applicable)
    game.resetCombo();
    
    // In endless mode, lose a life
    if (game.isEndlessMode) {
      game.loseLife();
    }
    
    // Remove obstacle after hit
    removeFromParent();
  }
}
