import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../data/models/nail_state.dart';

enum NailShape {
  square,
  round,
  oval,
  almond,
  squoval, // square + oval
}

enum ViewType {
  topDown,
  isometric,
}

class NailPainter extends CustomPainter {
  final NailState nailState;
  final NailShape nailShape;
  final ViewType viewType;
  final double scale;
  final bool showGuides;
  final double polishOpacity;
  
  NailPainter({
    required this.nailState,
    this.nailShape = NailShape.oval,
    this.viewType = ViewType.topDown,
    this.scale = 1.0,
    this.showGuides = false,
    this.polishOpacity = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    if (viewType == ViewType.isometric) {
      _drawIsometricView(canvas, size, center);
    } else {
      _drawTopDownView(canvas, size, center);
    }
    
    // Draw guides if in practice mode
    if (showGuides) {
      _drawGuides(canvas, size);
    }
  }
  
  void _drawTopDownView(Canvas canvas, Size size, Offset center) {
    // Draw nail bed
    _drawNailBed(canvas, size, center);
    
    // Draw nail plate with shape
    _drawNailPlate(canvas, size, center);
    
    // Draw cuticle area
    if (nailState.hasCuticle) {
      _drawCuticle(canvas, size, center);
    }
    
    // Draw lunula (half-moon)
    _drawLunula(canvas, size, center);
    
    // Draw polish if applied
    if (nailState.hasPolish) {
      _drawPolish(canvas, size, center);
    }
    
    // Draw nail free edge
    _drawFreeEdge(canvas, size, center);
    
    // Draw side walls/grooves
    _drawNailGrooves(canvas, size, center);
  }
  
  void _drawIsometricView(Canvas canvas, Size size, Offset center) {
    // Apply isometric transformation
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.skew(-0.5, 0.0); // Isometric skew
    canvas.translate(-center.dx, -center.dy);
    
    _drawTopDownView(canvas, size, center);
    
    canvas.restore();
  }
  
  void _drawFingerBase(Canvas canvas, Size size, Offset center) {
    final fingerPaint = Paint()
      ..color = const Color(0xFFFDBCAC) // Skin tone - light
      ..style = PaintingStyle.fill;
    
    // Finger shape - wider at base, narrower at tip
    final fingerPath = Path();
    final fingerWidth = size.width * 0.8;
    final fingerHeight = size.height;
    
    fingerPath.moveTo(center.dx - fingerWidth / 2, fingerHeight);
    fingerPath.quadraticBezierTo(
      center.dx - fingerWidth / 2.5, fingerHeight * 0.5,
      center.dx - fingerWidth / 3, 0,
    );
    fingerPath.lineTo(center.dx + fingerWidth / 3, 0);
    fingerPath.quadraticBezierTo(
      center.dx + fingerWidth / 2.5, fingerHeight * 0.5,
      center.dx + fingerWidth / 2, fingerHeight,
    );
    fingerPath.close();
    
    canvas.drawPath(fingerPath, fingerPaint);
    
    // Add slight shading for depth
    final shadePaint = Paint()
      ..color = const Color(0xFFE8A598).withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    final shadePath = Path();
    shadePath.moveTo(center.dx - fingerWidth / 2, fingerHeight);
    shadePath.quadraticBezierTo(
      center.dx - fingerWidth / 2.5, fingerHeight * 0.7,
      center.dx - fingerWidth / 3.5, fingerHeight * 0.4,
    );
    shadePath.lineTo(center.dx - fingerWidth / 4, fingerHeight * 0.4);
    shadePath.quadraticBezierTo(
      center.dx - fingerWidth / 3, fingerHeight * 0.7,
      center.dx - fingerWidth / 2.2, fingerHeight,
    );
    shadePath.close();
    
    canvas.drawPath(shadePath, shadePaint);
  }
  
  void _drawNailBed(Canvas canvas, Size size, Offset center) {
    final nailBedPaint = Paint()
      ..color = const Color(0xFFFFB3BA) // Pink nail bed color
      ..style = PaintingStyle.fill;
    
    final nailRect = _getNailRect(size, center);
    final nailPath = _getNailPath(nailRect, nailShape);
    
    canvas.drawPath(nailPath, nailBedPaint);
  }
  
  void _drawNailPlate(Canvas canvas, Size size, Offset center) {
    final nailPlatePaint = Paint()
      ..color = const Color(0xFFFFF5F0).withOpacity(0.7) // Natural nail color
      ..style = PaintingStyle.fill;
    
    final nailRect = _getNailRect(size, center);
    final nailPath = _getNailPath(nailRect, nailShape);
    
    canvas.drawPath(nailPath, nailPlatePaint);
    
    // Add nail shine/highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    
    final highlightPath = Path();
    final highlightRect = Rect.fromLTWH(
      nailRect.left + nailRect.width * 0.2,
      nailRect.top + nailRect.height * 0.1,
      nailRect.width * 0.3,
      nailRect.height * 0.2,
    );
    highlightPath.addOval(highlightRect);
    
    canvas.drawPath(highlightPath, highlightPaint);
  }
  
  void _drawCuticle(Canvas canvas, Size size, Offset center) {
    final cuticlePaint = Paint()
      ..color = const Color(0xFFE8A598)
      ..style = PaintingStyle.fill;
    
    final nailRect = _getNailRect(size, center);
    final cuticlePath = Path();
    
    // Cuticle curve at nail base
    cuticlePath.moveTo(nailRect.left, nailRect.bottom - 5);
    cuticlePath.quadraticBezierTo(
      nailRect.center.dx, nailRect.bottom + 8,
      nailRect.right, nailRect.bottom - 5,
    );
    cuticlePath.lineTo(nailRect.right, nailRect.bottom);
    cuticlePath.quadraticBezierTo(
      nailRect.center.dx, nailRect.bottom + 3,
      nailRect.left, nailRect.bottom,
    );
    cuticlePath.close();
    
    canvas.drawPath(cuticlePath, cuticlePaint);
  }
  
  void _drawLunula(Canvas canvas, Size size, Offset center) {
    final lunulaPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    
    final nailRect = _getNailRect(size, center);
    final lunulaPath = Path();
    
    // Half-moon shape at nail base
    final lunulaRect = Rect.fromLTWH(
      nailRect.left + nailRect.width * 0.25,
      nailRect.bottom - nailRect.height * 0.25,
      nailRect.width * 0.5,
      nailRect.height * 0.3,
    );
    
    lunulaPath.addArc(lunulaRect, 0, math.pi);
    canvas.drawPath(lunulaPath, lunulaPaint);
  }
  
  void _drawPolish(Canvas canvas, Size size, Offset center) {
    if (!nailState.hasPolish || polishOpacity <= 0) return;
    
    final polishPaint = Paint()
      ..color = nailState.polishColor.withOpacity(0.8 * polishOpacity)
      ..style = PaintingStyle.fill;
    
    final nailRect = _getNailRect(size, center);
    final coverageHeight = nailRect.height * nailState.polishCoverage;
    
    final polishRect = Rect.fromLTWH(
      nailRect.left,
      nailRect.top,
      nailRect.width,
      coverageHeight,
    );
    
    final polishPath = _getNailPath(polishRect, nailShape);
    canvas.drawPath(polishPath, polishPaint);
    
    // Add polish shine
    final shinePaint = Paint()
      ..color = Colors.white.withOpacity(nailState.shineLevel * 0.4 * polishOpacity)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    
    final shinePath = Path();
    final shineRect = Rect.fromLTWH(
      polishRect.left + polishRect.width * 0.3,
      polishRect.top + polishRect.height * 0.1,
      polishRect.width * 0.2,
      polishRect.height * 0.15,
    );
    shinePath.addOval(shineRect);
    
    canvas.drawPath(shinePath, shinePaint);
  }
  
  void _drawFreeEdge(Canvas canvas, Size size, Offset center) {
    final freeEdgePaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.fill;
    
    final nailRect = _getNailRect(size, center);
    final freeEdgeHeight = nailRect.height * 0.15 * nailState.length;
    
    final freeEdgeRect = Rect.fromLTWH(
      nailRect.left,
      nailRect.top,
      nailRect.width,
      freeEdgeHeight,
    );
    
    final freeEdgePath = _getNailPath(freeEdgeRect, nailShape);
    canvas.drawPath(freeEdgePath, freeEdgePaint);
  }
  
  void _drawNailGrooves(Canvas canvas, Size size, Offset center) {
    final groovePaint = Paint()
      ..color = const Color(0xFFE8A598).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    final nailRect = _getNailRect(size, center);
    final nailPath = _getNailPath(nailRect, nailShape);
    
    canvas.drawPath(nailPath, groovePaint);
  }
  
  void _drawGuides(Canvas canvas, Size size) {
    final guidePaint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeDashArray = [5, 5];
    
    // Center lines
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      guidePaint,
    );
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      guidePaint,
    );
  }
  
  Rect _getNailRect(Size size, Offset center) {
    final nailWidth = size.width * 0.8;
    final nailHeight = size.height * 0.8;
    
    return Rect.fromCenter(
      center: center,
      width: nailWidth,
      height: nailHeight,
    );
  }
  
  Path _getNailPath(Rect rect, NailShape shape) {
    final path = Path();
    
    switch (shape) {
      case NailShape.square:
        path.addRect(rect);
        break;
        
      case NailShape.round:
        path.addRRect(RRect.fromRectAndRadius(
          rect,
          Radius.circular(rect.width / 2),
        ));
        break;
        
      case NailShape.oval:
        path.addOval(rect);
        break;
        
      case NailShape.almond:
        path.moveTo(rect.center.dx, rect.top);
        path.quadraticBezierTo(
          rect.left, rect.top + rect.height * 0.3,
          rect.left, rect.center.dy,
        );
        path.quadraticBezierTo(
          rect.left, rect.bottom - rect.height * 0.1,
          rect.center.dx, rect.bottom,
        );
        path.quadraticBezierTo(
          rect.right, rect.bottom - rect.height * 0.1,
          rect.right, rect.center.dy,
        );
        path.quadraticBezierTo(
          rect.right, rect.top + rect.height * 0.3,
          rect.center.dx, rect.top,
        );
        path.close();
        break;
        
      case NailShape.squoval:
        path.addRRect(RRect.fromRectAndRadius(
          rect,
          Radius.circular(rect.width / 4),
        ));
        break;
    }
    
    return path;
  }
  
  @override
  bool shouldRepaint(NailPainter oldDelegate) {
    return oldDelegate.nailState != nailState ||
           oldDelegate.nailShape != nailShape ||
           oldDelegate.viewType != viewType ||
           oldDelegate.scale != scale ||
           oldDelegate.showGuides != showGuides ||
           oldDelegate.polishOpacity != polishOpacity;
  }
}

// Extension to add dash support to Paint
extension PaintExtension on Paint {
  set strokeDashArray(List<double> pattern) {
    // This would require a custom path effect implementation
    // For now, we'll use solid lines
  }
}