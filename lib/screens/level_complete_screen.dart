import 'package:flutter/material.dart';

import '../services/audio_service.dart';
import '../utils/constants.dart';

class LevelCompleteScreen extends StatefulWidget {
  final int levelNumber;
  final int score;
  final int stars;
  final int deliveries;
  final bool isNewHighScore;
  final VoidCallback onNextLevel;
  final VoidCallback onReplay;
  final VoidCallback onQuit;

  const LevelCompleteScreen({
    super.key,
    required this.levelNumber,
    required this.score,
    required this.stars,
    required this.deliveries,
    required this.isNewHighScore,
    required this.onNextLevel,
    required this.onReplay,
    required this.onQuit,
  });

  @override
  State<LevelCompleteScreen> createState() => _LevelCompleteScreenState();
}

class _LevelCompleteScreenState extends State<LevelCompleteScreen>
    with TickerProviderStateMixin {
  late List<AnimationController> _starControllers;
  late List<Animation<double>> _starAnimations;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    AudioService().playWin();
  }

  void _initAnimations() {
    _starControllers = List.generate(
      3,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );

    _starAnimations = _starControllers.map((controller) {
      return CurvedAnimation(
        parent: controller,
        curve: Curves.elasticOut,
      );
    }).toList();

    // Stagger star animations
    for (int i = 0; i < widget.stars; i++) {
      Future.delayed(Duration(milliseconds: 300 + (i * 200)), () {
        if (mounted) {
          _starControllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _starControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            GameColors.background,
            GameColors.surface,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Success banner
              _buildSuccessBanner(),
              const SizedBox(height: 32),
              // Stars
              _buildStars(),
              const SizedBox(height: 32),
              // Stats
              _buildStats(),
              if (widget.isNewHighScore) ...[
                const SizedBox(height: 16),
                _buildHighScoreBadge(),
              ],
              const Spacer(),
              // Buttons
              _buildButtons(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessBanner() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: GameColors.success.withValues(alpha: 0.2),
            border: Border.all(color: GameColors.success, width: 3),
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 50,
            color: GameColors.success,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'LEVEL COMPLETE!',
          style: TextStyle(
            color: GameColors.success,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Level ${widget.levelNumber}',
          style: TextStyle(
            color: GameColors.textSecondary.withValues(alpha: 0.7),
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _starAnimations[index],
          builder: (context, child) {
            return Transform.scale(
              scale: index < widget.stars ? _starAnimations[index].value : 1.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.star_rounded,
                  size: 56,
                  color: index < widget.stars
                      ? GameColors.starFilled
                      : GameColors.starEmpty,
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: GameColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('SCORE', widget.score.toString(), GameColors.accent),
          Container(
            width: 1,
            height: 40,
            color: GameColors.textSecondary.withValues(alpha: 0.3),
          ),
          _buildStatItem('DELIVERIES', widget.deliveries.toString(), GameColors.primary),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: GameColors.textSecondary.withValues(alpha: 0.7),
            fontSize: 12,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildHighScoreBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: GameColors.accent.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: GameColors.accent, width: 2),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events_rounded, color: GameColors.accent, size: 20),
          SizedBox(width: 8),
          Text(
            'NEW HIGH SCORE!',
            style: TextStyle(
              color: GameColors.accent,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              AudioService().playClick();
              widget.onNextLevel();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: GameColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'NEXT LEVEL',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    AudioService().playClick();
                    widget.onReplay();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: GameColors.textPrimary,
                    side: const BorderSide(color: GameColors.textSecondary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh_rounded, size: 20),
                      SizedBox(width: 8),
                      Text('REPLAY'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    AudioService().playClick();
                    widget.onQuit();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: GameColors.textPrimary,
                    side: const BorderSide(color: GameColors.textSecondary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.home_rounded, size: 20),
                      SizedBox(width: 8),
                      Text('MENU'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

