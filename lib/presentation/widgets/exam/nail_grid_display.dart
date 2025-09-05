import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../../data/models/nail_state.dart';
import 'nail_painter.dart';

class NailGridDisplay extends StatelessWidget {
  final List<NailState> nailStates;
  final bool isPracticeMode;
  final Function(int nailIndex, Offset localPosition)? onNailTap;
  final int? selectedNail;
  final double scale;
  final Function(int nailIndex, double progress)? onPolishRemovalProgress;
  final bool isPolishRemovalMode;
  final Function(int nailIndex, double progress)? onNailFilingProgress;
  final bool isNailFilingMode;
  
  const NailGridDisplay({
    super.key,
    required this.nailStates,
    this.isPracticeMode = false,
    this.onNailTap,
    this.selectedNail,
    this.scale = 1.0,
    this.onPolishRemovalProgress,
    this.isPolishRemovalMode = false,
    this.onNailFilingProgress,
    this.isNailFilingMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _getCrossAxisCount(constraints),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8, // Nail aspect ratio
          ),
          itemCount: math.min(nailStates.length, 10), // Limit to 10 nails max
          itemBuilder: (context, index) {
            return _buildSingleNail(context, index);
          },
        );
      },
    );
  }
  
  int _getCrossAxisCount(BoxConstraints constraints) {
    if (constraints.maxWidth > 800) {
      return 5; // 5 nails per row on wide screens
    } else if (constraints.maxWidth > 500) {
      return 3; // 3 nails per row on medium screens
    } else {
      return 2; // 2 nails per row on small screens
    }
  }
  
  Widget _buildSingleNail(BuildContext context, int index) {
    final isSelected = selectedNail == index;
    final nailState = nailStates[index];
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected 
              ? Theme.of(context).primaryColor 
              : Colors.grey.shade300,
          width: isSelected ? 3 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Nail label
          Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                    : Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(11),
                  topRight: Radius.circular(11),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fingerprint,
                    size: 14,
                    color: isSelected 
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getNailLabel(index),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected 
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            
            // Nail image
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleNailWidget(
                  nailState: nailState,
                  nailIndex: index,
                  isSelected: isSelected,
                  isPracticeMode: isPracticeMode,
                  scale: scale,
                  onTap: (localPosition) => onNailTap?.call(index, localPosition),
                  onPolishRemovalProgress: onPolishRemovalProgress,
                  isPolishRemovalMode: isPolishRemovalMode,
                  onNailFilingProgress: onNailFilingProgress,
                  isNailFilingMode: isNailFilingMode,
                ),
              ),
            ),
            
            // Status indicator
            Container(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (nailState.hasPolish) ...[
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: nailState.polishColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade400, width: 0.5),
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Icon(
                    nailState.hasPolish ? Icons.check_circle : Icons.radio_button_unchecked,
                    size: 12,
                    color: nailState.hasPolish 
                        ? Colors.green.shade600 
                        : Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ],
        ),
    );
    
  }
  
  String _getNailLabel(int index) {
    const labels = ['엄지', '검지', '중지', '약지', '새끼'];
    return index < labels.length ? '${labels[index]} 손가락' : '손가락 ${index + 1}';
  }
}

class SingleNailWidget extends StatefulWidget {
  final NailState nailState;
  final int nailIndex;
  final bool isSelected;
  final bool isPracticeMode;
  final double scale;
  final Function(Offset localPosition)? onTap;
  final Function(int nailIndex, double progress)? onPolishRemovalProgress;
  final bool isPolishRemovalMode;
  final Function(int nailIndex, double progress)? onNailFilingProgress;
  final bool isNailFilingMode;
  
  const SingleNailWidget({
    super.key,
    required this.nailState,
    required this.nailIndex,
    this.isSelected = false,
    this.isPracticeMode = false,
    this.scale = 1.0,
    this.onTap,
    this.onPolishRemovalProgress,
    this.isPolishRemovalMode = false,
    this.onNailFilingProgress,
    this.isNailFilingMode = false,
  });

  @override
  State<SingleNailWidget> createState() => _SingleNailWidgetState();
}

