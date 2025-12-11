import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/audio_service.dart';
import '../services/vibration_service.dart';
import '../utils/constants.dart';
import 'components/customer.dart';
import 'components/flying_ingredient.dart';
import 'components/game_messages.dart';
import 'components/ingredient.dart';
import 'components/obstacle.dart';
import 'components/particle_effects.dart';
import 'components/road.dart';
import 'components/truck.dart';
import 'config/level_config.dart';
import 'managers/spawn_manager.dart';

/// Main game class for Food Truck Frenzy
class FoodTruckGame extends FlameGame
    with
        HasCollisionDetection,
        TapCallbacks,
        HorizontalDragDetector,
        KeyboardEvents {
  // Current level configuration
  LevelConfig? currentLevel;
  bool isEndlessMode = false;

  // Game state
  GameState gameState = GameState.playing;
  int score = 0;
  int deliveries = 0;
  double distanceTraveled = 0;
  int comboCount = 0;
  double comboMultiplier = 1.0;

  // Distance scoring tracker
  double _lastDistanceScorePoint = 0;

  // Endless mode state
  double _endlessSpeedBonus = 0;
  int lives = 0; // Lives for endless mode

  // Inventory
  final List<IngredientType> inventory = [];

  // Callbacks
  VoidCallback? onGameOver;
  VoidCallback? onLevelComplete;
  VoidCallback? onScoreChanged;
  VoidCallback? onInventoryChanged;

  // Delivery state
  bool isDelivering = false;
  double _deliverySpeedMultiplier =
      1.0; // Smooth transition: 1.0 = full speed, 0.0 = stopped

  // Game components
  late Road road;
  late Truck truck;
  late SpawnManager spawnManager;

  FoodTruckGame({this.currentLevel, this.isEndlessMode = false});

  @override
  Color backgroundColor() => GameColors.background;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Set camera anchor to top-left for consistent positioning
    camera.viewfinder.anchor = Anchor.topLeft;

    // Load game assets
    await _loadAssets();

    // Initialize game components
    _initializeGame();
  }

  Future<void> _loadAssets() async {
    // Preload all images
    await images.loadAll([
      'truck.png',
      'tomato.png',
      'cheese.png',
      'lettuce.png',
      'burger.png',
      'cooked-burger.png',
      'traffic-cone.png',
      'pothole.png',
      'wooden-construction-barrier.png',
      'city-building.png',
      'customers/customer1.png',
      'customers/customer2.png',
      'customers/customer3.png',
    ]);
  }

  void _initializeGame() {
    // Reset game state
    score = 0;
    deliveries = 0;
    distanceTraveled = 0;
    comboCount = 0;
    comboMultiplier = 1.0;
    inventory.clear();
    gameState = GameState.playing;
    isDelivering = false;
    _deliverySpeedMultiplier = 1.0;
    _lastDistanceScorePoint = 0;
    _endlessSpeedBonus = 0;
    lives = isEndlessMode ? GameConstants.endlessStartingLives : 0;

    // Clear any existing components
    world.removeAll(world.children);

    // Initialize spawn manager
    spawnManager = SpawnManager(
      levelConfig: currentLevel,
      isEndlessMode: isEndlessMode,
    );

    // Add road first (background layer)
    road = Road();
    world.add(road);

    // Add truck (player layer)
    truck = Truck();
    world.add(truck);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (gameState != GameState.playing) return;

    // Smoothly transition speed multiplier for delivery pause/resume
    final targetMultiplier = isDelivering ? 0.0 : 1.0;
    const transitionSpeed = 8.0; // How fast to transition (higher = faster)

    if (_deliverySpeedMultiplier != targetMultiplier) {
      if (_deliverySpeedMultiplier < targetMultiplier) {
        _deliverySpeedMultiplier =
            (_deliverySpeedMultiplier + transitionSpeed * dt).clamp(0.0, 1.0);
      } else {
        _deliverySpeedMultiplier =
            (_deliverySpeedMultiplier - transitionSpeed * dt).clamp(0.0, 1.0);
      }
    }

    // Skip updates if fully stopped
    if (_deliverySpeedMultiplier < 0.01) return;

    // Get effective scroll speed (affected by truck penalty and endless mode bonus)
    final baseSpeed =
        currentLevel?.scrollSpeed ?? GameConstants.baseScrollSpeed;
    final speedWithBonus = isEndlessMode
        ? (baseSpeed + _endlessSpeedBonus).clamp(
            0,
            GameConstants.endlessMaxSpeed,
          )
        : baseSpeed;
    final effectiveSpeed = speedWithBonus * truck.speedMultiplier;

    // Update distance traveled
    distanceTraveled += effectiveSpeed * dt;

    // Award distance-based points
    _updateDistanceScore();

    // Update endless mode difficulty
    if (isEndlessMode) {
      _updateEndlessDifficulty();
    }

    // Update spawn manager with current difficulty
    spawnManager.update(
      dt,
      onSpawnIngredient: _spawnIngredient,
      onSpawnObstacle: _spawnObstacle,
      onSpawnCustomer: _spawnCustomer,
      endlessDistanceTraveled: isEndlessMode ? distanceTraveled : null,
    );

    // Check level completion (for non-endless mode)
    if (!isEndlessMode && currentLevel != null) {
      if (distanceTraveled >= currentLevel!.distance) {
        _checkLevelCompletion();
      }
    }
  }

  void _updateDistanceScore() {
    // Award points every distancePointsInterval distance units
    while (distanceTraveled >=
        _lastDistanceScorePoint + GameConstants.distancePointsInterval) {
      _lastDistanceScorePoint += GameConstants.distancePointsInterval;
      score += GameConstants.distancePoints;
      onScoreChanged?.call();
    }
  }

  void _updateEndlessDifficulty() {
    // Increase speed every endlessDifficultyIncreaseInterval distance units
    final speedIncreases =
        (distanceTraveled / GameConstants.endlessDifficultyIncreaseInterval)
            .floor();
    _endlessSpeedBonus = speedIncreases * GameConstants.endlessSpeedIncrease;
  }

  /// Get current scroll speed (for display purposes)
  double get currentScrollSpeed {
    final baseSpeed =
        currentLevel?.scrollSpeed ?? GameConstants.baseScrollSpeed;
    final speed = isEndlessMode
        ? (baseSpeed + _endlessSpeedBonus).clamp(
            0.0,
            GameConstants.endlessMaxSpeed,
          )
        : baseSpeed;

    // Apply smooth delivery transition multiplier
    return speed * _deliverySpeedMultiplier;
  }

  void _spawnIngredient(IngredientType type, int lane) {
    world.add(Ingredient(type: type, lane: lane));
  }

  void _spawnObstacle(ObstacleType type, int lane) {
    world.add(Obstacle(type: type, lane: lane));
  }

  void _spawnCustomer(List<IngredientType> order, bool isLeftSide) {
    world.add(Customer(order: order, isOnLeftSide: isLeftSide));
  }

  void _checkLevelCompletion() {
    if (deliveries >= currentLevel!.deliveriesRequired) {
      gameState = GameState.levelComplete;
      onLevelComplete?.call();
    } else {
      gameState = GameState.levelFailed;
      onGameOver?.call();
    }
  }

  /// Add points to score
  void addScore(int points) {
    score += (points * comboMultiplier).round();
    onScoreChanged?.call();
  }

  /// Increment combo
  void incrementCombo() {
    final previousMultiplier = comboMultiplier;
    comboCount++;

    if (comboCount >= 10) {
      comboMultiplier = GameConstants.comboMultiplier3;
    } else if (comboCount >= 5) {
      comboMultiplier = GameConstants.comboMultiplier2;
    } else if (comboCount >= 3) {
      comboMultiplier = GameConstants.comboMultiplier1;
    }

    // Play combo sound and show popup when multiplier increases
    if (comboMultiplier > previousMultiplier) {
      AudioService().playCombo();

      // Show combo popup at truck position
      world.add(
        ComboPopup(
          multiplier: comboMultiplier,
          position: Vector2(size.x / 2, truck.position.y - 80),
        ),
      );
    }
  }

  /// Reset combo
  void resetCombo() {
    // Show COMBO LOST message if there was an active combo
    if (comboMultiplier > 1.0) {
      world.add(
        GameMessage(
          type: GameMessageType.comboLost,
          position: Vector2(size.x / 2, truck.position.y - 100),
        ),
      );
    }
    comboCount = 0;
    comboMultiplier = 1.0;
  }

  /// Lose a life in endless mode
  /// Returns true if game over (no lives remaining)
  bool loseLife() {
    if (!isEndlessMode) return false;

    lives--;
    onScoreChanged?.call(); // Trigger UI update

    if (lives <= 0) {
      gameState = GameState.levelFailed;
      onGameOver?.call();
      return true;
    }
    return false;
  }

  /// Add ingredient to inventory
  bool addIngredient(IngredientType ingredient) {
    if (inventory.length >= GameConstants.maxInventorySize) {
      return false;
    }
    inventory.add(ingredient);
    onInventoryChanged?.call();
    return true;
  }

  /// Check if player has at least one ingredient from the order
  /// Returns the list of ingredients that can be delivered (partial delivery supported)
  List<IngredientType> getDeliverableIngredients(
    List<IngredientType> requiredIngredients,
  ) {
    final tempInventory = List<IngredientType>.from(inventory);
    final deliverable = <IngredientType>[];

    for (final ingredient in requiredIngredients) {
      if (tempInventory.contains(ingredient)) {
        deliverable.add(ingredient);
        tempInventory.remove(ingredient);
      }
    }
    return deliverable;
  }

  /// Check if player can deliver at least one item from the order
  bool canDeliverOrder(List<IngredientType> requiredIngredients) {
    return getDeliverableIngredients(requiredIngredients).isNotEmpty;
  }

  /// Check if player has ALL ingredients (for perfect delivery bonus)
  bool canDeliverFullOrder(List<IngredientType> requiredIngredients) {
    final tempInventory = List<IngredientType>.from(inventory);
    for (final ingredient in requiredIngredients) {
      if (!tempInventory.contains(ingredient)) {
        return false;
      }
      tempInventory.remove(ingredient);
    }
    return true;
  }

  /// Start delivery sequence (pause and animate)
  void startDeliverySequence(Customer customer) {
    isDelivering = true;

    // Get the ingredients we can actually deliver (partial delivery support)
    final deliverableIngredients = getDeliverableIngredients(customer.order);
    final isFullDelivery =
        deliverableIngredients.length == customer.order.length;

    // Play sound to indicate delivery started
    // AudioService().playInteract(); // Optional: sound for delivery start

    // Create flying ingredient animations
    _animateIngredientsToCustomer(
      customer,
      deliverableIngredients,
      isFullDelivery,
    );
  }

  void _animateIngredientsToCustomer(
    Customer customer,
    List<IngredientType> deliverableIngredients,
    bool isFullDelivery,
  ) {
    // Calculate start position (truck) and end position (customer)
    final startPos = truck.position.clone();
    final endPos = customer.position.clone();

    // Animate only the deliverable ingredients
    double delay = 0;
    for (final ingredient in deliverableIngredients) {
      // Create flying ingredient
      final flyingIngredient = FlyingIngredient(
        type: ingredient,
        startPosition: startPos,
        endPosition: endPos,
        delay: delay,
      );

      world.add(flyingIngredient);
      delay += 0.2; // Stagger animations
    }

    // Total duration = last item delay + flight time + small buffer
    final totalDuration = delay + 0.5 + 0.2;

    // Resume game after animation
    Future.delayed(Duration(milliseconds: (totalDuration * 1000).round()), () {
      if (gameState == GameState.playing) {
        isDelivering = false;
        customer.completeDelivery(deliverableIngredients, isFullDelivery);
      }
    });
  }

  /// Complete delivery logic (remove items, score)
  /// [deliveredIngredients] - the items actually being delivered
  /// [isFullDelivery] - true if all ordered items were delivered
  void completeDelivery(
    List<IngredientType> deliveredIngredients, {
    bool isFullDelivery = true,
  }) {
    // Remove used ingredients from inventory
    final tempInventory = List<IngredientType>.from(inventory);
    for (final ingredient in deliveredIngredients) {
      tempInventory.remove(ingredient);
    }
    inventory.clear();
    inventory.addAll(tempInventory);

    onInventoryChanged?.call();

    deliveries++;

    // Score based on items delivered
    // Base points per item delivered
    final basePoints =
        deliveredIngredients.length * GameConstants.deliveryPointsPerItem;

    // Bonus for full delivery
    final totalPoints = isFullDelivery
        ? basePoints + GameConstants.fullDeliveryBonus
        : basePoints;

    addScore(totalPoints);

    // Only increment combo for full deliveries
    if (isFullDelivery) {
      incrementCombo();
    }
  }

  /// Try to deliver order (OLD METHOD - kept for compatibility if needed, but unused now)
  bool tryDeliverOrder(List<IngredientType> requiredIngredients) {
    if (!canDeliverOrder(requiredIngredients)) return false;
    completeDelivery(requiredIngredients);
    return true;
  }

  /// Pause the game
  void pauseGame() {
    gameState = GameState.paused;
    pauseEngine();
  }

  /// Resume the game
  void resumeGame() {
    gameState = GameState.playing;
    resumeEngine();
  }

  /// Calculate star rating for current performance
  int calculateStars() {
    if (currentLevel == null) return 0;
    return currentLevel!.calculateStars(score, deliveries);
  }

  /// Get progress as percentage (0.0 - 1.0) for level mode
  double get levelProgress {
    if (currentLevel == null) return 0;
    return (distanceTraveled / currentLevel!.distance).clamp(0.0, 1.0);
  }

  @override
  void onHorizontalDragEnd(DragEndInfo info) {
    if (gameState != GameState.playing) return;

    // Detect swipe direction for lane changes
    final velocity = info.velocity.x;
    if (velocity > 100) {
      // Swipe right
      _switchLane(1);
    } else if (velocity < -100) {
      // Swipe left
      _switchLane(-1);
    }
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (gameState != GameState.playing) return KeyEventResult.ignored;

    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _switchLane(-1);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _switchLane(1);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void _switchLane(int direction) {
    truck.switchLane(direction);
    AudioService().playSwoosh();
    VibrationService().selectionClick();
  }
}
