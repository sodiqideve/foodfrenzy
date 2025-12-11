import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../utils/constants.dart';
import '../food_truck_game.dart';

/// Scrolling road background with 3 lanes and sidewalks
class Road extends PositionComponent with HasGameReference<FoodTruckGame> {
  // Lane positions (X coordinates) - calculated in onLoad
  late List<double> lanePositions;
  late double roadWidth;
  late double sidewalkWidth;
  late double laneWidth;
  
  // Scroll offset for animation
  double _scrollOffset = 0;
  
  // Lane marker dash settings
  static const double _dashLength = 40;
  static const double _dashGap = 30;
  static const double _dashWidth = 4;
  
  // Parallax buildings
  final List<_Building> _leftBuildings = [];
  final List<_Building> _rightBuildings = [];
  static const double _parallaxFactor = 0.7; // Buildings move slower than road
  final Random _random = Random();
  
  @override
  Future<void> onLoad() async {
    // Set size to full game size
    size = game.size;
    position = Vector2.zero();
    
    // Calculate dimensions based on screen width
    final screenWidth = game.size.x;
    sidewalkWidth = screenWidth * 0.12; // 12% each side
    roadWidth = screenWidth - (sidewalkWidth * 2);
    laneWidth = roadWidth / GameConstants.laneCount;
    
    // Calculate lane center positions (X coordinates)
    lanePositions = List.generate(GameConstants.laneCount, (index) {
      return sidewalkWidth + (laneWidth * index) + (laneWidth / 2);
    });
    
    // Initialize parallax buildings
    _initializeBuildings();
  }
  
  void _initializeBuildings() {
    final screenHeight = game.size.y;
    
    // Create initial buildings on both sides
    double leftY = 0;
    double rightY = 0;
    
    while (leftY < screenHeight + 200) {
      final building = _createRandomBuilding(true);
      building.y = leftY;
      _leftBuildings.add(building);
      leftY += building.height + 10 + _random.nextDouble() * 20;
    }
    
    while (rightY < screenHeight + 200) {
      final building = _createRandomBuilding(false);
      building.y = rightY;
      _rightBuildings.add(building);
      rightY += building.height + 10 + _random.nextDouble() * 20;
    }
  }
  
  _Building _createRandomBuilding(bool isLeft) {
    final buildingWidth = sidewalkWidth * 0.8;
    final buildingHeight = 60.0 + _random.nextDouble() * 80;
    
    // Building colors - various shades
    final colors = [
      const Color(0xFF455A64), // Blue grey
      const Color(0xFF546E7A), // Blue grey light
      const Color(0xFF37474F), // Blue grey dark
      const Color(0xFF5D4037), // Brown
      const Color(0xFF6D4C41), // Brown light
      const Color(0xFF4E342E), // Brown dark
      const Color(0xFF424242), // Grey
      const Color(0xFF616161), // Grey light
    ];
    
    return _Building(
      width: buildingWidth,
      height: buildingHeight,
      color: colors[_random.nextInt(colors.length)],
      windowRows: (buildingHeight / 25).floor(),
      windowCols: 2,
      x: isLeft 
          ? sidewalkWidth * 0.1
          : game.size.x - sidewalkWidth * 0.9,
      y: 0, // Will be set by caller
    );
  }
  
  /// Get X position for a given lane index (0, 1, 2)
  double getLaneX(int laneIndex) {
    if (laneIndex < 0 || laneIndex >= lanePositions.length) {
      return lanePositions[1]; // Default to center lane
    }
    return lanePositions[laneIndex];
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Update scroll offset based on current game speed
    final speed = game.currentScrollSpeed;
    _scrollOffset += speed * dt;
    
    // Reset offset when it exceeds dash pattern length to prevent overflow
    if (_scrollOffset >= _dashLength + _dashGap) {
      _scrollOffset = _scrollOffset % (_dashLength + _dashGap);
    }
    
    // Update parallax buildings (move slower than road)
    _updateBuildings(dt, speed * _parallaxFactor);
  }
  
  void _updateBuildings(double dt, double speed) {
    final screenHeight = game.size.y;
    
    // Update left buildings
    for (final building in _leftBuildings) {
      building.y += speed * dt;
    }
    
    // Update right buildings
    for (final building in _rightBuildings) {
      building.y += speed * dt;
    }
    
    // Remove buildings that are off screen and add new ones at top
    _leftBuildings.removeWhere((b) => b.y > screenHeight + b.height);
    _rightBuildings.removeWhere((b) => b.y > screenHeight + b.height);
    
    // Add new buildings at top if needed
    if (_leftBuildings.isEmpty || _leftBuildings.first.y > 0) {
      final newBuilding = _createRandomBuilding(true);
      final topY = _leftBuildings.isEmpty ? -newBuilding.height : _leftBuildings.first.y;
      newBuilding.y = topY - newBuilding.height - 10 - _random.nextDouble() * 20;
      _leftBuildings.insert(0, newBuilding);
    }
    
    if (_rightBuildings.isEmpty || _rightBuildings.first.y > 0) {
      final newBuilding = _createRandomBuilding(false);
      final topY = _rightBuildings.isEmpty ? -newBuilding.height : _rightBuildings.first.y;
      newBuilding.y = topY - newBuilding.height - 10 - _random.nextDouble() * 20;
      _rightBuildings.insert(0, newBuilding);
    }
  }
  
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final screenHeight = size.y;
    final screenWidth = size.x;
    
