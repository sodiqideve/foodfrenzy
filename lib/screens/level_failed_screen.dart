import 'package:flutter/material.dart';

import '../services/audio_service.dart';
import '../utils/constants.dart';

class LevelFailedScreen extends StatefulWidget {
  final int levelNumber;
  final int score;
  final int deliveries;
  final int deliveriesRequired;
  final VoidCallback onRetry;
  final VoidCallback onQuit;

  const LevelFailedScreen({
    super.key,
    required this.levelNumber,
    required this.score,
    required this.deliveries,
    required this.deliveriesRequired,
    required this.onRetry,
    required this.onQuit,
  });

  @override
  State<LevelFailedScreen> createState() => _LevelFailedScreenState();
}

class _LevelFailedScreenState extends State<LevelFailedScreen> {
  @override
  void initState() {
    super.initState();
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
              // Failure banner
              _buildFailureBanner(),
              const SizedBox(height: 32),
              // Stats
              _buildStats(),
              const SizedBox(height: 24),
              // Requirement hint
              _buildRequirementHint(),
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

  Widget _buildFailureBanner() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: GameColors.error.withValues(alpha: 0.2),
            border: Border.all(color: GameColors.error, width: 3),
          ),
          child: const Icon(
            Icons.close_rounded,
            size: 50,
            color: GameColors.error,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'LEVEL FAILED',
          style: TextStyle(
            color: GameColors.error,
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
          _buildStatItem('SCORE', widget.score.toString(), GameColors.textSecondary),
          Container(
            width: 1,
            height: 40,
            color: GameColors.textSecondary.withValues(alpha: 0.3),
          ),
          _buildStatItem(
            'DELIVERIES',
            '${widget.deliveries}/${widget.deliveriesRequired}',
            widget.deliveries >= widget.deliveriesRequired
                ? GameColors.success
                : GameColors.error,
          ),
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

  Widget _buildRequirementHint() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GameColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GameColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb_outline_rounded,
            color: GameColors.warning,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'You need ${widget.deliveriesRequired} deliveries to complete this level. Collect ingredients and deliver them to customers!',
              style: TextStyle(
                color: GameColors.textSecondary.withValues(alpha: 0.9),
                fontSize: 14,
              ),
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
              backgroundColor: GameColors.primary,
              foregroundColor: Colors.white,
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
                  'TRY AGAIN',
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

