import 'dart:math';

import '../../utils/constants.dart';
import '../config/level_config.dart';

/// Manages spawning of ingredients, obstacles, and customers
class SpawnManager {
  final LevelConfig? levelConfig;
  final bool isEndlessMode;
  final Random _random = Random();

  double _ingredientTimer = 0;
  double _obstacleTimer = 0;
  double _customerTimer = 0;

  SpawnManager({this.levelConfig, this.isEndlessMode = false});

  /// Update spawn timers and spawn new entities
  /// [endlessDistanceTraveled] is used to scale difficulty in endless mode
  void update(
    double dt, {
    required void Function(IngredientType type, int lane) onSpawnIngredient,
    required void Function(ObstacleType type, int lane) onSpawnObstacle,
    required void Function(List<IngredientType> order, bool isLeftSide)
    onSpawnCustomer,
    double? endlessDistanceTraveled,
  }) {
    _ingredientTimer += dt;
    _obstacleTimer += dt;
    _customerTimer += dt;

    // Calculate spawn rates (lower = more frequent)
    final difficultyMultiplier = _getDifficultyMultiplier(
      endlessDistanceTraveled,
    );

    final ingredientRate =
        (levelConfig?.ingredientSpawnRate ??
            GameConstants.minIngredientSpawnInterval) *
        difficultyMultiplier;
    final obstacleRate =
        (levelConfig?.obstacleSpawnRate ??
            GameConstants.minObstacleSpawnInterval) *
        difficultyMultiplier;
    final customerRate =
        (levelConfig?.customerSpawnRate ??
            GameConstants.minCustomerSpawnInterval) *
        difficultyMultiplier;

    // Spawn ingredient
    if (_ingredientTimer >= ingredientRate) {
      _ingredientTimer = 0;
      final type = _getRandomIngredient(endlessDistanceTraveled);
      final lane = _random.nextInt(GameConstants.laneCount);
      onSpawnIngredient(type, lane);
    }

    // Spawn obstacle
    if (_obstacleTimer >= obstacleRate) {
      _obstacleTimer = 0;
      final type =
          ObstacleType.values[_random.nextInt(ObstacleType.values.length)];
      final lane = _random.nextInt(GameConstants.laneCount);
      onSpawnObstacle(type, lane);
    }

    // Spawn customer
    if (_customerTimer >= customerRate) {
      _customerTimer = 0;
      final order = _generateRandomOrder(endlessDistanceTraveled);
      final isLeftSide = _random.nextBool();
      onSpawnCustomer(order, isLeftSide);
    }
  }

  /// Get allowed ingredients based on level
  List<IngredientType> _getAllowedIngredients(double? endlessDistance) {
    if (isEndlessMode) {
      // Unlock more ingredients over distance in endless mode
      final difficultyLevel =
          ((endlessDistance ?? 0) /
                  GameConstants.endlessDifficultyIncreaseInterval)
              .floor();
      if (difficultyLevel >= 4) return IngredientType.values;
      if (difficultyLevel >= 2) return IngredientType.values.take(4).toList();
      return IngredientType.values.take(3).toList();
    }

    final level = levelConfig?.levelNumber ?? 1;
    // Level 1-5 (Easy): First 2 ingredients (Tomato, Cheese)
    if (level <= 5) return IngredientType.values.take(2).toList();
    // Level 6-8 (Medium): First 3 ingredients (+ Lettuce)
    if (level <= 8) return IngredientType.values.take(3).toList();
    // Level 9-11 (Medium-Hard): First 4 ingredients (+ Patty)
    if (level <= 11) return IngredientType.values.take(4).toList();
    // Level 12+: All 5 ingredients (+ Bun)
    return IngredientType.values;
  }

  IngredientType _getRandomIngredient(double? endlessDistance) {
    final allowed = _getAllowedIngredients(endlessDistance);
    return allowed[_random.nextInt(allowed.length)];
  }

  List<IngredientType> _generateRandomOrder(double? endlessDistance) {
    int maxOrderSize = 3;
    final allowed = _getAllowedIngredients(endlessDistance);

    // Scale order size by level
    if (isEndlessMode && endlessDistance != null) {
      final difficultyLevel =
          (endlessDistance / GameConstants.endlessDifficultyIncreaseInterval)
              .floor();
      if (difficultyLevel >= 6) {
        maxOrderSize = 5;
      } else if (difficultyLevel >= 3) {
        maxOrderSize = 4;
      }
    } else {
      final level = levelConfig?.levelNumber ?? 1;
      // Levels 1-5 (Easy): Single item orders ONLY
      if (level <= 5) {
        maxOrderSize = 1;
      }
      // Levels 6-10 (Medium): Up to 2 items
      else if (level <= 10) {
        maxOrderSize = 2;
      }
      // Levels 11+ (Hard): Up to 3 items
      else {
        maxOrderSize = 3;
      }
    }

    final orderSize = _random.nextInt(maxOrderSize) + 1;
    final order = <IngredientType>[];
    for (int i = 0; i < orderSize; i++) {
      order.add(allowed[_random.nextInt(allowed.length)]);
    }
    return order;
  }

  /// Calculate difficulty multiplier for spawn rates
  /// Returns a value between 0.5 and 1.0 - lower means faster spawning (harder)
  double _getDifficultyMultiplier(double? endlessDistance) {
    if (!isEndlessMode || endlessDistance == null) {
      return 1.0; // Normal difficulty for story mode
    }

    // In endless mode, gradually decrease multiplier (faster spawns)
    final difficultyLevel =
        (endlessDistance / GameConstants.endlessDifficultyIncreaseInterval)
            .floor();

    // Cap at 0.5 (2x spawn rate) to prevent impossible difficulty
    return (1.0 - (difficultyLevel * 0.1)).clamp(0.5, 1.0);
  }

  void reset() {
    _ingredientTimer = 0;
    _obstacleTimer = 0;
    _customerTimer = 0;
  }
}
