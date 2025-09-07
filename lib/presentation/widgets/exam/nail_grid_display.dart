import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../../data/models/nail_state.dart';
import '../../../data/models/tool.dart';
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
  final Function(int nailIndex, double progress)? onFingerBowlProgress;
  final bool isFingerBowlMode;
  final Function(int nailIndex, double progress)? onCuticlePushProgress;
  final bool isCuticlePushMode;
  final Function(int nailIndex, double accuracy)? onCuticleTrimProgress;
  final bool isCuticleTrimMode;
  final Function(int nailIndex, double quality)? onColorApplicationProgress;
  final bool isColorApplicationMode;
  final dynamic currentTool;
  final Color? currentPolishColor;
  
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
    this.onFingerBowlProgress,
    this.isFingerBowlMode = false,
    this.onCuticlePushProgress,
    this.isCuticlePushMode = false,
    this.onCuticleTrimProgress,
    this.isCuticleTrimMode = false,
    this.onColorApplicationProgress,
    this.isColorApplicationMode = false,
    this.currentTool,
    this.currentPolishColor,
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
                  onFingerBowlProgress: onFingerBowlProgress,
                  isFingerBowlMode: isFingerBowlMode,
                  onCuticlePushProgress: onCuticlePushProgress,
                  isCuticlePushMode: isCuticlePushMode,
                  onCuticleTrimProgress: onCuticleTrimProgress,
                  isCuticleTrimMode: isCuticleTrimMode,
                  onColorApplicationProgress: onColorApplicationProgress,
                  isColorApplicationMode: isColorApplicationMode,
                  currentTool: currentTool,
                  currentPolishColor: currentPolishColor,
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
  final Function(int nailIndex, double progress)? onFingerBowlProgress;
  final bool isFingerBowlMode;
  final Function(int nailIndex, double progress)? onCuticlePushProgress;
  final bool isCuticlePushMode;
  final Function(int nailIndex, double accuracy)? onCuticleTrimProgress;
  final bool isCuticleTrimMode;
  final Function(int nailIndex, double quality)? onColorApplicationProgress;
  final bool isColorApplicationMode;
  final dynamic currentTool;
  final Color? currentPolishColor;
  
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
    this.onFingerBowlProgress,
    this.isFingerBowlMode = false,
    this.onCuticlePushProgress,
    this.isCuticlePushMode = false,
    this.onCuticleTrimProgress,
    this.isCuticleTrimMode = false,
    this.onColorApplicationProgress,
    this.isColorApplicationMode = false,
    this.currentTool,
    this.currentPolishColor,
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
  
  // Finger bowl mechanics
  double _fingerBowlProgress = 0.0;
  bool _isSoaking = false;
  Timer? _soakingTimer;
  List<BubbleParticle> _bubbleParticles = [];
  List<RippleEffect> _rippleEffects = [];
  
  // Cuticle push mechanics (tap-and-hold)
  double _cuticlePushProgress = 0.0;
  bool _isCuticlePushing = false;
  Timer? _cuticlePushTimer;
  double _cuticlePosition = 0.0; // 0.0 = original position, 1.0 = fully pushed back
  List<CuticleParticle> _cuticleParticles = [];
  
  // Cuticle trim mechanics (precision tapping)
  double _cuticleTrimProgress = 0.0;
  List<CuticleTrimPoint> _trimTargets = [];
  List<CuticleTrimPoint> _completedTrims = [];
  double _accuracyScore = 0.0;
  List<CutAnimationEffect> _cutEffects = [];
  
  // Color application mechanics (simple filling)
  double _colorApplicationProgress = 0.0;
  int _tapCount = 0;
  List<ShimmerEffect> _shimmerEffects = [];
  List<ConfettiParticle> _confettiParticles = [];

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
    
    // Initialize finger bowl progress
    _fingerBowlProgress = 0.0;
    
    // Initialize cuticle push progress
    _cuticlePushProgress = 0.0;
    _cuticlePosition = 0.0;
    
    // Initialize cuticle trim targets
    _initializeTrimTargets();
    
    // Initialize color application mechanics
    _initializeColorApplication();
  }
  
  @override
  void didUpdateWidget(SingleNailWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Reinitialize trim targets when entering cuticle trim mode
    if (widget.isCuticleTrimMode && !oldWidget.isCuticleTrimMode) {
      _initializeTrimTargets();
    }
    
    // Reinitialize color application when entering color application mode
    if (widget.isColorApplicationMode && !oldWidget.isColorApplicationMode) {
      _initializeColorApplication();
    }
  }
  
  @override
  void dispose() {
    _rippleController.dispose();
    _flashController.dispose();
    _particleController.dispose();
    _soakingTimer?.cancel();
    _cuticlePushTimer?.cancel();
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
          onTapDown: widget.isCuticleTrimMode ? (details) {
            if (_isWithinNailBounds(details.localPosition, constraints.biggest) && _hasCuticleNipperTool()) {
              _handleCuticleTrimTap(details.localPosition, constraints.biggest);
            }
          } : widget.isColorApplicationMode ? (details) {
            if (_isWithinNailBounds(details.localPosition, constraints.biggest) && _hasPolishBrushTool()) {
              _handleColorApplicationTap(details.localPosition, constraints.biggest);
            }
          } : (widget.isPolishRemovalMode || widget.isNailFilingMode || widget.isFingerBowlMode || widget.isCuticlePushMode) ? null : (details) {
            // Check if tap is within nail boundaries
            if (_isWithinNailBounds(details.localPosition, constraints.biggest)) {
              _triggerEffects(details.localPosition);
              widget.onTap?.call(details.localPosition);
            }
          },
          onLongPressStart: widget.isFingerBowlMode ? (details) {
            if (_isWithinNailBounds(details.localPosition, constraints.biggest)) {
              _startFingerBowlSoak(details.localPosition);
            }
          } : widget.isCuticlePushMode ? (details) {
            if (_isWithinNailBounds(details.localPosition, constraints.biggest) && _hasCuticlePusherTool()) {
              _startCuticlePushHold(details.localPosition);
            }
          } : null,
          onLongPressEnd: widget.isFingerBowlMode ? (details) {
            _endFingerBowlSoak();
          } : widget.isCuticlePushMode ? (details) {
            _endCuticlePushHold();
          } : null,
          onPanStart: widget.isPolishRemovalMode ? (details) {
            if (_isWithinNailBounds(details.localPosition, constraints.biggest)) {
              _startPolishRemoval(details.localPosition);
            }
          } : widget.isNailFilingMode ? (details) {
            if (_isWithinNailBounds(details.localPosition, constraints.biggest) && _hasNailFileTool()) {
              _startNailFiling(details.localPosition);
            }
          } : null,
          onPanUpdate: widget.isPolishRemovalMode ? (details) {
            if (_isWithinNailBounds(details.localPosition, constraints.biggest)) {
              _updatePolishRemoval(details.localPosition, constraints.biggest);
            }
          } : widget.isNailFilingMode ? (details) {
            if (_isWithinNailBounds(details.localPosition, constraints.biggest) && _hasNailFileTool()) {
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
                        polishOpacity: _calculatePolishOpacity(),
                        filingProgress: _filingProgress,
                        cuticlePosition: _cuticlePosition,
                        colorApplicationProgress: _colorApplicationProgress,
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
                  
                  // Water ripple effects for finger bowl
                  if (_rippleEffects.isNotEmpty)
                    ...List.generate(_rippleEffects.length, (index) {
                      final ripple = _rippleEffects[index];
                      return AnimatedBuilder(
                        animation: _particleController,
                        builder: (context, child) {
                          final progress = (DateTime.now().millisecondsSinceEpoch - ripple.createdAt) / 2000.0;
                          if (progress > 1.0) {
                            return const SizedBox.shrink();
                          }
                          
                          final radius = ripple.maxRadius * progress;
                          final opacity = (1.0 - progress) * 0.6;
                          
                          return Positioned(
                            left: ripple.position.dx - radius,
                            top: ripple.position.dy - radius,
                            child: Container(
                              width: radius * 2,
                              height: radius * 2,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.blue.withOpacity(opacity),
                                  width: 2,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  
                  // Bubble particles for finger bowl
                  if (_bubbleParticles.isNotEmpty)
                    ...List.generate(_bubbleParticles.length, (index) {
                      final bubble = _bubbleParticles[index];
                      return AnimatedBuilder(
                        animation: _particleController,
                        builder: (context, child) {
                          final progress = (DateTime.now().millisecondsSinceEpoch - bubble.createdAt) / 3000.0;
                          if (progress > 1.0) {
                            return const SizedBox.shrink();
                          }
                          
                          final opacity = (1.0 - progress) * 0.8;
                          final dy = bubble.position.dy + (bubble.velocityY * progress);
                          final wobble = math.sin(progress * 10) * 3;
                          
                          return Positioned(
                            left: bubble.position.dx - bubble.size / 2 + wobble,
                            top: dy - bubble.size / 2,
                            child: Container(
                              width: bubble.size,
                              height: bubble.size,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.lightBlue.withOpacity(opacity),
                                border: Border.all(
                                  color: Colors.white.withOpacity(opacity),
                                  width: 1,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  
                  // Finger bowl progress indicator (gauge bar)
                  if (widget.isFingerBowlMode && (_fingerBowlProgress > 0 || _isSoaking))
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 120,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              // Background gauge
                              Container(
                                width: double.infinity,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              // Progress fill with water effect
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 50),
                                width: 120 * _fingerBowlProgress,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.lightBlue.shade300,
                                      Colors.blue.shade400,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              // Water wave effect
                              if (_isSoaking)
                                AnimatedBuilder(
                                  animation: _particleController,
                                  builder: (context, child) {
                                    return Container(
                                      width: 120 * _fingerBowlProgress,
                                      height: double.infinity,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.lightBlue.withOpacity(0.3),
                                            Colors.transparent,
                                          ],
                                          stops: [
                                            0.5 + math.sin(_particleController.value * 2 * math.pi) * 0.2,
                                            1.0,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    );
                                  },
                                ),
                              // Timer text
                              Center(
                                child: Text(
                                  _isSoaking ? '담그는 중...' : '${(_fingerBowlProgress * 100).toInt()}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  
                  // Cuticle particles
                  if (_cuticleParticles.isNotEmpty)
                    ...List.generate(_cuticleParticles.length, (index) {
                      final particle = _cuticleParticles[index];
                      return AnimatedBuilder(
                        animation: _particleController,
                        builder: (context, child) {
                          final progress = (DateTime.now().millisecondsSinceEpoch - particle.createdAt) / 1000.0;
                          if (progress > 1.0) {
                            return const SizedBox.shrink();
                          }
                          
                          final opacity = (1.0 - progress) * 0.8;
                          final dx = particle.position.dx + (particle.velocityX * progress);
                          final dy = particle.position.dy + (particle.velocityY * progress);
                          
                          return Positioned(
                            left: dx - 3,
                            top: dy - 3,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: particle.color.withOpacity(opacity),
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  
                  // Cuticle push progress indicator
                  if (widget.isCuticlePushMode && _cuticlePushProgress > 0)
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: _cuticlePushProgress >= 1.0 
                                ? Colors.green.withOpacity(0.9) 
                                : Colors.orange.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _cuticlePushProgress >= 1.0 
                                    ? Icons.check_circle 
                                    : Icons.arrow_upward,
                                color: Colors.white,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _cuticlePushProgress >= 1.0 
                                    ? '완료!' 
                                    : '${(_cuticlePushProgress * 100).toInt()}%',
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
                  
                  // Cuticle trim targets overlay
                  if (widget.isCuticleTrimMode) ...[
                    // Force initialization if targets are empty
                    ...() {
                      if (_trimTargets.isEmpty) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _initializeTrimTargets();
                        });
                      }
                      return _buildCuticleTrimTargets(constraints.biggest);
                    }(),
                  ],
                  
                  // Cut animation effects
                  if (_cutEffects.isNotEmpty)
                    ...List.generate(_cutEffects.length, (index) {
                      final effect = _cutEffects[index];
                      return AnimatedBuilder(
                        animation: _particleController,
                        builder: (context, child) {
                          final progress = (DateTime.now().millisecondsSinceEpoch - effect.createdAt) / 800.0;
                          if (progress > 1.0) {
                            return const SizedBox.shrink();
                          }
                          
                          final scale = 1.0 + (progress * 0.5);
                          final opacity = (1.0 - progress) * 0.9;
                          
                          return Positioned(
                            left: effect.position.dx - 15,
                            top: effect.position.dy - 15,
                            child: Transform.scale(
                              scale: scale,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.green.withOpacity(opacity * 0.3),
                                  border: Border.all(
                                    color: Colors.green.withOpacity(opacity),
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.content_cut,
                                  size: 12,
                                  color: Colors.white.withOpacity(opacity),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  
                  // Cuticle trim progress and accuracy display
                  if (widget.isCuticleTrimMode && _cuticleTrimProgress > 0)
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.content_cut,
                                color: Colors.white,
                                size: 10,
                              ),
                              const SizedBox(width: 2),
                              Flexible(
                                child: Text(
                                  '${(_cuticleTrimProgress * 100).toInt()}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  
                  // Color application progress display
                  if (widget.isColorApplicationMode && _colorApplicationProgress > 0)
                    Positioned(
                      top: 8,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${(_colorApplicationProgress * 100).toInt()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  
                  // Shimmer effects for polish shine
                  if (_shimmerEffects.isNotEmpty)
                    ...List.generate(_shimmerEffects.length, (index) {
                      final effect = _shimmerEffects[index];
                      return AnimatedBuilder(
                        animation: _particleController,
                        builder: (context, child) {
                          final progress = (DateTime.now().millisecondsSinceEpoch - effect.createdAt) / 2000.0;
                          if (progress > 1.0) {
                            return const SizedBox.shrink();
                          }
                          
                          final shimmerProgress = (progress * 2.0).clamp(0.0, 1.0);
                          final opacity = math.sin(shimmerProgress * math.pi) * 0.8;
                          
                          return Positioned(
                            left: effect.position.dx - effect.width / 2,
                            top: effect.position.dy - effect.height / 2,
                            child: Container(
                              width: effect.width,
                              height: effect.height,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0),
                                    Colors.white.withOpacity(opacity),
                                    Colors.white.withOpacity(0),
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                ),
                                borderRadius: BorderRadius.circular(effect.height / 2),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  
                  // Confetti particles for completion celebration
                  if (_confettiParticles.isNotEmpty)
                    ...List.generate(_confettiParticles.length, (index) {
                      final particle = _confettiParticles[index];
                      return AnimatedBuilder(
                        animation: _particleController,
                        builder: (context, child) {
                          final progress = (DateTime.now().millisecondsSinceEpoch - particle.createdAt) / 3000.0;
                          if (progress > 1.0) {
                            return const SizedBox.shrink();
                          }
                          
                          final x = particle.position.dx + (particle.velocityX * progress);
                          final y = particle.position.dy + (particle.velocityY * progress) + (0.5 * 981 * progress * progress); // Gravity
                          final rotation = particle.rotation + (particle.angularVelocity * progress);
                          
                          return Positioned(
                            left: x - particle.size / 2,
                            top: y - particle.size / 2,
                            child: Transform.rotate(
                              angle: rotation,
                              child: Container(
                                width: particle.size,
                                height: particle.size,
                                decoration: BoxDecoration(
                                  color: particle.color.withOpacity((1.0 - progress) * 0.9),
                                  shape: particle.shape == ParticleShape.circle ? BoxShape.circle : BoxShape.rectangle,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  
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
  
  // Finger bowl soaking methods
  void _startFingerBowlSoak(Offset position) {
    if (_fingerBowlProgress >= 1.0) return;
    
    setState(() {
      _isSoaking = true;
      _fingerBowlProgress = 0.0;
    });
    
    // Create initial ripple effect
    _createRippleEffect(position);
    
    // Start 3-second timer with 60fps updates
    _soakingTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        _fingerBowlProgress = (_fingerBowlProgress + 0.0167).clamp(0.0, 1.0); // 3 seconds = 60 updates
        
        // Create bubbles randomly
        if (math.Random().nextDouble() > 0.7) {
          _createBubbleParticle(position);
        }
        
        // Create ripple effects occasionally
        if (math.Random().nextDouble() > 0.85) {
          _createRippleEffect(position);
        }
        
        // Clean up old particles
        final now = DateTime.now().millisecondsSinceEpoch;
        _bubbleParticles.removeWhere((bubble) => now - bubble.createdAt > 3000);
        _rippleEffects.removeWhere((ripple) => now - ripple.createdAt > 2000);
        
        // Complete soaking after 3 seconds
        if (_fingerBowlProgress >= 1.0) {
          timer.cancel();
          _isSoaking = false;
          HapticFeedback.mediumImpact();
          widget.onFingerBowlProgress?.call(widget.nailIndex, _fingerBowlProgress);
        }
      });
    });
  }
  
  void _endFingerBowlSoak() {
    _soakingTimer?.cancel();
    setState(() {
      _isSoaking = false;
      // Don't reset progress - allow resuming
    });
  }
  
  void _createBubbleParticle(Offset basePosition) {
    final random = math.Random();
    final position = Offset(
      basePosition.dx + (random.nextDouble() - 0.5) * 60,
      basePosition.dy + (random.nextDouble() - 0.5) * 60,
    );
    
    _bubbleParticles.add(BubbleParticle(
      position: position,
      size: random.nextDouble() * 8 + 4,
      velocityY: -random.nextDouble() * 30 - 10,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    ));
  }
  
  void _createRippleEffect(Offset position) {
    _rippleEffects.add(RippleEffect(
      position: position,
      maxRadius: 40.0 + math.Random().nextDouble() * 20,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    ));
  }
  
  bool _hasNailFileTool() {
    if (widget.currentTool == null) return false;
    
    // Import the Tool class to check the type
    if (widget.currentTool is Tool) {
      final tool = widget.currentTool as Tool;
      return tool.type == ToolType.nailFile;
    }
    
    return false;
  }
  
  bool _hasCuticlePusherTool() {
    if (widget.currentTool == null) return false;
    
    if (widget.currentTool is Tool) {
      final tool = widget.currentTool as Tool;
      return tool.type == ToolType.cuticlePusher;
    }
    
    return false;
  }
  
  // Cuticle push methods (tap-and-hold)
  void _startCuticlePushHold(Offset position) {
    if (_cuticlePushProgress >= 1.0) return;
    
    setState(() {
      _isCuticlePushing = true;
    });
    
    // Immediate haptic feedback
    HapticFeedback.lightImpact();
    
    // Start timer with smooth progress updates (60fps)
    _cuticlePushTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        // Increase progress - takes about 2 seconds to complete
        _cuticlePushProgress = (_cuticlePushProgress + 0.025).clamp(0.0, 1.0);
        _cuticlePosition = _cuticlePushProgress; // Update visual position
        
        // Create cuticle particles while pushing
        if (_cuticlePushProgress < 1.0 && math.Random().nextDouble() > 0.7) {
          final random = math.Random();
          _cuticleParticles.add(CuticleParticle(
            position: position + Offset(
              (random.nextDouble() - 0.5) * 30,
              (random.nextDouble() - 0.5) * 20,
            ),
            color: const Color(0xFFE8A598), // cuticle color
            velocityX: (random.nextDouble() - 0.5) * 15,
            velocityY: -random.nextDouble() * 20 - 10,
            createdAt: DateTime.now().millisecondsSinceEpoch,
          ));
        }
        
        // Clean old particles
        final now = DateTime.now().millisecondsSinceEpoch;
        _cuticleParticles.removeWhere((p) => now - p.createdAt > 1000);
        
        // Complete when progress reaches 100%
        if (_cuticlePushProgress >= 1.0) {
          timer.cancel();
          _isCuticlePushing = false;
          HapticFeedback.mediumImpact(); // Success feedback
          widget.onCuticlePushProgress?.call(widget.nailIndex, _cuticlePushProgress);
        }
      });
    });
  }
  
  void _endCuticlePushHold() {
    _cuticlePushTimer?.cancel();
    setState(() {
      _isCuticlePushing = false;
      // Don't reset progress - allow resuming
    });
  }
  
  // Cuticle trimming methods
  void _initializeTrimTargets() {
    if (!widget.isCuticleTrimMode) return;
    
    print('DEBUG: Initializing cuticle trim targets for nail ${widget.nailIndex}');
    
    setState(() {
      _trimTargets.clear();
      _completedTrims.clear();
      _cuticleTrimProgress = 0.0;
      _accuracyScore = 0.0;
      
      // Generate cuticle trim target points around nail perimeter
      // Use nail index as seed to ensure different positions for each nail
      final random = math.Random(widget.nailIndex * 123 + DateTime.now().millisecondsSinceEpoch ~/ 10000);
      
      // Create 4-6 precision trim targets positioned around cuticle area
      final numTargets = 4 + random.nextInt(3);
      print('DEBUG: Creating $numTargets trim targets');
      
      for (int i = 0; i < numTargets; i++) {
        // Position targets in the cuticle area - we'll use dynamic sizing in build method
        // For now, store relative positions that will be calculated properly in _buildCuticleTrimTargets
        
        // Create targets in a small arc pattern (will be positioned correctly in build)
        final angle = (i * math.pi * 0.5 / (numTargets - 1)) - math.pi * 0.25; // Narrow arc
        final randomOffset = (random.nextDouble() - 0.5) * 0.05;
        final adjustedAngle = angle + randomOffset;
        
        // Store relative positions (0.0 to 1.0) that will be converted to actual positions
        final relativeX = 0.5 + 0.25 * math.cos(adjustedAngle); // Center ± 25%
        final relativeY = 0.75 + 0.1 * math.sin(adjustedAngle.abs()); // 75% down the nail
        
        final targetRadius = 6.0 + random.nextDouble() * 3.0;
        
        _trimTargets.add(CuticleTrimPoint(
          position: Offset(relativeX, relativeY), // Store relative positions
          accuracy: 1.0,
          isCompleted: false,
          targetRadius: targetRadius,
        ));
        
        print('DEBUG: Created trim target $i at relative position ($relativeX, $relativeY) with radius $targetRadius');
      }
    });
  }
  
  void _handleCuticleTrimTap(Offset tapPosition, Size widgetSize) {
    if (!_hasCuticleNipperTool()) return;
    
    print('DEBUG: Cuticle trim tap at (${tapPosition.dx}, ${tapPosition.dy}) on nail ${widget.nailIndex}');
    print('DEBUG: Available targets: ${_trimTargets.length}');
    
    // Calculate the actual nail bounds to convert relative positions
    final center = Offset(widgetSize.width / 2, widgetSize.height / 2);
    final nailWidth = widgetSize.width * 0.8;
    final nailHeight = widgetSize.height * 0.8;
    
    final nailRect = Rect.fromCenter(
      center: center,
      width: nailWidth,
      height: nailHeight,
    );
    
    // Find the closest target within acceptable range
    CuticleTrimPoint? closestTarget;
    double closestDistance = double.infinity;
    int targetIndex = -1;
    
    for (int i = 0; i < _trimTargets.length; i++) {
      final target = _trimTargets[i];
      if (target.isCompleted) continue;
      
      // Convert relative position to actual position
      final actualX = nailRect.left + (target.position.dx * nailRect.width);
      final actualY = nailRect.top + (target.position.dy * nailRect.height);
      final actualPosition = Offset(actualX, actualY);
      
      final distance = (tapPosition - actualPosition).distance;
      if (distance < target.targetRadius && distance < closestDistance) {
        closestDistance = distance;
        closestTarget = target;
        targetIndex = i;
      }
    }
    
    if (closestTarget != null) {
      // Calculate accuracy based on distance from center
      final accuracy = (1.0 - (closestDistance / closestTarget!.targetRadius)).clamp(0.0, 1.0);
      
      setState(() {
        // Mark target as completed
        _trimTargets[targetIndex] = CuticleTrimPoint(
          position: closestTarget!.position,
          accuracy: accuracy,
          isCompleted: true,
          targetRadius: closestTarget!.targetRadius,
        );
        _completedTrims.add(_trimTargets[targetIndex]);
        
        // Update progress
        _cuticleTrimProgress = _completedTrims.length / _trimTargets.length;
        
        // Update accuracy score (average of all completed trims)
        _accuracyScore = _completedTrims.fold<double>(0.0, (sum, trim) => sum + trim.accuracy) / _completedTrims.length;
        
        // Add cutting animation effect
        _cutEffects.add(CutAnimationEffect(
          position: tapPosition,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ));
      });
      
      // Provide haptic feedback based on accuracy
      if (accuracy > 0.8) {
        HapticFeedback.mediumImpact(); // Great cut
      } else if (accuracy > 0.5) {
        HapticFeedback.lightImpact(); // Good cut
      } else {
        HapticFeedback.selectionClick(); // Poor cut
      }
      
      // Check if step is completed
      if (_cuticleTrimProgress >= 1.0) {
        widget.onCuticleTrimProgress?.call(widget.nailIndex, _accuracyScore);
      }
    }
  }
  
  bool _hasCuticleNipperTool() {
    return widget.currentTool != null && 
           widget.currentTool is Tool && 
           (widget.currentTool as Tool).type == ToolType.cuticleNipper;
  }
  
  Rect _getCuticleAreaRect() {
    // Get the area around the cuticle for trim targets - match NailPainter sizing
    final widgetSize = Size(150, 150);
    final center = Offset(widgetSize.width / 2, widgetSize.height / 2);
    final nailWidth = widgetSize.width * 0.6;
    final nailHeight = widgetSize.height * 0.6;
    
    return Rect.fromCenter(
      center: center,
      width: nailWidth,
      height: nailHeight,
    );
  }
  
  List<Widget> _buildCuticleTrimTargets(Size widgetSize) {
    print('DEBUG: Building ${_trimTargets.length} cuticle trim targets for nail ${widget.nailIndex} with widget size: $widgetSize');
    
    // Calculate the actual nail bounds using NailPainter's logic
    final center = Offset(widgetSize.width / 2, widgetSize.height / 2);
    final nailWidth = widgetSize.width * 0.8; // Match NailPainter
    final nailHeight = widgetSize.height * 0.8; // Match NailPainter
    
    final nailRect = Rect.fromCenter(
      center: center,
      width: nailWidth,
      height: nailHeight,
    );
    
    print('DEBUG: Nail bounds: ${nailRect.toString()}');
    
    return _trimTargets.asMap().entries.map((entry) {
      final index = entry.key;
      final target = entry.value;
      
      if (target.isCompleted) {
        print('DEBUG: Target $index completed, hiding');
        return const SizedBox.shrink();
      }
      
      // Convert relative position (0.0-1.0) to actual position within nail bounds
      final actualX = nailRect.left + (target.position.dx * nailRect.width);
      final actualY = nailRect.top + (target.position.dy * nailRect.height);
      
      print('DEBUG: Target $index - relative pos: (${target.position.dx}, ${target.position.dy}) -> actual pos: ($actualX, $actualY)');
      
      return Positioned(
        left: actualX - target.targetRadius / 2,
        top: actualY - target.targetRadius / 2,
        child: AnimatedBuilder(
          animation: _particleController,
          builder: (context, child) {
            // Pulsing animation for targets - more visible
            final pulseScale = 1.0 + math.sin(_particleController.value * 4 * math.pi) * 0.2;
            
            return Transform.scale(
              scale: pulseScale,
              child: Container(
                width: target.targetRadius,
                height: target.targetRadius,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.withOpacity(0.3),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.9),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }).toList();
  }
  
  // Color application methods
  void _initializeColorApplication() {
    if (!widget.isColorApplicationMode) return;
    
    debugPrint('🎯 INITIALIZING COLOR APPLICATION:');
    debugPrint('🎯 Nail: ${widget.nailIndex}');
    debugPrint('🎯 Mode: ${widget.isPracticeMode ? "Practice" : "Exam"}');
    debugPrint('🎯 Selected color: ${widget.currentPolishColor}');
    debugPrint('🎯 Fallback color: ${Colors.red}');
    
    setState(() {
      _colorApplicationProgress = 0.0;
      _tapCount = 0;
      
      // Reset nail to have no polish for color application step
      widget.nailState.hasPolish = false;
      widget.nailState.polishCoverage = 0.0;
      widget.nailState.polishColor = widget.currentPolishColor ?? Colors.red;
    });
  }
  
  void _handleColorApplicationTap(Offset tapPosition, Size widgetSize) {
    if (_tapCount >= 5) return; // Already completed
    
    // SUPER DETAILED COLOR DEBUG
    print('🔍🔍🔍 COLOR APPLICATION TAP DEBUG 🔍🔍🔍');
    print('Current widget.currentPolishColor: ${widget.currentPolishColor}');
    print('Current nail state polish color BEFORE: ${widget.nailState.polishColor}');
    print('Practice mode: ${widget.isPracticeMode}');
    print('Tap count BEFORE: $_tapCount');
    
    setState(() {
      _tapCount++;
      _colorApplicationProgress = _tapCount / 5.0; // 20%, 40%, 60%, 80%, 100%
      
      // Apply polish using the NailState's applyPolish method
      if (widget.currentPolishColor != null) {
        print('✅ COLOR EXISTS: Applying ${widget.currentPolishColor}');
        // Apply 20% polish coverage (0.2) on each tap
        widget.nailState.applyPolish(widget.currentPolishColor!, 0.2);
        // Ensure hasPolish is true when we have coverage
        if (widget.nailState.polishCoverage > 0) {
          widget.nailState.hasPolish = true;
        }
        print('✅ AFTER APPLYING:');
        print('  Final nail color: ${widget.nailState.polishColor}');
        print('  Coverage: ${widget.nailState.polishCoverage}');
        print('  HasPolish: ${widget.nailState.hasPolish}');
      } else {
        print('❌ NO COLOR: widget.currentPolishColor is NULL!');
        print('❌ This means the color was not passed to the nail widget correctly');
      }
    });
    
    // Add shimmer effect at tap position
    _addShimmerEffect(tapPosition, widgetSize);
    
    // Provide haptic feedback
    HapticFeedback.lightImpact();
    
    print('DEBUG: Color application tap ${_tapCount}/5 (${(_colorApplicationProgress * 100).toInt()}%)');
    
    // Check if completed (5 taps = 100%)
    if (_colorApplicationProgress >= 1.0) {
      // Trigger celebration and complete step
      _triggerCompletionCelebration();
      widget.onColorApplicationProgress?.call(widget.nailIndex, 1.0); // Perfect quality for simple tapping
      print('DEBUG: Color application completed! Final nail state - hasPolish: ${widget.nailState.hasPolish}, coverage: ${widget.nailState.polishCoverage}, color: ${widget.nailState.polishColor}');
    }
  }
  
  
  void _addShimmerEffect(Offset position, Size widgetSize) {
    setState(() {
      _shimmerEffects.add(ShimmerEffect(
        position: position,
        width: 40.0,
        height: 8.0,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ));
    });
  }
  
  void _triggerCompletionCelebration() {
    final random = math.Random();
    
    setState(() {
      // Create confetti particles
      for (int i = 0; i < 20; i++) {
        _confettiParticles.add(ConfettiParticle(
          position: Offset(
            75 + (random.nextDouble() - 0.5) * 50,
            75 + (random.nextDouble() - 0.5) * 50,
          ),
          velocityX: (random.nextDouble() - 0.5) * 200,
          velocityY: -random.nextDouble() * 300 - 100,
          color: [Colors.pink, Colors.purple, Colors.blue, Colors.green, Colors.yellow][random.nextInt(5)],
          size: 4 + random.nextDouble() * 4,
          rotation: random.nextDouble() * 2 * math.pi,
          angularVelocity: (random.nextDouble() - 0.5) * 6,
          shape: random.nextBool() ? ParticleShape.circle : ParticleShape.square,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ));
      }
    });
    
    HapticFeedback.heavyImpact();
    print('DEBUG: Triggered completion celebration!');
  }
  
  bool _hasPolishBrushTool() {
    return widget.currentTool != null && 
           widget.currentTool is Tool && 
           (widget.currentTool as Tool).type == ToolType.polishBrush;
  }
  
  double _calculatePolishOpacity() {
    // During polish removal, fade out the existing polish
    if (widget.isPolishRemovalMode && _polishRemovalProgress > 0) {
      return widget.nailState.hasPolish ? 1.0 - _polishRemovalProgress : 0.0;
    }
    
    // During color application, show polish based on application progress
    if (widget.isColorApplicationMode && _colorApplicationProgress > 0) {
      print('DEBUG: Color application mode active - progress: $_colorApplicationProgress, opacity: $_colorApplicationProgress');
      return _colorApplicationProgress; // 0.0 to 1.0 based on tap count
    }
    
    // For all other cases, show polish if it exists
    return widget.nailState.hasPolish ? 1.0 : 0.0;
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
    // All nails start as squoval (rounded square) for better visual transformation
    return NailShape.squoval;
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
    
    final opacity = (0.8 * (1 - animation)).clamp(0.0, 1.0);
    final paint = Paint()
      ..color = color.withOpacity(opacity)
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

class BubbleParticle {
  final Offset position;
  final double size;
  final double velocityY;
  final int createdAt;
  
  BubbleParticle({
    required this.position,
    required this.size,
    required this.velocityY,
    required this.createdAt,
  });
}

class RippleEffect {
  final Offset position;
  final double maxRadius;
  final int createdAt;
  
  RippleEffect({
    required this.position,
    required this.maxRadius,
    required this.createdAt,
  });
}

class CuticleParticle {
  final Offset position;
  final Color color;
  final double velocityX;
  final double velocityY;
  final int createdAt;
  
  CuticleParticle({
    required this.position,
    required this.color,
    required this.velocityX,
    required this.velocityY,
    required this.createdAt,
  });
}

class CuticleTrimPoint {
  final Offset position;
  final double accuracy;
  final bool isCompleted;
  final double targetRadius;
  
  CuticleTrimPoint({
    required this.position,
    required this.accuracy,
    required this.isCompleted,
    required this.targetRadius,
  });
}

class CutAnimationEffect {
  final Offset position;
  final int createdAt;
  
  CutAnimationEffect({
    required this.position,
    required this.createdAt,
  });
}


class ShimmerEffect {
  final Offset position;
  final double width;
  final double height;
  final int createdAt;
  
  ShimmerEffect({
    required this.position,
    required this.width,
    required this.height,
    required this.createdAt,
  });
}

enum ParticleShape { circle, square }

class ConfettiParticle {
  final Offset position;
  final double velocityX;
  final double velocityY;
  final Color color;
  final double size;
  final double rotation;
  final double angularVelocity;
  final ParticleShape shape;
  final int createdAt;
  
  ConfettiParticle({
    required this.position,
    required this.velocityX,
    required this.velocityY,
    required this.color,
    required this.size,
    required this.rotation,
    required this.angularVelocity,
    required this.shape,
    required this.createdAt,
  });
}

