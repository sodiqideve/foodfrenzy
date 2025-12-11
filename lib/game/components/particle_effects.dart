import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

/// Sparkle particle effect for ingredient collection
class CollectionParticleEffect extends ParticleSystemComponent {
  CollectionParticleEffect({
    required Vector2 position,
    Color color = const Color(0xFFFFD700), // Gold by default
  }) : super(
          particle: _createSparkleParticle(color),
          position: position,
        );

  static Particle _createSparkleParticle(Color color) {
    final random = Random();
    
    return Particle.generate(
      count: 12,
      lifespan: 0.6,
      generator: (i) {
        // Random angle for particle direction
        final angle = (i / 12) * 2 * pi + random.nextDouble() * 0.5;
        final speed = 80 + random.nextDouble() * 60;
        final velocity = Vector2(cos(angle) * speed, sin(angle) * speed);
        
        return AcceleratedParticle(
          acceleration: Vector2(0, 150), // Gravity
          speed: velocity,
          child: ComputedParticle(
            renderer: (canvas, particle) {
              final opacity = (1 - particle.progress).clamp(0.0, 1.0);
              final size = (1 - particle.progress * 0.5) * 6;
              
              final paint = Paint()
                ..color = color.withValues(alpha: opacity)
                ..style = PaintingStyle.fill;
              
              // Draw a star shape
              canvas.drawCircle(Offset.zero, size, paint);
              
              // Add a glow effect
              paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
              canvas.drawCircle(Offset.zero, size * 0.8, paint);
            },
          ),
        );
      },
    );
  }
}

/// Coin/star particle effect for successful delivery
class DeliveryParticleEffect extends ParticleSystemComponent {
  DeliveryParticleEffect({
    required Vector2 position,
  }) : super(
          particle: _createDeliveryParticle(),
          position: position,
        );

  static Particle _createDeliveryParticle() {
    final random = Random();
    
    return Particle.generate(
      count: 8,
      lifespan: 1.0,
      generator: (i) {
        // Particles rise up and spread out
        final angle = -pi / 2 + (random.nextDouble() - 0.5) * pi * 0.6;
        final speed = 100 + random.nextDouble() * 50;
        final velocity = Vector2(cos(angle) * speed, sin(angle) * speed);
        
        // Alternate between gold (coins) and yellow (stars)
        final isGold = i % 2 == 0;
        final color = isGold ? const Color(0xFFFFD700) : const Color(0xFFFFEB3B);
        
        return AcceleratedParticle(
          acceleration: Vector2(0, 200), // Gravity pulls down
          speed: velocity,
          child: ComputedParticle(
            renderer: (canvas, particle) {
              final opacity = (1 - particle.progress * 0.7).clamp(0.0, 1.0);
              final scale = 1 - particle.progress * 0.3;
              
              final paint = Paint()
                ..color = color.withValues(alpha: opacity)
                ..style = PaintingStyle.fill;
              
              if (isGold) {
                // Draw a coin (circle)
                canvas.drawCircle(Offset.zero, 8 * scale, paint);
                // Inner detail
                paint.color = const Color(0xFFFFA000).withValues(alpha: opacity * 0.7);
                canvas.drawCircle(Offset.zero, 5 * scale, paint);
              } else {
                // Draw a simple star
                _drawStar(canvas, 10 * scale, paint);
              }
            },
          ),
        );
      },
    );
  }

  static void _drawStar(Canvas canvas, double size, Paint paint) {
    final path = Path();
    const points = 5;
    final outerRadius = size;
    final innerRadius = size * 0.4;
    
    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = (i * pi / points) - pi / 2;
      final x = cos(angle) * radius;
      final y = sin(angle) * radius;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }
}

/// Plus score text that floats up and fades
class ScorePopup extends TextComponent {
  final int points;
  double _elapsed = 0;
  static const double _duration = 0.8;

  ScorePopup({
    required this.points,
    required Vector2 position,
  }) : super(
          text: '+$points',
          position: position,
          anchor: Anchor.center,
          textRenderer: TextPaint(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black54,
                  blurRadius: 4,
                  offset: Offset(1, 1),
                ),
              ],
            ),
          ),
        );

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    
    // Move up
    position.y -= 60 * dt;
    
    // Fade out
    final progress = _elapsed / _duration;
    final opacity = (1 - progress).clamp(0.0, 1.0);
    textRenderer = TextPaint(
      style: TextStyle(
        color: Colors.white.withValues(alpha: opacity),
        fontSize: 24 + progress * 8, // Grow slightly
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            color: Colors.black54.withValues(alpha: opacity),
            blurRadius: 4,
            offset: const Offset(1, 1),
          ),
        ],
      ),
    );
    
    if (_elapsed >= _duration) {
      removeFromParent();
    }
  }
}

/// Combo text popup
class ComboPopup extends TextComponent {
  final double multiplier;
  double _elapsed = 0;
  static const double _duration = 1.0;

  ComboPopup({
    required this.multiplier,
    required Vector2 position,
  }) : super(
          text: 'x${multiplier.toStringAsFixed(1)} COMBO!',
          position: position,
          anchor: Anchor.center,
          textRenderer: TextPaint(
            style: const TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 28,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black87,
                  blurRadius: 6,
                  offset: Offset(2, 2),
                ),
              ],
            ),
          ),
        );

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    
    final progress = _elapsed / _duration;
    
    // Scale up then down
    final scale = progress < 0.2 
        ? 0.5 + progress * 2.5 
        : 1.0 - (progress - 0.2) * 0.3;
    
    // Move up slowly
    position.y -= 30 * dt;
    
    // Fade out in last half
    final opacity = progress > 0.5 ? (1 - (progress - 0.5) * 2).clamp(0.0, 1.0) : 1.0;
    
    textRenderer = TextPaint(
      style: TextStyle(
        color: const Color(0xFFFFD700).withValues(alpha: opacity),
        fontSize: 28 * scale,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            color: Colors.black87.withValues(alpha: opacity),
            blurRadius: 6,
            offset: const Offset(2, 2),
          ),
        ],
      ),
    );
    
    if (_elapsed >= _duration) {
      removeFromParent();
    }
  }
}

