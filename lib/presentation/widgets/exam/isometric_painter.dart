import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../data/models/nail_state.dart';
import '../../../data/models/tool.dart';

class IsometricPainter extends CustomPainter {
  final List<NailState> nailStates;
  final Matrix4 isometricTransform;
  final double scale;
  final Tool? currentTool;
  final int? highlightedNail;
  final Animation<double>? highlightAnimation;
  final List<Offset> dragPath;

  IsometricPainter({
    required this.nailStates,
    required this.isometricTransform,
    required this.scale,
    this.currentTool,
    this.highlightedNail,
    this.highlightAnimation,
    this.dragPath = const [],
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw work surface with isometric grid
    _drawWorkSurface(canvas, size);

    // Draw hand base
    _drawHandBase(canvas, size);

    // Draw each nail with current state
    _drawNails(canvas, size);

    // Draw drag path if active
    _drawDragPath(canvas, size);

    // Draw tool cursor if tool is selected
    _drawToolCursor(canvas, size);

    // Draw overlays (guides, measurements)
    _drawOverlays(canvas, size);
  }

  void _drawWorkSurface(Canvas canvas, Size size) {
    // Background gradient
    final backgroundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [const Color(0xFFF8F8F8), const Color(0xFFE8E8E8)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );

    // Draw isometric grid
    _drawIsometricGrid(canvas, size);

    // Draw work surface shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    final workSurfaceRect = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.7),
      width: size.width * 0.8,
      height: size.height * 0.6,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(workSurfaceRect, const Radius.circular(20)),
      shadowPaint,
    );
  }

