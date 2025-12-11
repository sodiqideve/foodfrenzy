import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../game/config/level_config.dart';
import '../game/food_truck_game.dart';
import '../services/audio_service.dart';
import '../services/save_service.dart';
import '../utils/constants.dart';
import 'endless_game_over_screen.dart';
import 'level_complete_screen.dart';
import 'level_failed_screen.dart';
import 'pause_screen.dart';

class GameScreen extends StatefulWidget {
  final int? levelNumber;
  final bool isEndlessMode;
  final VoidCallback onQuit;
  final void Function(int level)? onNextLevel;

  const GameScreen({
    super.key,
    this.levelNumber,
    this.isEndlessMode = false,
    required this.onQuit,
    this.onNextLevel,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  late FoodTruckGame _game;
  bool _isPaused = false;
  bool _isLevelComplete = false;
  bool _isLevelFailed = false;
  bool _isEndlessGameOver = false;
  
  final AudioService _audioService = AudioService();
  final SaveService _saveService = SaveService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Lock to portrait mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    
    // Hide system UI for immersive gameplay
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    
    _initGame();
    _audioService.playBackgroundMusic();
  }

  void _initGame() {
    final levelConfig = widget.levelNumber != null
        ? LevelConfigs.getLevel(widget.levelNumber!)
        : null;

    _game = FoodTruckGame(
      currentLevel: levelConfig,
      isEndlessMode: widget.isEndlessMode,
    );

    _game.onLevelComplete = _handleLevelComplete;
    _game.onGameOver = _handleGameOver;
    _game.onScoreChanged = _onGameStateChanged;
    _game.onInventoryChanged = _onGameStateChanged;
  }

  void _onGameStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pauseGame();
      _audioService.pauseBackgroundMusic();
    } else if (state == AppLifecycleState.resumed) {
      _audioService.resumeBackgroundMusic();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    _audioService.stopBackgroundMusic();
    super.dispose();
  }

  void _pauseGame() {
    if (!_isPaused && !_isLevelComplete && !_isLevelFailed) {
      setState(() => _isPaused = true);
      _game.pauseGame();
      _audioService.pauseBackgroundMusic();
    }
  }

  void _resumeGame() {
    setState(() => _isPaused = false);
    _game.resumeGame();
    _audioService.resumeBackgroundMusic();
  }

  void _restartGame() {
    setState(() {
      _isPaused = false;
      _isLevelComplete = false;
      _isLevelFailed = false;
      _isEndlessGameOver = false;
    });
    _initGame();
    _audioService.playBackgroundMusic();
  }

  void _handleLevelComplete() {
    setState(() => _isLevelComplete = true);
    _audioService.stopBackgroundMusic();
    
    // Save progress
    if (widget.levelNumber != null) {
      final stars = _game.calculateStars();
      _saveService.setLevelStars(widget.levelNumber!, stars);
      _saveService.setLevelHighScore(widget.levelNumber!, _game.score);
      
      // Unlock next level
      if (widget.levelNumber! < LevelConfigs.totalLevels) {
        _saveService.unlockLevel(widget.levelNumber! + 1);
      }
    }
  }

  void _handleGameOver() {
    _audioService.stopBackgroundMusic();
    
    if (widget.isEndlessMode) {
      // Save endless mode score and show endless game over
      _saveService.setEndlessBestScore(_game.score);
      setState(() => _isEndlessGameOver = true);
    } else {
      // Show level failed screen
      setState(() => _isLevelFailed = true);
    }
  }

