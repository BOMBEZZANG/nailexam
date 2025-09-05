import 'dart:math';
import 'package:flutter/material.dart';
import '../core/utils/logger.dart';
import '../managers/game_manager.dart';

enum GestureType {
  tap,
  drag,
  dragStart,
  dragEnd,
  longPress,
  pinch,
  swipe,
  doubleTab,
}

enum SwipeDirection { 
  up, 
  down, 
  left, 
  right 
}

class GestureController {
  final Function(GestureType, Offset, {dynamic data}) onGesture;
  
  // Gesture recognition parameters
  static const double minSwipeDistance = 50.0;
  static const double minDragDistance = 10.0;
  static const Duration longPressDuration = Duration(milliseconds: 500);
  static const Duration doubleTapTimeout = Duration(milliseconds: 300);
  static const double doubleTapDistance = 50.0;
  
  // State tracking
  Offset? _startPosition;
  DateTime? _startTime;
  Offset? _lastTapPosition;
  DateTime? _lastTapTime;
  bool _isDragging = false;
  double _currentScale = 1.0;
  double _initialScale = 1.0;
  
  GestureController({required this.onGesture});
  
  void processTap(Offset position) {
    final now = DateTime.now();
    
    // Check for double tap
    if (_lastTapPosition != null && _lastTapTime != null) {
      final timeDiff = now.difference(_lastTapTime!);
      final distance = (position - _lastTapPosition!).distance;
      
      if (timeDiff < doubleTapTimeout && distance < doubleTapDistance) {
        onGesture(GestureType.doubleTab, position);
        _logGesture('double_tap', position);
        _lastTapPosition = null;
        _lastTapTime = null;
        return;
      }
    }
    
    onGesture(GestureType.tap, position);
    _logGesture('tap', position);
    
    _lastTapPosition = position;
    _lastTapTime = now;
  }
  
  void processDragStart(Offset position) {
    _startPosition = position;
    _startTime = DateTime.now();
    _isDragging = false;
    
    onGesture(GestureType.dragStart, position);
    Logger.d('Drag started at: $position');
  }
  
  void processDragUpdate(Offset position, Offset delta) {
    if (_startPosition == null) return;
    
    final distance = (position - _startPosition!).distance;
    
    if (!_isDragging && distance > minDragDistance) {
      _isDragging = true;
      Logger.d('Drag threshold reached');
    }
    
    if (_isDragging) {
      onGesture(GestureType.drag, position, data: {
        'delta': delta,
        'totalDistance': distance,
        'velocity': _calculateVelocity(position),
      });
      
      _logGesture('drag', position, additionalData: {
        'delta': {'dx': delta.dx, 'dy': delta.dy},
        'distance': distance,
      });
    }
  }
  
  void processDragEnd(Offset position) {
    if (_startPosition == null || _startTime == null) return;
    
    final distance = (position - _startPosition!).distance;
    final duration = DateTime.now().difference(_startTime!);
    final velocity = distance / duration.inMilliseconds;
    
    // Check if it's a swipe (fast movement over distance)
    if (distance > minSwipeDistance && 
        duration < const Duration(milliseconds: 500) &&
        velocity > 0.5) {
      final direction = _calculateSwipeDirection(_startPosition!, position);
      onGesture(GestureType.swipe, position, data: {
        'direction': direction,
        'velocity': velocity,
        'distance': distance,
      });
      _logGesture('swipe', position, additionalData: {
        'direction': direction.toString(),
        'velocity': velocity,
      });
    } else if (_isDragging) {
      onGesture(GestureType.dragEnd, position, data: {
        'totalDistance': distance,
        'duration': duration.inMilliseconds,
      });
      _logGesture('drag_end', position);
    }
    
    _startPosition = null;
    _startTime = null;
    _isDragging = false;
  }
  
  void processLongPress(Offset position) {
    onGesture(GestureType.longPress, position);
    _logGesture('long_press', position);
  }
  
  void processScale(double scale, Offset focalPoint) {
    if (_initialScale == 0) {
      _initialScale = scale;
      return;
    }
    
    final scaleDelta = scale - _currentScale;
    _currentScale = scale;
    
    onGesture(GestureType.pinch, focalPoint, data: {
      'scale': scale,
      'scaleDelta': scaleDelta,
      'focalPoint': focalPoint,
    });
    
    if (scaleDelta.abs() > 0.1) {
      _logGesture('pinch', focalPoint, additionalData: {
        'scale': scale,
        'delta': scaleDelta,
      });
    }
  }
  
  void processScaleEnd() {
    _initialScale = 0;
    _currentScale = 1.0;
  }
  
  SwipeDirection _calculateSwipeDirection(Offset start, Offset end) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    
    if (dx.abs() > dy.abs()) {
      return dx > 0 ? SwipeDirection.right : SwipeDirection.left;
    } else {
      return dy > 0 ? SwipeDirection.down : SwipeDirection.up;
    }
  }
  
  double _calculateVelocity(Offset currentPosition) {
    if (_startPosition == null || _startTime == null) return 0.0;
    
    final distance = (currentPosition - _startPosition!).distance;
    final timeMs = DateTime.now().difference(_startTime!).inMilliseconds;
    
    return timeMs > 0 ? distance / timeMs : 0.0;
  }
  
  void _logGesture(String gestureType, Offset position, {Map<String, dynamic>? additionalData}) {
    final data = <String, dynamic>{
      'position': {'x': position.dx, 'y': position.dy},
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      if (additionalData != null) ...additionalData,
    };
    
    GameManager.instance.logAction(gestureType, data: data);
  }
  
  // Gesture quality assessment
  bool isGestureSteady(List<Offset> points) {
    if (points.length < 3) return true;
    
    double totalVariation = 0.0;
    for (int i = 1; i < points.length - 1; i++) {
      final p1 = points[i - 1];
      final p2 = points[i];
      final p3 = points[i + 1];
      
      // Calculate angle between consecutive segments
      final angle1 = atan2(p2.dy - p1.dy, p2.dx - p1.dx);
      final angle2 = atan2(p3.dy - p2.dy, p3.dx - p2.dx);
      final angleDiff = (angle2 - angle1).abs();
      
      totalVariation += angleDiff;
    }
    
    // Steady if average angle variation is small
    final avgVariation = totalVariation / (points.length - 2);
    return avgVariation < 0.5; // Threshold in radians
  }
  
  double calculateGestureSpeed(List<Offset> points, List<DateTime> timestamps) {
    if (points.length != timestamps.length || points.length < 2) return 0.0;
    
    double totalDistance = 0.0;
    int totalTime = 0;
    
    for (int i = 1; i < points.length; i++) {
      totalDistance += (points[i] - points[i - 1]).distance;
      totalTime += timestamps[i].difference(timestamps[i - 1]).inMilliseconds;
    }
    
    return totalTime > 0 ? totalDistance / totalTime : 0.0;
  }
  
  // Check if gesture is within nail bounds
  bool isGestureOnNail(Offset position, Rect nailBounds) {
    return nailBounds.contains(position);
  }
  
  // Calculate gesture pressure (if available on device)
  double calculatePressure(double pressure) {
    // Normalize pressure (0.0 to 1.0)
    return pressure.clamp(0.0, 1.0);
  }
  
  void reset() {
    _startPosition = null;
    _startTime = null;
    _lastTapPosition = null;
    _lastTapTime = null;
    _isDragging = false;
    _currentScale = 1.0;
    _initialScale = 0;
  }
}