import 'package:flutter/material.dart';

/// Game constants and configuration values
class GameConstants {
  // Game dimensions
  static const double laneWidth = 100.0;
  static const int laneCount = 3;

  // Truck settings
  static const double truckWidth = 80.0;
  static const double truckHeight = 120.0;
  static const double truckYPosition = 0.75; // 75% from top
  static const double laneSwitchDuration = 0.2; // seconds

  // Game speed
  static const double baseScrollSpeed = 200.0;
  static const double maxScrollSpeed = 500.0;

  // Scoring
  static const int ingredientPoints = 10;
  static const int deliveryPoints = 100; // Legacy - kept for compatibility
  static const int deliveryPointsPerItem = 50; // Points per item delivered
  static const int fullDeliveryBonus =
      50; // Bonus for delivering all items in order
  static const int distancePointsInterval =
      100; // Award points every X distance units
  static const int distancePoints = 5; // Points per interval
  static const double comboMultiplier1 = 1.5;
  static const double comboMultiplier2 = 2.0;
  static const double comboMultiplier3 = 2.5;

  // Endless mode
  static const double endlessDifficultyIncreaseInterval = 500; // Distance units
  static const double endlessSpeedIncrease = 10; // Speed increase per interval
  static const double endlessMaxSpeed = 400; // Maximum scroll speed
  static const int endlessStartingLives = 3; // Lives in endless mode

  // Inventory
  static const int maxInventorySize = 10;

  // Spawning intervals (seconds)
  static const double minIngredientSpawnInterval = 0.8;
  static const double maxIngredientSpawnInterval = 2.0;
  static const double minObstacleSpawnInterval = 2.0;
  static const double maxObstacleSpawnInterval = 4.0;
  static const double minCustomerSpawnInterval = 3.0;
  static const double maxCustomerSpawnInterval = 6.0;

  // Speed reduction on obstacle hit
  static const double obstacleSpeedPenalty = 0.5;
  static const double penaltyDuration = 2.0; // seconds
}

/// Route names for navigation
class RouteNames {
  static const String mainMenu = 'main-menu';
  static const String levelSelect = 'level-select';
  static const String game = 'game';
  static const String pause = 'pause';
  static const String levelComplete = 'level-complete';
  static const String levelFailed = 'level-failed';
  static const String settings = 'settings';
  static const String tutorial = 'tutorial';
  static const String endless = 'endless';
}

/// Color palette for the game
class GameColors {
  // Primary colors
  static const Color primary = Color(0xFFFF6B35);
  static const Color secondary = Color(0xFF004E89);
  static const Color accent = Color(0xFFFFC700);

  // Background colors
  static const Color background = Color(0xFF1A1A2E);
  static const Color surface = Color(0xFF16213E);
  static const Color surfaceLight = Color(0xFF0F3460);

  // Road colors
  static const Color roadDark = Color(0xFF2D2D2D);
  static const Color roadLight = Color(0xFF3D3D3D);
  static const Color laneMarker = Color(0xFFFFFFFF);
  static const Color sidewalk = Color(0xFF8B7355);

  // UI colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFB300);

  // Star colors
  static const Color starFilled = Color(0xFFFFD700);
  static const Color starEmpty = Color(0xFF555555);
}

/// Ingredient types
enum IngredientType { tomato, cheese, lettuce, patty, bun }

/// Obstacle types
enum ObstacleType { cone, pothole, barrier }

/// Game state
enum GameState { playing, paused, levelComplete, levelFailed }
