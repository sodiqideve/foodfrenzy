/// Configuration for a single level
class LevelConfig {
  final int levelNumber;
  final double distance; // Total distance to complete level
  final int deliveriesRequired; // Minimum deliveries to pass
  final double scrollSpeed; // Base scroll speed
  final double ingredientSpawnRate; // Lower = more frequent
  final double obstacleSpawnRate; // Lower = more frequent
  final double customerSpawnRate; // Lower = more frequent
  final int star2Score; // Score needed for 2 stars
  final int star3Score; // Score needed for 3 stars

  const LevelConfig({
    required this.levelNumber,
    required this.distance,
    required this.deliveriesRequired,
    required this.scrollSpeed,
    required this.ingredientSpawnRate,
    required this.obstacleSpawnRate,
    required this.customerSpawnRate,
    required this.star2Score,
    required this.star3Score,
  });

  /// Calculate star rating based on score
  int calculateStars(int score, int deliveries) {
    if (deliveries < deliveriesRequired) return 0;
    if (score >= star3Score) return 3;
    if (score >= star2Score) return 2;
    return 1;
  }
}

/// All level configurations
class LevelConfigs {
  static const int totalLevels = 15;

  static final List<LevelConfig> levels = [
    // ========================================
    // EASY LEVELS (1-5): Single item orders, slow pace, lots of time
    // ========================================

    // Level 1 - Tutorial/Very Easy
    const LevelConfig(
      levelNumber: 1,
      distance: 4000, // Long level for learning
      deliveriesRequired: 2,
      scrollSpeed: 180, // Very slow
      ingredientSpawnRate: 1.5,
      obstacleSpawnRate: 5.0, // Very few obstacles
      customerSpawnRate: 4.0,
      star2Score: 300,
      star3Score: 500,
    ),
    // Level 2 - Still Easy
    const LevelConfig(
      levelNumber: 2,
      distance: 4500,
      deliveriesRequired: 2,
      scrollSpeed: 190,
      ingredientSpawnRate: 1.4,
      obstacleSpawnRate: 4.5,
      customerSpawnRate: 3.8,
      star2Score: 400,
      star3Score: 650,
    ),
    // Level 3 - Easy with slightly more customers
    const LevelConfig(
      levelNumber: 3,
      distance: 5000,
      deliveriesRequired: 3, // Only 3 deliveries required
      scrollSpeed: 195, // Still slow
      ingredientSpawnRate: 1.3,
      obstacleSpawnRate: 4.0, // Still few obstacles
      customerSpawnRate: 3.5,
      star2Score: 500,
      star3Score: 800,
    ),
    // Level 4 - Easy, slightly longer
    const LevelConfig(
      levelNumber: 4,
      distance: 5500,
      deliveriesRequired: 3,
      scrollSpeed: 200,
      ingredientSpawnRate: 1.3,
      obstacleSpawnRate: 3.8,
      customerSpawnRate: 3.3,
      star2Score: 600,
      star3Score: 950,
    ),
    // Level 5 - Easy, last relaxed level
    const LevelConfig(
      levelNumber: 5,
      distance: 6000,
      deliveriesRequired: 4,
      scrollSpeed: 210,
      ingredientSpawnRate: 1.2,
      obstacleSpawnRate: 3.5,
      customerSpawnRate: 3.2,
      star2Score: 700,
      star3Score: 1100,
    ),

    // ========================================
    // MEDIUM LEVELS (6-10): Introduce 2-item orders gradually
    // ========================================

    // Level 6 - First challenge: 2-item orders introduced
    const LevelConfig(
      levelNumber: 6,
      distance: 6500,
      deliveriesRequired: 4,
      scrollSpeed: 220,
      ingredientSpawnRate: 1.2,
      obstacleSpawnRate: 3.2,
      customerSpawnRate: 3.0,
      star2Score: 900,
      star3Score: 1400,
    ),
    // Level 7 - Medium difficulty
    const LevelConfig(
      levelNumber: 7,
      distance: 7000,
      deliveriesRequired: 5,
      scrollSpeed: 235,
      ingredientSpawnRate: 1.1,
      obstacleSpawnRate: 3.0,
      customerSpawnRate: 2.8,
      star2Score: 1100,
      star3Score: 1700,
    ),
    // Level 8 - Medium-Hard
    const LevelConfig(
      levelNumber: 8,
      distance: 7500,
      deliveriesRequired: 5,
      scrollSpeed: 250,
      ingredientSpawnRate: 1.0,
      obstacleSpawnRate: 2.8,
      customerSpawnRate: 2.6,
      star2Score: 1300,
      star3Score: 2000,
    ),
    // Level 9 - Getting harder
    const LevelConfig(
      levelNumber: 9,
      distance: 8000,
      deliveriesRequired: 6,
      scrollSpeed: 265,
      ingredientSpawnRate: 0.95,
      obstacleSpawnRate: 2.5,
      customerSpawnRate: 2.4,
      star2Score: 1500,
      star3Score: 2300,
    ),
    // Level 10 - Challenge milestone
    const LevelConfig(
      levelNumber: 10,
      distance: 8500,
      deliveriesRequired: 6,
      scrollSpeed: 280,
      ingredientSpawnRate: 0.9,
      obstacleSpawnRate: 2.3,
      customerSpawnRate: 2.2,
      star2Score: 1700,
      star3Score: 2600,
    ),

    // ========================================
    // HARD LEVELS (11-15): 3-item orders, faster pace
    // ========================================

    // Level 11 - Hard
    const LevelConfig(
      levelNumber: 11,
      distance: 9000,
      deliveriesRequired: 7,
      scrollSpeed: 300,
      ingredientSpawnRate: 0.85,
      obstacleSpawnRate: 2.1,
      customerSpawnRate: 2.0,
      star2Score: 2000,
      star3Score: 3000,
    ),
    // Level 12 - Harder
    const LevelConfig(
      levelNumber: 12,
      distance: 9500,
      deliveriesRequired: 7,
      scrollSpeed: 320,
      ingredientSpawnRate: 0.8,
      obstacleSpawnRate: 1.9,
      customerSpawnRate: 1.9,
      star2Score: 2300,
      star3Score: 3400,
    ),
    // Level 13 - Very Hard
    const LevelConfig(
      levelNumber: 13,
      distance: 10000,
      deliveriesRequired: 8,
      scrollSpeed: 340,
      ingredientSpawnRate: 0.75,
      obstacleSpawnRate: 1.7,
      customerSpawnRate: 1.8,
      star2Score: 2600,
      star3Score: 3800,
    ),
    // Level 14 - Expert
    const LevelConfig(
      levelNumber: 14,
      distance: 10500,
      deliveriesRequired: 8,
      scrollSpeed: 360,
      ingredientSpawnRate: 0.7,
      obstacleSpawnRate: 1.5,
      customerSpawnRate: 1.7,
      star2Score: 2900,
      star3Score: 4200,
    ),
    // Level 15 - Final Level / Master
    const LevelConfig(
      levelNumber: 15,
      distance: 11000,
      deliveriesRequired: 10,
      scrollSpeed: 380,
      ingredientSpawnRate: 0.65,
      obstacleSpawnRate: 1.4,
      customerSpawnRate: 1.6,
      star2Score: 3500,
      star3Score: 5000,
    ),
  ];

  /// Get config for a specific level (1-indexed)
  static LevelConfig getLevel(int levelNumber) {
    if (levelNumber < 1 || levelNumber > totalLevels) {
      throw ArgumentError('Invalid level number: $levelNumber');
    }
    return levels[levelNumber - 1];
  }

  /// Check if endless mode is unlocked
  static bool isEndlessModeUnlocked(int highestCompletedLevel) {
    return highestCompletedLevel >= totalLevels;
  }
}
