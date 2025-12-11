import 'package:flutter/material.dart';

import '../services/audio_service.dart';
import '../utils/constants.dart';

class MainMenuScreen extends StatefulWidget {
  final VoidCallback onPlay;
  final VoidCallback onSettings;
  final VoidCallback onTutorial;

  const MainMenuScreen({
    super.key,
    required this.onPlay,
    required this.onSettings,
    required this.onTutorial,
  });

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [GameColors.background, GameColors.surface],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                // Game Logo with animation
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildLogo(),
                ),
                const Spacer(flex: 2),
                // Menu buttons with staggered animation
                _buildAnimatedButton(
                  context,
                  'PLAY',
                  GameColors.primary,
                  Icons.play_arrow_rounded,
                  widget.onPlay,
                  0,
                ),
                const SizedBox(height: 12),
                _buildAnimatedButton(
                  context,
                  'HOW TO PLAY',
                  GameColors.secondary,
                  Icons.help_outline_rounded,
                  widget.onTutorial,
                  1,
                ),
                const SizedBox(height: 12),
                _buildAnimatedButton(
                  context,
                  'SETTINGS',
                  GameColors.surfaceLight,
                  Icons.settings_rounded,
                  widget.onSettings,
                  2,
                ),
                const Spacer(flex: 2),
                // Version info
                Text(
                  'v1.0.0',
                  style: TextStyle(
                    color: GameColors.textSecondary.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedButton(
    BuildContext context,
    String text,
    Color color,
    IconData icon,
    VoidCallback onPressed,
    int index,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: _buildMenuButton(context, text, color, icon, onPressed),
          ),
        );
      },
    );
  }

  Widget _buildLogo() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 280, maxHeight: 280),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: GameColors.primary.withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/images/foodfenzylogo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String text,
    Color color,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
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
          elevation: 8,
          shadowColor: color.withValues(alpha: 0.5),
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
