import '../config/level_config.dart';

/// Manages level state and progression
/// Will be fully implemented in Phase 3
class LevelManager {
  final LevelConfig config;
  
  double distanceTraveled = 0;
  int score = 0;
  int deliveries = 0;
  bool isCompleted = false;
  bool isFailed = false;
  
  LevelManager({required this.config});
  
  /// Update level progress
  void update(double dt, double scrollSpeed) {
    distanceTraveled += scrollSpeed * dt;
    _checkCompletion();
  }
  
  void _checkCompletion() {
    if (distanceTraveled >= config.distance) {
      if (deliveries >= config.deliveriesRequired) {
        isCompleted = true;
      } else {
        isFailed = true;
      }
    }
  }
  
  /// Calculate star rating based on current score and deliveries
  int calculateStars() {
    return config.calculateStars(score, deliveries);
  }
  
  /// Get progress as percentage (0.0 - 1.0)
  double get progress => (distanceTraveled / config.distance).clamp(0.0, 1.0);
  
  void addScore(int points) {
    score += points;
  }
  
  void addDelivery() {
    deliveries++;
  }
  
  void reset() {
    distanceTraveled = 0;
    score = 0;
    deliveries = 0;
    isCompleted = false;
    isFailed = false;
  }
}