    // Draw left sidewalk
    canvas.drawRect(
      Rect.fromLTWH(0, 0, sidewalkWidth, screenHeight),
      Paint()..color = GameColors.sidewalk,
    );
    
    // Draw right sidewalk
    canvas.drawRect(
      Rect.fromLTWH(screenWidth - sidewalkWidth, 0, sidewalkWidth, screenHeight),
      Paint()..color = GameColors.sidewalk,
    );
    
    // Draw parallax buildings on sidewalks
    _drawBuildings(canvas, _leftBuildings);
    _drawBuildings(canvas, _rightBuildings);
    
    // Draw road background
    canvas.drawRect(
      Rect.fromLTWH(sidewalkWidth, 0, roadWidth, screenHeight),
      Paint()..color = GameColors.roadDark,
    );
    
    // Draw lane dividers (dashed lines between lanes)
    _drawLaneMarkers(canvas, screenHeight);
    
    // Draw road edges (solid white lines)
    _drawRoadEdges(canvas, screenHeight, screenWidth);
  }
  
  void _drawBuildings(Canvas canvas, List<_Building> buildings) {
    for (final building in buildings) {
      // Draw building body
      final buildingRect = Rect.fromLTWH(
        building.x,
        building.y,
        building.width,
        building.height,
      );
      canvas.drawRect(buildingRect, Paint()..color = building.color);
      
      // Draw building outline
      canvas.drawRect(
        buildingRect,
        Paint()
          ..color = building.color.withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      
      // Draw windows
      final windowWidth = building.width * 0.25;
      final windowHeight = 12.0;
      final windowPaint = Paint()..color = const Color(0xFF1A237E).withValues(alpha: 0.6);
      final litWindowPaint = Paint()..color = const Color(0xFFFFEB3B).withValues(alpha: 0.8);
      
      for (int row = 0; row < building.windowRows; row++) {
        for (int col = 0; col < building.windowCols; col++) {
          final windowX = building.x + 8 + col * (windowWidth + 6);
          final windowY = building.y + 10 + row * 22;
          
          // Randomly light some windows
          final isLit = (building.hashCode + row * 10 + col) % 3 == 0;
          
          canvas.drawRect(
            Rect.fromLTWH(windowX, windowY, windowWidth, windowHeight),
            isLit ? litWindowPaint : windowPaint,
          );
        }
      }
      
      // Draw roof detail
      canvas.drawRect(
        Rect.fromLTWH(building.x, building.y, building.width, 4),
        Paint()..color = building.color.withValues(alpha: 0.7),
      );
    }
  }
  
  void _drawLaneMarkers(Canvas canvas, double screenHeight) {
    final paint = Paint()
      ..color = GameColors.laneMarker
      ..strokeWidth = _dashWidth
      ..style = PaintingStyle.stroke;
    
    // Draw dashed lines between each lane
    for (int i = 1; i < GameConstants.laneCount; i++) {
      final x = sidewalkWidth + (laneWidth * i);
      
      // Start from negative offset to create scrolling effect
      var y = -_scrollOffset;
      
      while (y < screenHeight) {
        // Draw dash
        if (y + _dashLength > 0) {
          canvas.drawLine(
            Offset(x, y.clamp(0, screenHeight)),
            Offset(x, (y + _dashLength).clamp(0, screenHeight)),
            paint,
          );
        }
        y += _dashLength + _dashGap;
      }
    }
  }
  
  void _drawRoadEdges(Canvas canvas, double screenHeight, double screenWidth) {
    final edgePaint = Paint()
      ..color = GameColors.laneMarker
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    // Left edge
    canvas.drawLine(
      Offset(sidewalkWidth, 0),
      Offset(sidewalkWidth, screenHeight),
      edgePaint,
    );
    
    // Right edge
    canvas.drawLine(
      Offset(screenWidth - sidewalkWidth, 0),
      Offset(screenWidth - sidewalkWidth, screenHeight),
      edgePaint,
    );
  }
}

/// Internal class for parallax building data
class _Building {
  double x;
  double y;
  final double width;
  final double height;
  final Color color;
  final int windowRows;
  final int windowCols;
  
  _Building({
    required this.width,
    required this.height,
    required this.color,
    required this.windowRows,
    required this.windowCols,
    required this.x,
    required this.y,
  });
}