  void _goToNextLevel() {
    if (widget.levelNumber != null && widget.levelNumber! < LevelConfigs.totalLevels) {
      widget.onNextLevel?.call(widget.levelNumber! + 1);
    } else {
      widget.onQuit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Game
          GameWidget(
            game: _game,
            loadingBuilder: (context) => Container(
              color: GameColors.background,
              child: const Center(
                child: CircularProgressIndicator(
                  color: GameColors.primary,
                ),
              ),
            ),
          ),
          
          // Top HUD (score, pause, level)
          _buildTopHUD(),
          
          // Bottom HUD (inventory, deliveries, progress)
          _buildBottomHUD(),
          
          // Pause overlay
          if (_isPaused)
            PauseScreen(
              onResume: _resumeGame,
              onRestart: _restartGame,
              onQuit: widget.onQuit,
            ),
          
          // Level complete overlay
          if (_isLevelComplete && widget.levelNumber != null)
            LevelCompleteScreen(
              levelNumber: widget.levelNumber!,
              score: _game.score,
              stars: _game.calculateStars(),
              deliveries: _game.deliveries,
              isNewHighScore: _game.score > _saveService.getLevelHighScore(widget.levelNumber!),
              onNextLevel: _goToNextLevel,
              onReplay: _restartGame,
              onQuit: widget.onQuit,
            ),
          
          // Level failed overlay
          if (_isLevelFailed && widget.levelNumber != null)
            LevelFailedScreen(
              levelNumber: widget.levelNumber!,
              score: _game.score,
              deliveries: _game.deliveries,
              deliveriesRequired: _game.currentLevel?.deliveriesRequired ?? 0,
              onRetry: _restartGame,
              onQuit: widget.onQuit,
            ),
          
          // Endless mode game over overlay
          if (_isEndlessGameOver && widget.isEndlessMode)
            EndlessGameOverScreen(
              score: _game.score,
              deliveries: _game.deliveries,
              distanceTraveled: _game.distanceTraveled,
              onRetry: _restartGame,
              onQuit: widget.onQuit,
            ),
        ],
      ),
    );
  }

  Widget _buildTopHUD() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Pause button
                  _buildHUDButton(
                    Icons.pause_rounded,
                    _pauseGame,
                  ),
                  // Level or Mode indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: GameColors.primary.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      widget.isEndlessMode 
                          ? 'ENDLESS' 
                          : 'LEVEL ${widget.levelNumber ?? 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  // Deliveries counter or Lives (endless mode)
                  if (widget.isEndlessMode)
                    _buildLivesDisplay()
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: GameColors.surfaceLight.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.local_shipping_rounded,
                            color: GameColors.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${_game.deliveries}/${_game.currentLevel?.deliveriesRequired ?? 0}',
                            style: const TextStyle(
                              color: GameColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Score display with combo - centered below
              _buildScoreDisplay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: GameColors.surfaceLight.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            color: GameColors.accent,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            '${_game.score}',
            style: const TextStyle(
              color: GameColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_game.comboMultiplier > 1.0) ...[
            const SizedBox(width: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [GameColors.accent, GameColors.starFilled],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: GameColors.accent.withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Text(
                'x${_game.comboMultiplier.toStringAsFixed(1)}',
                style: const TextStyle(
                  color: GameColors.background,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomHUD() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress bar (level mode only)
              if (!widget.isEndlessMode && widget.levelNumber != null)
                _buildProgressBar(),
              const SizedBox(height: 8),
              // Inventory display
              _buildInventoryDisplay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = _game.levelProgress;
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: GameColors.surfaceLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [GameColors.primary, GameColors.accent],
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildInventoryDisplay() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: GameColors.surfaceLight.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.inventory_2_rounded,
            color: GameColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 8),
          // Show inventory items
          if (_game.inventory.isEmpty)
            Text(
              'Empty',
              style: TextStyle(
                color: GameColors.textSecondary.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            )
          else
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _game.inventory.take(GameConstants.maxInventorySize).map((ingredient) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: _buildIngredientIcon(ingredient),
                  );
                }).toList(),
              ),
            ),
          // Inventory count
          const SizedBox(width: 8),
          Text(
            '${_game.inventory.length}/${GameConstants.maxInventorySize}',
            style: const TextStyle(
              color: GameColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientIcon(IngredientType type) {
    final color = switch (type) {
      IngredientType.tomato => const Color(0xFFE53935),
      IngredientType.cheese => const Color(0xFFFFCA28),
      IngredientType.lettuce => const Color(0xFF4CAF50),
      IngredientType.patty => const Color(0xFF795548),
      IngredientType.bun => const Color(0xFFFFB74D),
    };
    
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildLivesDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: GameColors.surfaceLight.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(GameConstants.endlessStartingLives, (index) {
          final hasLife = index < _game.lives;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              hasLife ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: hasLife ? GameColors.error : GameColors.textSecondary,
              size: 20,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHUDButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: () {
        _audioService.playClick();
        onPressed();
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: GameColors.surfaceLight.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: GameColors.textPrimary,
          size: 24,
        ),
      ),
    );
  }
}