  void _drawIsometricGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.15)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    final gridSpacing = 40.0 * scale;

    // Vertical lines
    for (double x = 0; x <= size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Horizontal lines
    for (double y = 0; y <= size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Diagonal lines for isometric effect
    final isometricPaint = Paint()
      ..color = Colors.blue.withOpacity(0.1)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (double i = 0; i <= 20; i++) {
      final x = size.width * (i / 20);
      final y = size.height * (i / 20);

      // Left diagonal
      canvas.drawLine(
        Offset(x, 0),
        Offset(x - size.height * 0.3, size.height),
        isometricPaint,
      );

      // Right diagonal
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y + size.width * 0.3),
        isometricPaint,
      );
    }
  }

  void _drawHandBase(Canvas canvas, Size size) {
    // Hand silhouette
    final handPaint = Paint()
      ..color =
          const Color(0xFFFFE0BD) // Skin tone
      ..style = PaintingStyle.fill;

    final handShadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // Draw only right hand centered and bigger
    _drawRightHandCentered(canvas, size, handPaint, handShadowPaint);
  }

  void _drawLeftHand(
    Canvas canvas,
    Size size,
    Paint handPaint,
    Paint shadowPaint,
  ) {
    final handCenter = Offset(size.width * 0.25, size.height * 0.5);
    final handWidth = size.width * 0.12 * scale;
    final handHeight = size.height * 0.25 * scale;

    // Draw shadow first
    canvas.drawOval(
      Rect.fromCenter(
        center: handCenter + const Offset(3, 3),
        width: handWidth,
        height: handHeight,
      ),
      shadowPaint,
    );

    // Draw hand
    final handPath = Path()
      ..addOval(
        Rect.fromCenter(
          center: handCenter,
          width: handWidth,
          height: handHeight,
        ),
      );

    canvas.drawPath(handPath, handPaint);

    // Add hand details (simplified)
    final detailPaint = Paint()
      ..color = const Color(0xFFFFD0A0)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw hand outline
    canvas.drawPath(handPath, detailPaint);
  }

  void _drawRightHandCentered(
    Canvas canvas,
    Size size,
    Paint handPaint,
    Paint shadowPaint,
  ) {
    final handCenter = Offset(size.width * 0.5, size.height * 0.5); // Centered
    final handWidth = size.width * 0.2 * scale; // Bigger hand
    final handHeight = size.height * 0.35 * scale; // Bigger hand

    // Draw shadow first
    canvas.drawOval(
      Rect.fromCenter(
        center: handCenter + const Offset(4, 4),
        width: handWidth,
        height: handHeight,
      ),
      shadowPaint,
    );

    // Draw hand
    final handPath = Path()
      ..addOval(
        Rect.fromCenter(
          center: handCenter,
          width: handWidth,
          height: handHeight,
        ),
      );

    canvas.drawPath(handPath, handPaint);

    // Add hand details
    final detailPaint = Paint()
      ..color = const Color(0xFFFFD0A0)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawPath(handPath, detailPaint);
  }

  void _drawRightHand(
    Canvas canvas,
    Size size,
    Paint handPaint,
    Paint shadowPaint,
  ) {
    final handCenter = Offset(size.width * 0.75, size.height * 0.5);
    final handWidth = size.width * 0.12 * scale;
    final handHeight = size.height * 0.25 * scale;

    // Draw shadow first
    canvas.drawOval(
      Rect.fromCenter(
        center: handCenter + const Offset(3, 3),
        width: handWidth,
        height: handHeight,
      ),
      shadowPaint,
    );

    // Draw hand
    final handPath = Path()
      ..addOval(
        Rect.fromCenter(
          center: handCenter,
          width: handWidth,
          height: handHeight,
        ),
      );

    canvas.drawPath(handPath, handPaint);

    // Add hand details
    final detailPaint = Paint()
      ..color = const Color(0xFFFFD0A0)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawPath(handPath, detailPaint);
  }

  void _drawNails(Canvas canvas, Size size) {
    final nailPositions = _calculateNailPositions(size);

    for (int i = 0; i < nailStates.length && i < nailPositions.length; i++) {
      _drawSingleNail(canvas, size, i, nailStates[i], nailPositions[i]);
    }
  }

  void _drawSingleNail(
    Canvas canvas,
    Size size,
    int index,
    NailState state,
    Offset position,
  ) {
    final nailWidth = 40.0 * scale; // Bigger nails
    final nailHeight = 55.0 * scale; // Bigger nails

    // Draw nail shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final shadowRect = Rect.fromCenter(
      center: position + const Offset(2, 2),
      width: nailWidth,
      height: nailHeight,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(shadowRect, Radius.circular(nailHeight * 0.3)),
      shadowPaint,
    );

    // Draw nail base
    final basePaint = Paint()
      ..color = state.hasPolish ? state.polishColor : const Color(0xFFFFF0E8)
      ..style = PaintingStyle.fill;

    final nailRect = Rect.fromCenter(
      center: position,
      width: nailWidth,
      height: nailHeight,
    );

    final nailRRect = RRect.fromRectAndRadius(
      nailRect,
      Radius.circular(nailHeight * 0.3),
    );

    canvas.drawRRect(nailRRect, basePaint);

    // Draw cuticle if present
    if (state.hasCuticle) {
      final cuticlePaint = Paint()
        ..color = const Color(0xFFFFD0A0)
        ..style = PaintingStyle.fill;

      final cuticleRect = Rect.fromCenter(
        center: Offset(position.dx, position.dy - nailHeight * 0.3),
        width: nailWidth * 0.8,
        height: 8 * scale,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(cuticleRect, const Radius.circular(4)),
        cuticlePaint,
      );
    }

    // Draw polish coverage if partial
    if (state.hasPolish && state.polishCoverage < 1.0) {
      final coveragePaint = Paint()
        ..color = state.polishColor.withOpacity(0.7)
        ..style = PaintingStyle.fill;

      final coverageHeight = nailHeight * state.polishCoverage;
      final coverageRect = Rect.fromCenter(
        center: Offset(
          position.dx,
          position.dy + (nailHeight - coverageHeight) * 0.5,
        ),
        width: nailWidth * 0.9,
        height: coverageHeight,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          coverageRect,
          Radius.circular(nailHeight * 0.2),
        ),
        coveragePaint,
      );
    }

    // Draw shine effect
    if (state.shineLevel > 0) {
      final shinePaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.6 * state.shineLevel),
            Colors.transparent,
          ],
        ).createShader(nailRect)
        ..style = PaintingStyle.fill;

      final shineRect = Rect.fromLTWH(
        nailRect.left + 2,
        nailRect.top + 2,
        nailRect.width * 0.4,
        nailRect.height * 0.6,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(shineRect, const Radius.circular(4)),
        shinePaint,
      );
    }

    // Draw sparkling light effect if this nail is highlighted
    if (highlightedNail == index) {
      final animValue = highlightAnimation?.value ?? 1.0;

      // Debug: Print when we're drawing highlight
      print(
        'Drawing sparkle effect for nail $index with animValue: $animValue, animationStatus: ${highlightAnimation?.status}',
      );

      // Only draw sparkle if we have a valid animation value
      if (animValue > 0.0) {
        // Sparkling light effect - multiple overlapping circles with different opacities
        _drawSparkleEffect(canvas, nailRect, animValue);
      }
    }

    // Draw nail outline
    final outlinePaint = Paint()
      ..color = Colors.grey.withOpacity(0.6)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(nailRRect, outlinePaint);

    // Draw completion indicator
    _drawCompletionIndicator(
      canvas,
      position,
      state.calculateCompletionScore(),
    );
  }

  void _drawCompletionIndicator(
    Canvas canvas,
    Offset nailPosition,
    double completion,
  ) {
    final indicatorSize = 8.0 * scale;
    final indicatorPosition = Offset(
      nailPosition.dx + 20,
      nailPosition.dy - 20,
    );

    // Background circle
    final bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(indicatorPosition, indicatorSize, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = completion > 0.8
          ? Colors.green
          : completion > 0.5
          ? Colors.orange
          : Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressRect = Rect.fromCenter(
      center: indicatorPosition,
      width: indicatorSize * 2,
      height: indicatorSize * 2,
    );

    canvas.drawArc(
      progressRect,
      -math.pi / 2,
      2 * math.pi * completion,
      false,
      progressPaint,
    );
  }

  void _drawDragPath(Canvas canvas, Size size) {
    if (dragPath.length < 2) return;

    final pathPaint = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(dragPath.first.dx, dragPath.first.dy);

    for (int i = 1; i < dragPath.length; i++) {
      path.lineTo(dragPath[i].dx, dragPath[i].dy);
    }

    canvas.drawPath(path, pathPaint);
  }

  void _drawToolCursor(Canvas canvas, Size size) {
    if (currentTool == null) return;

    // This would show the current tool cursor - simplified implementation
    final cursorPaint = Paint()
      ..color = Colors.blue.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    // Draw tool indicator in top-right
    final indicatorPosition = Offset(size.width - 50, 50);
    canvas.drawCircle(indicatorPosition, 20, cursorPaint);

    // Draw tool icon (simplified)
    final textPainter = TextPainter(
      text: TextSpan(
        text: _getToolEmoji(currentTool!.type),
        style: const TextStyle(fontSize: 24),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        indicatorPosition.dx - textPainter.width / 2,
        indicatorPosition.dy - textPainter.height / 2,
      ),
    );
  }

  String _getToolEmoji(ToolType type) {
    switch (type) {
      case ToolType.nailFile:
        return '📏';
      case ToolType.buffer:
        return '⬜';
      case ToolType.cuticlePusher:
        return '📌';
      case ToolType.polishBrush:
        return '🖌️';
      case ToolType.nailTips:
        return '💅';
      case ToolType.cottonPad:
        return '⭕';
      case ToolType.cuticleNipper:
        return '✂️';
      case ToolType.handSanitizer:
        return '🧴';
      case ToolType.uvLamp:
        return '💡';
      case ToolType.remover:
        return '🧽';
      case ToolType.sandingBlock:
        return '🧱';
      case ToolType.fingerBowl:
        return '🫧';
      case ToolType.cuticleOil:
        return '💧';
      case ToolType.disinfectantSpray:
        return '💨';
      case ToolType.sterilizedGauze:
        return '🩹';
      default:
        return '🔧';
    }
  }

  void _drawSparkleEffect(Canvas canvas, Rect nailRect, double animValue) {
    final center = nailRect.center;
    final maxRadius = nailRect.width * 1.0; // Slightly larger sparkle area

    // Create multiple sparkle circles with different properties
    final sparkles = [
      {'radius': maxRadius * 0.2, 'opacity': 1.0, 'color': Colors.white},
      {
        'radius': maxRadius * 0.4,
        'opacity': 0.8,
        'color': Colors.yellow.shade200,
      },
      {
        'radius': maxRadius * 0.6,
        'opacity': 0.6,
        'color': Colors.blue.shade200,
      },
      {
        'radius': maxRadius * 0.8,
        'opacity': 0.4,
        'color': Colors.pink.shade100,
      },
      {'radius': maxRadius * 1.0, 'opacity': 0.2, 'color': Colors.white},
    ];

    for (int i = 0; i < sparkles.length; i++) {
      final sparkle = sparkles[i];
      final radius = (sparkle['radius'] as double) * animValue;
      final opacity = (sparkle['opacity'] as double) * animValue;
      final color = sparkle['color'] as Color;

      // Create gradient effect for each sparkle circle
      final sparklePaint = Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          colors: [
            color.withOpacity(opacity),
            color.withOpacity(opacity * 0.6),
            color.withOpacity(opacity * 0.2),
            color.withOpacity(0.0),
          ],
          stops: const [0.0, 0.4, 0.8, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius, sparklePaint);
    }

    // Add small bright sparkle dots around the nail - more visible
    final sparkleCount = 8;
    for (int i = 0; i < sparkleCount; i++) {
      final angle =
          (i * 2 * math.pi / sparkleCount) +
          (animValue * math.pi * 3); // Faster rotation
      final sparkleRadius = maxRadius * 1.3;
      final sparkleCenter = Offset(
        center.dx + math.cos(angle) * sparkleRadius * animValue,
        center.dy + math.sin(angle) * sparkleRadius * animValue,
      );

      final sparkleSize = 4.0 * animValue; // Bigger sparkles
      final sparkleDotPaint = Paint()
        ..color = Colors.white.withOpacity(1.0 * animValue)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(sparkleCenter, sparkleSize, sparkleDotPaint);

      // Add smaller inner sparkle with different color
      final innerSparkle = Paint()
        ..color = Colors.yellow.shade300.withOpacity(0.9 * animValue)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(sparkleCenter, sparkleSize * 0.6, innerSparkle);

      // Add even smaller central bright spot
      final centerSparkle = Paint()
        ..color = Colors.white.withOpacity(1.0 * animValue)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(sparkleCenter, sparkleSize * 0.3, centerSparkle);
    }

    // Add a central bright flash
    final centralFlash = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.8 * animValue),
          Colors.yellow.shade100.withOpacity(0.4 * animValue),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius * 0.5))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, maxRadius * 0.5 * animValue, centralFlash);
  }

  void _drawOverlays(Canvas canvas, Size size) {
    // Draw measurement guides if needed
    // Draw technique hints
    // This is where additional UI overlays would go
  }

  List<Offset> _calculateNailPositions(Size size) {
    // Calculate positions for right hand only (5 nails) centered and bigger
    final centerX = size.width * 0.5; // Center horizontally
    final centerY = size.height * 0.5; // Center vertically
    final spacing = 80.0; // Bigger spacing for larger hand

    return [
      // Right hand only (thumb to pinky) - centered and spread out
      Offset(centerX + spacing * 2, centerY + 30), // Thumb
      Offset(centerX + spacing, centerY - 60), // Index
      Offset(centerX, centerY - 80), // Middle (center finger)
      Offset(centerX - spacing, centerY - 60), // Ring
      Offset(centerX - spacing * 2, centerY + 15), // Pinky
    ];
  }

  @override
  bool shouldRepaint(IsometricPainter oldDelegate) {
    return oldDelegate.nailStates != nailStates ||
        oldDelegate.scale != scale ||
        oldDelegate.highlightedNail != highlightedNail ||
        oldDelegate.currentTool != currentTool ||
        oldDelegate.dragPath.length != dragPath.length;
  }
}
