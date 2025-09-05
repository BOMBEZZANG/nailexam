import 'package:flutter/material.dart';
import '../../../data/models/nail_state.dart';
import '../../../data/models/tool.dart';
import 'nail_grid_display.dart';

// Temporary IsometricWorkArea widget
class IsometricWorkArea extends StatefulWidget {
  final Function(Offset)? onDragUpdate;
  final Function(dynamic, Offset)? onToolApplied;
  final Function(String, Offset)? onGesture;
  final dynamic currentTool;
  final Set<dynamic>? selectedTools;
  final Color? currentPolishColor;
  final bool isPracticeMode;
  final Function(Map<String, dynamic>)? onExamCompleted;
  final Function(int)? onStepChanged;

  const IsometricWorkArea({
    super.key,
    this.onDragUpdate,
    this.onToolApplied,
    this.onGesture,
    this.currentTool,
    this.selectedTools,
    this.currentPolishColor,
    required this.isPracticeMode,
    this.onExamCompleted,
    this.onStepChanged,
  });

  @override
  State<IsometricWorkArea> createState() => IsometricWorkAreaState();
}

class IsometricWorkAreaState extends State<IsometricWorkArea>
    with TickerProviderStateMixin {
  late AnimationController _rippleController;
  late Animation<double> _rippleAnimation;
  Offset? _lastTapPosition;
  
  // Nail states for 5 fingers
  late List<NailState> _nailStates;
  int? _selectedFingerIndex;
  
  // Tutorial system for practice mode
  int _currentStep = 1;
  Map<int, Set<int>> _stepProgress = {}; // step -> set of completed nail indices
  Map<int, double> _nailPolishRemovalProgress = {}; // nail index -> removal progress
  Map<int, Set<ToolType>> _stepRequiredTools = {
    1: {ToolType.handSanitizer}, // 손을(내손 -> 고객 손) 소독하세요
    2: {ToolType.remover, ToolType.cottonPad}, // 폴리쉬 제거(소지->약지)
    3: {ToolType.nailFile},      // 네일파일로 모양 만들기
    4: {ToolType.sandingBlock},  // 샌딩블록으로 표면 정리
    5: {ToolType.fingerBowl},    // 핑거볼에 손 담그기
    6: {ToolType.cuticleOil},    // 큐티클 오일 발라주기
    7: {ToolType.cuticlePusher}, // 큐티클 푸셔로 밀어올리기
    8: {ToolType.cuticleNipper}, // 니퍼로 큐티클 제거
    9: {ToolType.disinfectantSpray}, // 소독 스프레이 뿌리기
    10: {ToolType.cottonPad},  // 코튼패드로 오일 제거
    11: {ToolType.polishBrush},  // 컬러링 도포
  };
  
  Map<int, Set<int>> _stepTargetNails = {
    1: {0, 1, 2, 3, 4}, // 모든 손가락
    2: {0, 1, 2, 3, 4}, // 모든 손가락 - 전체 폴리쉬 제거
    3: {0, 1, 2, 3, 4}, // 모든 손가락
    4: {0, 1, 2, 3, 4}, // 모든 손가락
    5: {0, 1, 2, 3, 4}, // 모든 손가락
    6: {0, 1, 2, 3, 4}, // 모든 손가락
    7: {0, 1, 2, 3, 4}, // 모든 손가락
    8: {0, 1, 2, 3, 4}, // 모든 손가락
    9: {0, 1, 2, 3, 4}, // 모든 손가락
    10: {0, 1, 2, 3, 4}, // 모든 손가락
    11: {0, 1, 2, 3, 4}, // 모든 손가락
  };

  @override
  void initState() {
    super.initState();
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
    
    // Initialize nail states with red polish by default
    _nailStates = List.generate(5, (index) => NailState(
      fingerIndex: index,
      hasCuticle: true,
      hasPolish: true,  // Start with polish applied
      polishColor: Colors.red,
      polishCoverage: 1.0,  // Full coverage
      needsFiling: true,
      condition: NailCondition.clean,
    ));
    
    // Initialize step progress if in practice mode
    if (widget.isPracticeMode) {
      for (int step = 1; step <= 11; step++) {
        _stepProgress[step] = <int>{};
      }
    }
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  void _showRipple(Offset position) {
    setState(() {
      _lastTapPosition = position;
    });
    _rippleController.forward().then((_) {
      _rippleController.reset();
    });
  }

  void _onNailTapped(int nailIndex, Offset localPosition) {
    setState(() {
      _selectedFingerIndex = nailIndex;
    });
    
    // Apply current tool/color to selected nail
    if (widget.currentTool != null && nailIndex < _nailStates.length) {
      setState(() {
        _nailStates[nailIndex].applyTool(widget.currentTool);
      });
      
      // Tutorial step tracking for practice mode
      if (widget.isPracticeMode && widget.currentTool is Tool) {
        print('DEBUG: Tool applied - ${(widget.currentTool as Tool).name} on nail $nailIndex, current step: $_currentStep');
        _handleStepProgress(widget.currentTool as Tool, nailIndex);
      }
    }
    
    if (widget.currentPolishColor != null && nailIndex < _nailStates.length) {
      setState(() {
        _nailStates[nailIndex].hasPolish = true;
        _nailStates[nailIndex].polishColor = widget.currentPolishColor!;
        _nailStates[nailIndex].polishCoverage = 1.0;
      });
    }
    
    // Trigger haptic feedback and tool applied callback
    widget.onToolApplied?.call(widget.currentTool, localPosition);
  }
  
  void _handleStepProgress(Tool tool, int nailIndex) {
    print('DEBUG: _handleStepProgress called - tool: ${tool.type}, nail: $nailIndex, step: $_currentStep');
    print('DEBUG: Required tools for step $_currentStep: ${_stepRequiredTools[_currentStep]}');
    print('DEBUG: Target nails for step $_currentStep: ${_stepTargetNails[_currentStep]}');
    
    // Check if this nail is a target for the current step
    if (_stepTargetNails[_currentStep]?.contains(nailIndex) == true) {
      print('DEBUG: Nail $nailIndex is a target for step $_currentStep');
      
      // Special handling for step 2 (polish removal) - handled by swipe mechanic
      if (_currentStep == 2) {
        print('DEBUG: Step 2 - polish removal handled by swipe');
        // Step 2 progress is handled by _onPolishRemovalProgress
        return;
      } else {
        // For other steps, check if the current tool is one of the required tools
        if (_stepRequiredTools[_currentStep]?.contains(tool.type) == true) {
          print('DEBUG: Tool ${tool.type} is required for step $_currentStep - marking progress');
          setState(() {
            _stepProgress[_currentStep]?.add(nailIndex);
          });
          
          // Check if current step is completed
          if (_isStepCompleted(_currentStep)) {
            _advanceToNextStep();
          }
        } else {
          print('DEBUG: Tool ${tool.type} is NOT required for step $_currentStep');
        }
      }
    } else {
      print('DEBUG: Nail $nailIndex is NOT a target for step $_currentStep');
    }
  }
  
  void _onPolishRemovalProgress(int nailIndex, double progress) {
    if (_currentStep != 2) return;
    if (!_hasRequiredToolsForStep2()) return;
    if (_stepTargetNails[2]?.contains(nailIndex) != true) return;
    
    setState(() {
      _nailPolishRemovalProgress[nailIndex] = progress;
      
      // Update nail state when fully removed
      if (progress >= 1.0 && _nailStates[nailIndex].hasPolish) {
        _nailStates[nailIndex] = _nailStates[nailIndex].copyWith(
          hasPolish: false,
          polishCoverage: 0.0,
        );
        _stepProgress[_currentStep]?.add(nailIndex);
        
        // Check if current step is completed
        if (_isStepCompleted(_currentStep)) {
          _advanceToNextStep();
        }
      }
    });
  }
  
  bool _hasRequiredToolsForStep2() {
    // Check if both remover and cotton pad are selected
    if (widget.selectedTools == null) return false;
    
    bool hasRemover = false;
    bool hasCottonPad = false;
    
    for (var tool in widget.selectedTools!) {
      if (tool is Tool) {
        if (tool.type == ToolType.remover) hasRemover = true;
        if (tool.type == ToolType.cottonPad) hasCottonPad = true;
      }
    }
    
    return hasRemover && hasCottonPad;
  }
  
  bool _isStepCompleted(int step) {
    final targetNails = _stepTargetNails[step] ?? {};
    final completedNails = _stepProgress[step] ?? {};
    final isCompleted = targetNails.every((nailIndex) => completedNails.contains(nailIndex));
    print('DEBUG: Step $step completion check - target: $targetNails, completed: $completedNails, isCompleted: $isCompleted');
    return isCompleted;
  }
  
  void _advanceToNextStep() {
    if (_currentStep < 11) {
      print('DEBUG: Advancing from step $_currentStep to step ${_currentStep + 1}');
      setState(() {
        _currentStep++;
      });
      widget.onStepChanged?.call(_currentStep);
    }
  }
  
  int getCurrentStep() => _currentStep;
  
  Map<int, Set<int>> getStepProgress() => Map.from(_stepProgress);
  
  Set<ToolType>? getCurrentStepRequiredTools() => _stepRequiredTools[_currentStep];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[50],
      child: GestureDetector(
        onPanUpdate: (details) {
          widget.onDragUpdate?.call(details.localPosition);
        },
        onTapDown: (details) {
          _showRipple(details.localPosition);
          // Simulate tool application
          if (widget.currentTool != null) {
            widget.onToolApplied?.call(widget.currentTool, details.localPosition);
          }
        },
        child: Stack(
          children: [
            // Work surface background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF8F9FA),
                    Color(0xFFE9ECEF),
                  ],
                ),
              ),
            ),
            
            // Grid pattern overlay
            CustomPaint(
              painter: GridPatternPainter(),
              size: Size.infinite,
            ),
            
            // Real hand display with nails
            Center(
              child: Container(
                width: 300,
                height: 400,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: NailGridDisplay(
                    nailStates: _nailStates,
                    isPracticeMode: widget.isPracticeMode,
                    selectedNail: _selectedFingerIndex,
                    onNailTap: _onNailTapped,
                    isPolishRemovalMode: widget.isPracticeMode && _currentStep == 2,
                    onPolishRemovalProgress: _onPolishRemovalProgress,
                  ),
                ),
              ),
            ),
            
            // Touch feedback overlay with ripple
            if (_lastTapPosition != null)
              AnimatedBuilder(
                animation: _rippleAnimation,
                builder: (context, child) {
                  return Positioned(
                    left: _lastTapPosition!.dx - 30,
                    top: _lastTapPosition!.dy - 30,
                    child: IgnorePointer(
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).primaryColor.withOpacity(
                              (1.0 - _rippleAnimation.value) * 0.6,
                            ),
                            width: 2,
                          ),
                        ),
                        transform: Matrix4.identity()
                          ..scale(1.0 + _rippleAnimation.value * 2),
                      ),
                    ),
                  );
                },
              ),
            
            // Tool active indicator
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: widget.currentTool != null 
                        ? Theme.of(context).primaryColor.withOpacity(0.3)
                        : Colors.transparent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Grid pattern painter for the work surface
class GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..strokeWidth = 1;

    const gridSize = 20.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}