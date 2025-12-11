import 'package:flutter/material.dart';

import '../services/audio_service.dart';
import '../utils/constants.dart';

class PauseScreen extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onQuit;

  const PauseScreen({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onQuit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: GameColors.background.withValues(alpha: 0.9),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pause icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: GameColors.surfaceLight,
                    border: Border.all(
                      color: GameColors.primary,
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.pause_rounded,
                    size: 60,
                    color: GameColors.primary,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'PAUSED',
                  style: TextStyle(
                    color: GameColors.textPrimary,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 48),
                // Resume button
                _buildPauseButton(
                  'RESUME',
                  Icons.play_arrow_rounded,
                  GameColors.primary,
                  onResume,
                ),
                const SizedBox(height: 16),
                // Restart button
                _buildPauseButton(
                  'RESTART',
                  Icons.refresh_rounded,
                  GameColors.secondary,
                  onRestart,
                ),
                const SizedBox(height: 16),
                // Quit button
                _buildPauseButton(
                  'QUIT',
                  Icons.exit_to_app_rounded,
                  GameColors.surfaceLight,
                  onQuit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPauseButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: 250,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          AudioService().playClick();
          onPressed();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

