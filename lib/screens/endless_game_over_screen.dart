import 'package:flutter/material.dart';

import '../services/audio_service.dart';
import '../services/save_service.dart';
import '../utils/constants.dart';

class EndlessGameOverScreen extends StatefulWidget {
  final int score;
  final int deliveries;
  final double distanceTraveled;
  final VoidCallback onRetry;
  final VoidCallback onQuit;

  const EndlessGameOverScreen({
    super.key,
    required this.score,
    required this.deliveries,
    required this.distanceTraveled,
    required this.onRetry,
    required this.onQuit,
  });

  @override
  State<EndlessGameOverScreen> createState() => _EndlessGameOverScreenState();
}

class _EndlessGameOverScreenState extends State<EndlessGameOverScreen> {
  late int _bestScore;
  late bool _isNewBestScore;

  @override
  void initState() {
    super.initState();
    final saveService = SaveService();
    _bestScore = saveService.getEndlessBestScore();
    _isNewBestScore = widget.score > _bestScore;
    
    if (_isNewBestScore) {
      _bestScore = widget.score;
    }
    
    AudioService().playFail();
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
              // Game Over banner
              _buildGameOverBanner(),
              const SizedBox(height: 32),
              // Stats
              _buildStats(),
              const SizedBox(height: 16),
              // Best score indicator
              if (_isNewBestScore) _buildNewBestScoreBadge(),
              if (!_isNewBestScore) _buildBestScoreDisplay(),
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

  Widget _buildGameOverBanner() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: GameColors.accent.withValues(alpha: 0.2),
            border: Border.all(color: GameColors.accent, width: 3),
          ),
          child: const Icon(
            Icons.all_inclusive_rounded,
            size: 60,
            color: GameColors.accent,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'GAME OVER',
          style: TextStyle(
            color: GameColors.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Endless Mode',
          style: TextStyle(
            color: GameColors.accent,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: GameColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Main score display
          Text(
            '${widget.score}',
            style: const TextStyle(
              color: GameColors.accent,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'SCORE',
            style: TextStyle(
              color: GameColors.textSecondary,
              fontSize: 14,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),
          // Secondary stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                Icons.local_shipping_rounded,
                '${widget.deliveries}',
                'DELIVERIES',
                GameColors.primary,
              ),
              Container(
                width: 1,
                height: 40,
                color: GameColors.textSecondary.withValues(alpha: 0.3),
              ),
              _buildStatItem(
                Icons.straighten_rounded,
                '${(widget.distanceTraveled / 100).toStringAsFixed(1)}m',
                'DISTANCE',
                GameColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: GameColors.textSecondary.withValues(alpha: 0.7),
            fontSize: 10,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildNewBestScoreBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [GameColors.accent, GameColors.primary],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: GameColors.accent.withValues(alpha: 0.4),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events_rounded, color: Colors.white, size: 24),
          SizedBox(width: 10),
          Text(
            'NEW BEST SCORE!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBestScoreDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: GameColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.emoji_events_rounded,
            color: GameColors.starFilled,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Best: $_bestScore',
            style: const TextStyle(
              color: GameColors.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
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
              widget.onRetry();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: GameColors.accent,
              foregroundColor: GameColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh_rounded),
                SizedBox(width: 12),
                Text(
                  'PLAY AGAIN',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
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
                Text('BACK TO MENU'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

