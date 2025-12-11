import 'package:flame/components.dart';

/// Manages collision detection between game entities
/// Will be fully implemented in Phase 2
class CollisionManager {
  /// Check if two components are colliding
  static bool checkCollision(PositionComponent a, PositionComponent b) {
    // Simple AABB collision detection
    final aRect = a.toRect();
    final bRect = b.toRect();
    return aRect.overlaps(bRect);
  }
  
  /// Check if a component is within delivery range
  static bool isInDeliveryRange(PositionComponent truck, PositionComponent customer) {
    final distance = truck.position.distanceTo(customer.position);
    return distance < 100; // Delivery range threshold
  }
}