class _SingleNailWidgetState extends State<SingleNailWidget>
    with TickerProviderStateMixin {
  late AnimationController _rippleController;
  late AnimationController _flashController;
  late Animation<double> _rippleAnimation;
  late Animation<double> _flashAnimation;
  
  bool _showRipple = false;
  Offset? _ripplePosition;
  
  // Polish removal mechanics
  double _polishRemovalProgress = 0.0;
  List<Offset> _swipePoints = [];
  Offset? _lastSwipePosition;
  List<PolishParticle> _particles = [];
  late AnimationController _particleController;
  
  // Nail filing mechanics
  double _filingProgress = 0.0;
  List<Offset> _filingStrokes = [];
  List<FilingDustParticle> _dustParticles = [];
  bool _isValidFilingDirection = false;

  @override
  void initState() {
    super.initState();
    
    // Ripple animation for click feedback
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));
    
    // Flash animation for tool application
    _flashController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _flashAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flashController,
      curve: Curves.elasticOut,
    ));
    
    // Particle animation controller
    _particleController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
    
    // Initialize polish removal progress based on nail state
    _polishRemovalProgress = widget.nailState.hasPolish ? 0.0 : 1.0;
    
    // Initialize nail filing progress
    _filingProgress = widget.nailState.needsFiling ? 0.0 : 1.0;
  }
  
  @override
  void dispose() {
    _rippleController.dispose();
    _flashController.dispose();
    _particleController.dispose();
    super.dispose();
  }
  
  void _triggerEffects(Offset position) {
    setState(() {
      _showRipple = true;
      _ripplePosition = position;
    });
    
    // Start ripple animation
    _rippleController.forward().then((_) {
      _rippleController.reset();
      setState(() {
        _showRipple = false;
      });
    });
    
    // Start flash animation
    _flashController.forward().then((_) {
      _flashController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapDown: (widget.isPolishRemovalMode || widget.isNailFilingMode) ? null : (details) {
            // Check if tap is within nail boundaries
            if (_isWithinNailBounds(details.localPosition, constraints.biggest)) {
              _triggerEffects(details.localPosition);
              widget.onTap?.call(details.localPosition);
            }
          },
          onPanStart: widget.isPolishRemovalMode ? (details) {
            if (_isWithinNailBounds(details.localPosition, constraints.biggest)) {
              _startPolishRemoval(details.localPosition);
            }
          } : widget.isNailFilingMode ? (details) {
            if (_isWithinNailBounds(details.localPosition, constraints.biggest)) {
              _startNailFiling(details.localPosition);
            }
          } : null,
          onPanUpdate: widget.isPolishRemovalMode ? (details) {
            if (_isWithinNailBounds(details.localPosition, constraints.biggest)) {
              _updatePolishRemoval(details.localPosition, constraints.biggest);
            }
          } : widget.isNailFilingMode ? (details) {
            if (_isWithinNailBounds(details.localPosition, constraints.biggest)) {
              _updateNailFiling(details.localPosition, constraints.biggest);
            }
          } : null,
          onPanEnd: widget.isPolishRemovalMode ? (details) {
            _endPolishRemoval();
          } : widget.isNailFilingMode ? (details) {
            _endNailFiling();
          } : null,
          child: AnimatedBuilder(
            animation: Listenable.merge([_rippleAnimation, _flashAnimation]),
            builder: (context, child) {
              return Stack(
                children: [
                  // Nail painter with flash effect
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: _flashAnimation.value > 0 ? [
                        BoxShadow(
                          color: Theme.of(context).primaryColor.withOpacity(
                            0.4 * _flashAnimation.value
                          ),
                          blurRadius: 10 * _flashAnimation.value,
                          spreadRadius: 3 * _flashAnimation.value,
                        ),
                      ] : null,
                    ),
                    child: CustomPaint(
                      size: constraints.biggest,
                      painter: NailPainter(
                        nailState: widget.nailState,
                        nailShape: _getNailShape(widget.nailIndex),
                        viewType: ViewType.topDown,
                        scale: widget.scale,
                        showGuides: widget.isPracticeMode && widget.isSelected,
                        polishOpacity: widget.nailState.hasPolish ? 1.0 - _polishRemovalProgress : 0.0,
                        filingProgress: _filingProgress,
                      ),
                    ),
                  ),
                  
                  // Ripple effect
                  if (_showRipple && _ripplePosition != null)
                    Positioned(
                      left: _ripplePosition!.dx - 30,
                      top: _ripplePosition!.dy - 30,
                      child: IgnorePointer(
                        child: AnimatedBuilder(
                          animation: _rippleAnimation,
                          builder: (context, child) {
                            return Container(
                              width: 60 * _rippleAnimation.value,
                              height: 60 * _rippleAnimation.value,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(context).primaryColor.withOpacity(
                                    0.8 * (1 - _rippleAnimation.value)
                                  ),
                                  width: 2,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  
                  // Tool application sparkle effect
                  if (_flashAnimation.value > 0)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: AnimatedBuilder(
                          animation: _flashAnimation,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: SparkleEffectPainter(
                                animation: _flashAnimation.value,
                                color: Theme.of(context).primaryColor,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  
                  // Polish particles
                  if (_particles.isNotEmpty)
                    ...List.generate(_particles.length, (index) {
                      final particle = _particles[index];
                      return AnimatedBuilder(
                        animation: _particleController,
                        builder: (context, child) {
                          final progress = (DateTime.now().millisecondsSinceEpoch - particle.createdAt) / 1000.0;
                          if (progress > 1.0) {
                            return const SizedBox.shrink();
                          }
                          
                          final opacity = 1.0 - progress;
                          final dy = particle.position.dy + (progress * 50);
                          
                          return Positioned(
                            left: particle.position.dx - 4,
                            top: dy - 4,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: particle.color.withOpacity(opacity * 0.8),
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  
                  // Polish removal progress indicator - show on all nails during step 2
                  if (widget.isPolishRemovalMode && 
                      widget.nailState.hasPolish && 
                      _polishRemovalProgress > 0)
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${(_polishRemovalProgress * 100).toInt()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  
                  // Filing dust particles
                  if (_dustParticles.isNotEmpty)
                    ...List.generate(_dustParticles.length, (index) {
                      final particle = _dustParticles[index];
                      return AnimatedBuilder(
                        animation: _particleController,
                        builder: (context, child) {
                          final progress = (DateTime.now().millisecondsSinceEpoch - particle.createdAt) / 1000.0;
                          if (progress > 1.0) {
                            return const SizedBox.shrink();
                          }
                          
                          final opacity = 1.0 - progress;
                          final dx = particle.position.dx + (particle.velocityX * progress);
                          final dy = particle.position.dy + (particle.velocityY * progress);
                          
                          return Positioned(
                            left: dx - 3,
                            top: dy - 3,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: particle.color.withOpacity(opacity * 0.7),
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  
                  // Filing progress indicator
                  if (widget.isNailFilingMode && _filingProgress > 0)
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.build,
                                color: Colors.white,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${(_filingProgress * 100).toInt()}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
  
  void _startPolishRemoval(Offset position) {
    setState(() {
      _swipePoints.clear();
      _swipePoints.add(position);
      _lastSwipePosition = position;
    });
  }
  
  void _updatePolishRemoval(Offset position, Size widgetSize) {
    if (_lastSwipePosition == null) return;
    
    // Calculate swipe distance
    final distance = (position - _lastSwipePosition!).distance;
    
    // Only process if moved enough distance
    if (distance > 5) {
      setState(() {
        // Add to swipe points
        _swipePoints.add(position);
        if (_swipePoints.length > 20) {
          _swipePoints.removeAt(0);
        }
        
        // Increase removal progress based on swipe
        _polishRemovalProgress = (_polishRemovalProgress + 0.02).clamp(0.0, 1.0);
        
        // Create particles
        if (_polishRemovalProgress < 1.0 && math.Random().nextDouble() > 0.3) {
          _particles.add(PolishParticle(
            position: position,
            color: widget.nailState.polishColor,
            createdAt: DateTime.now().millisecondsSinceEpoch,
          ));
        }
        
        // Clean old particles
        final now = DateTime.now().millisecondsSinceEpoch;
        _particles.removeWhere((p) => now - p.createdAt > 1000);
        
        _lastSwipePosition = position;
        
        // Notify progress
        widget.onPolishRemovalProgress?.call(widget.nailIndex, _polishRemovalProgress);
      });
    }
  }
  
  void _endPolishRemoval() {
    setState(() {
      _swipePoints.clear();
      _lastSwipePosition = null;
    });
  }
  
  // Nail filing methods
  void _startNailFiling(Offset position) {
    setState(() {
      _filingStrokes.clear();
      _filingStrokes.add(position);
    });
  }
  
  void _updateNailFiling(Offset position, Size widgetSize) {
    if (_filingStrokes.isEmpty) return;
    
    final lastPosition = _filingStrokes.last;
    final distance = (position - lastPosition).distance;
    
    // Only process if moved enough distance
    if (distance > 5) {
      final direction = _getFilingDirection(lastPosition, position, widgetSize);
      _isValidFilingDirection = _isCorrectFilingDirection(direction);
      
      if (_isValidFilingDirection) {
        // Vibration feedback
        HapticFeedback.lightImpact();
        
        setState(() {
          _filingStrokes.add(position);
          if (_filingStrokes.length > 10) {
            _filingStrokes.removeAt(0);
          }
          
          // Increase filing progress
          _filingProgress = (_filingProgress + 0.03).clamp(0.0, 1.0);
          
          // Create dust particles
          if (_filingProgress < 1.0 && math.Random().nextDouble() > 0.4) {
            final random = math.Random();
            _dustParticles.add(FilingDustParticle(
              position: position,
              color: const Color(0xFFE8D5C4), // nail dust color
              velocityX: (random.nextDouble() - 0.5) * 30,
              velocityY: random.nextDouble() * -20 - 10,
              createdAt: DateTime.now().millisecondsSinceEpoch,
            ));
          }
          
          // Clean old particles
          final now = DateTime.now().millisecondsSinceEpoch;
          _dustParticles.removeWhere((p) => now - p.createdAt > 1000);
          
          // Notify progress
          widget.onNailFilingProgress?.call(widget.nailIndex, _filingProgress);
        });
      }
    }
  }
  
  void _endNailFiling() {
    setState(() {
      _filingStrokes.clear();
      _isValidFilingDirection = false;
    });
  }
  
  String _getFilingDirection(Offset start, Offset end, Size widgetSize) {
    final center = Offset(widgetSize.width / 2, widgetSize.height / 2);
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    
    // Determine if swipe is toward center
    if (start.dx < center.dx && dx > 0) {
      return 'left-to-center';
    } else if (start.dx > center.dx && dx < 0) {
      return 'right-to-center';
    } else if (start.dy < center.dy && dy > 0) {
      return 'top-to-center';
    } else if (start.dy > center.dy && dy < 0) {
      return 'bottom-to-center';
    }
    
    return 'invalid';
  }
  
  bool _isCorrectFilingDirection(String direction) {
    return direction != 'invalid';
  }
  
  bool _isWithinNailBounds(Offset tapPosition, Size widgetSize) {
    // Calculate nail bounds similar to NailPainter._getNailRect
    final center = Offset(widgetSize.width / 2, widgetSize.height / 2);
    final nailWidth = widgetSize.width * 0.8;
    final nailHeight = widgetSize.height * 0.8;
    
    final nailRect = Rect.fromCenter(
      center: center,
      width: nailWidth,
      height: nailHeight,
    );
    
    // Create path for nail shape to do precise hit testing
    final nailPath = _getNailPath(nailRect, _getNailShape(widget.nailIndex));
    return nailPath.contains(tapPosition);
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
  
  NailShape _getNailShape(int nailIndex) {
    // Different nail shapes for different fingers (realistic)
    switch (nailIndex) {
      case 0: return NailShape.square;  // Thumb - wider
      case 1: return NailShape.squoval; // Index
      case 2: return NailShape.oval;    // Middle - longest
      case 3: return NailShape.oval;    // Ring
      case 4: return NailShape.round;   // Pinky - smallest
      default: return NailShape.oval;
    }
  }
}

class SparkleEffectPainter extends CustomPainter {
  final double animation;
  final Color color;
  
  SparkleEffectPainter({
    required this.animation,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (animation <= 0) return;
    
    final paint = Paint()
      ..color = color.withOpacity(0.8 * (1 - animation))
      ..style = PaintingStyle.fill;
    
    final center = Offset(size.width / 2, size.height / 2);
    final sparkleSize = 8.0 * animation;
    
    // Draw sparkles at random positions around the center
    final sparklePositions = [
      Offset(center.dx - 15, center.dy - 10),
      Offset(center.dx + 12, center.dy - 8),
      Offset(center.dx - 8, center.dy + 15),
      Offset(center.dx + 10, center.dy + 12),
      Offset(center.dx, center.dy - 20),
      Offset(center.dx + 18, center.dy + 5),
    ];
    
    for (int i = 0; i < sparklePositions.length; i++) {
      final sparkle = sparklePositions[i];
      final adjustedSize = sparkleSize * (0.5 + 0.5 * math.sin(animation * 3.14 * (i + 1)));
      
      // Draw sparkle as a star
      _drawStar(canvas, sparkle, adjustedSize, paint);
    }
  }
  
  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    
    // Create a simple 4-pointed star
    path.moveTo(center.dx, center.dy - size);  // Top
    path.lineTo(center.dx + size * 0.3, center.dy - size * 0.3);
    path.lineTo(center.dx + size, center.dy);  // Right
    path.lineTo(center.dx + size * 0.3, center.dy + size * 0.3);
    path.lineTo(center.dx, center.dy + size);  // Bottom
    path.lineTo(center.dx - size * 0.3, center.dy + size * 0.3);
    path.lineTo(center.dx - size, center.dy);  // Left
    path.lineTo(center.dx - size * 0.3, center.dy - size * 0.3);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(SparkleEffectPainter oldDelegate) {
    return oldDelegate.animation != animation || oldDelegate.color != color;
  }
}

class PolishParticle {
  final Offset position;
  final Color color;
  final int createdAt;
  
  PolishParticle({
    required this.position,
    required this.color,
    required this.createdAt,
  });
}

class FilingDustParticle {
  final Offset position;
  final Color color;
  final double velocityX;
  final double velocityY;
  final int createdAt;
  
  FilingDustParticle({
    required this.position,
    required this.color,
    required this.velocityX,
    required this.velocityY,
    required this.createdAt,
  });
}