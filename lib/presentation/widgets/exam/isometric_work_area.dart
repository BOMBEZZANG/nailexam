import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
  Map<int, double> _nailFingerBowlProgress = {}; // nail index -> finger bowl progress
  Map<int, double> _nailCuticlePushProgress = {}; // nail index -> cuticle push progress
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
    _nailStates = List.generate(5, (index) {
      final nailState = NailState(
        fingerIndex: index,
        hasCuticle: true,
        hasPolish: true,  // Start with polish applied
        polishColor: Colors.red,
        polishCoverage: 1.0,  // Full coverage
        needsFiling: true,
        condition: NailCondition.clean,
      );
      print('💅 INITIALIZED NAIL $index with color: ${nailState.polishColor}');
      return nailState;
    });
    
    // Initialize step progress for all steps
    for (int step = 1; step <= 11; step++) {
      _stepProgress[step] = <int>{};
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
    debugPrint('👆 NAIL TAPPED:');
    debugPrint('👆 Nail index: $nailIndex');
    debugPrint('👆 Current step: $_currentStep');
    debugPrint('👆 Current tool: ${widget.currentTool is Tool ? (widget.currentTool as Tool).name : widget.currentTool}');
    debugPrint('👆 Current polish color: ${widget.currentPolishColor}');
    
    setState(() {
      _selectedFingerIndex = nailIndex;
    });
    
    // Apply current tool/color to selected nail
    if (widget.currentTool != null && nailIndex < _nailStates.length) {
      // For color application (step 11), let the gamified tapping system handle it
      bool isColorApplicationStep = (widget.isPracticeMode && _currentStep == 11) || 
                                   (!widget.isPracticeMode && widget.currentTool is Tool && 
                                    (widget.currentTool as Tool).type == ToolType.polishBrush);
      
      if (!isColorApplicationStep) {
        setState(() {
          // For polish brush tool, pass the selected color in additionalData
          if (widget.currentTool is Tool && (widget.currentTool as Tool).type == ToolType.polishBrush && widget.currentPolishColor != null) {
            _nailStates[nailIndex].applyTool(widget.currentTool, additionalData: {'color': widget.currentPolishColor});
          } else {
            _nailStates[nailIndex].applyTool(widget.currentTool);
          }
        });
      } else {
        debugPrint('🎮 COLOR APPLICATION STEP: Letting gamified system handle it');
      }
      
      // Step tracking for both practice and exam mode
      if (widget.currentTool is Tool) {
        print('DEBUG: Tool applied - ${(widget.currentTool as Tool).name} on nail $nailIndex, current step: $_currentStep');
        _handleStepProgress(widget.currentTool as Tool, nailIndex);
      }
    }
    
    // Color application is handled by the gamified tapping system in NailGridDisplay
    // Don't apply color directly here when in color application mode - let the gamified system handle it
    bool isColorApplicationStep = (widget.isPracticeMode && _currentStep == 11) || 
                                 (!widget.isPracticeMode && widget.currentTool is Tool && 
                                  (widget.currentTool as Tool).type == ToolType.polishBrush);
    
    if (!isColorApplicationStep && widget.currentPolishColor != null && nailIndex < _nailStates.length) {
      // Only set initial color for non-color-application steps
      if (!_nailStates[nailIndex].hasPolish || _nailStates[nailIndex].polishCoverage == 0.0) {
        print('DEBUG: Setting initial nail color in isometric work area - Color: ${widget.currentPolishColor}');
        setState(() {
          _nailStates[nailIndex].polishColor = widget.currentPolishColor!;
          // Don't set hasPolish or coverage here - let the progressive system handle it
        });
      }
    } else if (isColorApplicationStep) {
      print('DEBUG: Color application step - letting gamified system handle color completely');
    } else {
      print('DEBUG: No currentPolishColor available in isometric work area');
    }
    
    // Trigger haptic feedback and tool applied callback
    widget.onToolApplied?.call(widget.currentTool, localPosition);
  }
  
  void _handleStepProgress(Tool tool, int nailIndex) {
    print('DEBUG: _handleStepProgress called - tool: ${tool.type}, nail: $nailIndex, step: $_currentStep');
    print('DEBUG: Selected tools: ${widget.selectedTools?.map((t) => (t as Tool).type).toList()}');
    
    if (widget.isPracticeMode) {
      // Practice mode: only track progress for current step
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
      }
    } else {
      // Exam mode: track progress for any step that matches the tool
      for (int step = 1; step <= 11; step++) {
        if (_stepRequiredTools[step]?.contains(tool.type) == true &&
            _stepTargetNails[step]?.contains(nailIndex) == true) {
          // Special case: Skip step 2 (polish removal) as it's handled by swipe mechanics
          if (step == 2) {
            continue;
          }
          
          // For step 10, only track if we're using cotton pad for oil removal (not polish removal)
          if (step == 10 && tool.type == ToolType.cottonPad) {
            // Only count as step 10 if step 2 is already completed (polish removal done)
            if (!_isStepCompleted(2)) {
              continue;
            }
          }
          
          print('DEBUG: EXAM MODE - Tool ${tool.type} matches step $step for nail $nailIndex - marking progress');
          setState(() {
            _stepProgress[step] ??= {};
            _stepProgress[step]!.add(nailIndex);
          });
          
          print('DEBUG: EXAM MODE - Step $step progress: ${_stepProgress[step]}');
        }
      }
    }
  }
  
  void _onPolishRemovalProgress(int nailIndex, double progress) {
    print('DEBUG: Polish removal progress - nail: $nailIndex, progress: $progress, isPracticeMode: ${widget.isPracticeMode}');
    
    // In practice mode, only process if on step 2
    if (widget.isPracticeMode && _currentStep != 2) return;
    
    if (!_hasRequiredToolsForStep2()) {
      print('DEBUG: Polish removal - Required tools not selected');
      return;
    }
    
    if (_stepTargetNails[2]?.contains(nailIndex) != true) {
      print('DEBUG: Polish removal - Nail $nailIndex is not a target for step 2');
      return;
    }
    
    print('DEBUG: Polish removal progress processing for nail $nailIndex');
    
    setState(() {
      _nailPolishRemovalProgress[nailIndex] = progress;
      
      // Update nail state when fully removed
      if (progress >= 1.0 && _nailStates[nailIndex].hasPolish) {
        _nailStates[nailIndex] = _nailStates[nailIndex].copyWith(
          hasPolish: false,
          polishCoverage: 0.0,
        );
        
        // Track progress for step 2
        _stepProgress[2] ??= {};
        _stepProgress[2]!.add(nailIndex);
        
        // In practice mode, check if current step is completed and advance
        if (widget.isPracticeMode && _currentStep == 2 && _isStepCompleted(_currentStep)) {
          _advanceToNextStep();
        }
      }
    });
  }
  
  void _onNailFilingProgress(int nailIndex, double progress) {
    print('DEBUG: Filing progress for nail $nailIndex: $progress, current step: $_currentStep');
    // In practice mode, only process if on step 3
    if (widget.isPracticeMode && _currentStep != 3) return;
    if (_stepTargetNails[3]?.contains(nailIndex) != true) return;
    
    setState(() {
      // Update nail state when fully filed
      if (progress >= 1.0 && _nailStates[nailIndex].needsFiling) {
        print('DEBUG: Nail $nailIndex filing completed, marking as done');
        _nailStates[nailIndex] = _nailStates[nailIndex].copyWith(
          needsFiling: false,
        );
        
        // Track progress for step 3
        _stepProgress[3] ??= {};
        _stepProgress[3]!.add(nailIndex);
        
        print('DEBUG: Step 3 progress after filing: ${_stepProgress[3]}');
        
        // In practice mode, check if current step is completed and advance
        if (widget.isPracticeMode && _currentStep == 3 && _isStepCompleted(_currentStep)) {
          print('DEBUG: Step $_currentStep completed! Advancing to next step');
          _advanceToNextStep();
        } else if (widget.isPracticeMode) {
          print('DEBUG: Step $_currentStep not yet completed');
        }
      }
    });
  }
  
  void _onFingerBowlProgress(int nailIndex, double progress) {
    print('DEBUG: Finger bowl progress for nail $nailIndex: $progress, current step: $_currentStep');
    // In practice mode, only process if on step 5
    if (widget.isPracticeMode && _currentStep != 5) return;
    if (_stepTargetNails[5]?.contains(nailIndex) != true) return;
    
    setState(() {
      _nailFingerBowlProgress[nailIndex] = progress;
      
      // Update nail state when fully soaked (3 seconds)
      if (progress >= 1.0) {
        print('DEBUG: Nail $nailIndex finger bowl soaking completed, marking as done');
        
        // Track progress for step 5
        _stepProgress[5] ??= {};
        _stepProgress[5]!.add(nailIndex);
        
        print('DEBUG: Step 5 progress after soaking: ${_stepProgress[5]}');
        
        // In practice mode, check if current step is completed and advance
        if (widget.isPracticeMode && _currentStep == 5 && _isStepCompleted(_currentStep)) {
          print('DEBUG: Step $_currentStep completed! Advancing to next step');
          _advanceToNextStep();
        } else if (widget.isPracticeMode) {
          print('DEBUG: Step $_currentStep not yet completed');
        }
      }
    });
  }
  
  void _onCuticlePushProgress(int nailIndex, double progress) {
    print('DEBUG: Cuticle push progress for nail $nailIndex: $progress, current step: $_currentStep');
    // In practice mode, only process if on step 7
    if (widget.isPracticeMode && _currentStep != 7) return;
    if (_stepTargetNails[7]?.contains(nailIndex) != true) return;
    
    setState(() {
      _nailCuticlePushProgress[nailIndex] = progress;
      
      // Update nail state when fully pushed (upward swipes completed)
      if (progress >= 1.0) {
        print('DEBUG: Nail $nailIndex cuticle push completed, marking as done');
        
        // Track progress for step 7
        _stepProgress[7] ??= {};
        _stepProgress[7]!.add(nailIndex);
        
        print('DEBUG: Step 7 progress after cuticle push: ${_stepProgress[7]}');
        
        // In practice mode, check if current step is completed and advance
        if (widget.isPracticeMode && _currentStep == 7 && _isStepCompleted(_currentStep)) {
          print('DEBUG: Step $_currentStep completed! Advancing to next step');
          _advanceToNextStep();
        } else if (widget.isPracticeMode) {
          print('DEBUG: Step $_currentStep not yet completed');
        }
      }
    });
  }
  
  void _onCuticleTrimProgress(int nailIndex, double accuracy) {
    print('DEBUG: Cuticle trim progress for nail $nailIndex: accuracy $accuracy, current step: $_currentStep');
    // In practice mode, only process if on step 8
    if (widget.isPracticeMode && _currentStep != 8) return;
    if (_stepTargetNails[8]?.contains(nailIndex) != true) return;
    
    setState(() {
      // Mark nail as completed with accuracy score
      if (accuracy > 0.0) {
        print('DEBUG: Nail $nailIndex cuticle trimming completed with accuracy: $accuracy');
        
        // Track progress for step 8
        _stepProgress[8] ??= {};
        _stepProgress[8]!.add(nailIndex);
        
        print('DEBUG: Step 8 progress after cuticle trim: ${_stepProgress[8]}');
        
        // In practice mode, check if current step is completed and advance
        if (widget.isPracticeMode && _currentStep == 8 && _isStepCompleted(_currentStep)) {
          print('DEBUG: Step $_currentStep completed! Advancing to next step');
          _advanceToNextStep();
        } else if (widget.isPracticeMode) {
          print('DEBUG: Step $_currentStep not yet completed');
        }
      }
    });
  }
  
  void _onColorApplicationProgress(int nailIndex, double quality) {
    print('DEBUG: Color application progress for nail $nailIndex: quality $quality, current step: $_currentStep');
    // In practice mode, only process if on step 11
    if (widget.isPracticeMode && _currentStep != 11) return;
    if (_stepTargetNails[11]?.contains(nailIndex) != true) return;
    
    setState(() {
      // Mark nail as completed with quality score
      if (quality > 0.0) {
        print('DEBUG: Nail $nailIndex color application completed with quality: $quality');
        
        // Track progress for step 11
        _stepProgress[11] ??= {};
        _stepProgress[11]!.add(nailIndex);
        
        print('DEBUG: Step 11 progress after color application: ${_stepProgress[11]}');
        
        // In practice mode, check if current step is completed and advance
        if (widget.isPracticeMode && _currentStep == 11 && _isStepCompleted(_currentStep)) {
          print('DEBUG: Step $_currentStep completed! Advancing to next step');
          _advanceToNextStep();
        } else if (widget.isPracticeMode) {
          print('DEBUG: Step $_currentStep not yet completed');
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
  
  // Helper methods to determine when each mode should be active
  bool _isPolishRemovalActive() {
    if (widget.isPracticeMode) {
      return _currentStep == 2;
    } else {
      // In exam mode, activate when proper tools are selected
      return _hasRequiredToolsForStep2();
    }
  }
  
  bool _isNailFilingActive() {
    if (widget.isPracticeMode) {
      return _currentStep == 3;
    } else {
      // In exam mode, activate when nail file is selected
      return widget.currentTool is Tool && (widget.currentTool as Tool).type == ToolType.nailFile;
    }
  }
  
  bool _isFingerBowlActive() {
    if (widget.isPracticeMode) {
      return _currentStep == 5;
    } else {
      // In exam mode, activate when finger bowl is selected
      return widget.currentTool is Tool && (widget.currentTool as Tool).type == ToolType.fingerBowl;
    }
  }
  
  bool _isCuticlePushActive() {
    if (widget.isPracticeMode) {
      return _currentStep == 7;
    } else {
      // In exam mode, activate when cuticle pusher is selected
      return widget.currentTool is Tool && (widget.currentTool as Tool).type == ToolType.cuticlePusher;
    }
  }
  
  bool _isCuticleTrimActive() {
    if (widget.isPracticeMode) {
      return _currentStep == 8;
    } else {
      // In exam mode, activate when cuticle nipper is selected
      return widget.currentTool is Tool && (widget.currentTool as Tool).type == ToolType.cuticleNipper;
    }
  }
  
  bool _isColorApplicationActive() {
    if (widget.isPracticeMode) {
      return _currentStep == 11;
    } else {
      // In exam mode, activate when polish brush is selected
      return widget.currentTool is Tool && (widget.currentTool as Tool).type == ToolType.polishBrush;
    }
  }
  
  bool _isStepCompleted(int step) {
    final targetNails = _stepTargetNails[step] ?? {};
    final completedNails = _stepProgress[step] ?? {};
    final isCompleted = targetNails.every((nailIndex) => completedNails.contains(nailIndex));
    if (!widget.isPracticeMode) {
      print('DEBUG: EXAM MODE Step $step completion check - target: $targetNails, completed: $completedNails, isCompleted: $isCompleted');
    }
    return isCompleted;
  }
  
  void _advanceToNextStep() {
    if (_currentStep < 11) {
      print('DEBUG: Advancing from step $_currentStep to step ${_currentStep + 1}');
      setState(() {
        _currentStep++;
      });
      widget.onStepChanged?.call(_currentStep);
    } else if (_currentStep == 11 && !widget.isPracticeMode) {
      // In exam mode, automatically complete the exam when step 11 is finished
      completeExam();
    }
  }
  
  int getCurrentStep() => _currentStep;
  
  Map<int, Set<int>> getStepProgress() => Map.from(_stepProgress);
  
  Set<ToolType>? getCurrentStepRequiredTools() => _stepRequiredTools[_currentStep];
  
  // Get current score for live display
  int getCurrentScore() => _calculateExamScore();

  // Calculate exam score based on completed steps (1 point per completed step)
  int _calculateExamScore() {
    int score = 0;
    List<int> completedSteps = [];
    for (int step = 1; step <= 11; step++) {
      if (_isStepCompleted(step)) {
        score++;
        completedSteps.add(step);
      }
    }
    if (!widget.isPracticeMode && completedSteps.isNotEmpty) {
      print('DEBUG: Current score: $score/11, completed steps: $completedSteps');
    }
    return score;
  }

  // Get list of completed step names
  List<String> _getCompletedSteps() {
    List<String> completedSteps = [];
    final stepNames = [
      '손을(내손 -> 고객 손) 소독하세요',
      '폴리쉬 제거 (모든 손가락)',
      '네일파일로 모양 만들기',
      '샌딩블록으로 표면 정리',
      '핑거볼에 손 담그기',
      '큐티클 오일 발라주기',
      '큐티클 푸셔로 밀어올리기',
      '니퍼로 큐티클 제거',
      '소독 스프레이 뿌리기',
      '코튼패드로 오일 제거',
      '컬러링 도포',
    ];
    
    for (int step = 1; step <= 11; step++) {
      if (_isStepCompleted(step)) {
        completedSteps.add(stepNames[step - 1]);
      }
    }
    return completedSteps;
  }

  // Get list of missed step names
  List<String> _getMissedSteps() {
    List<String> missedSteps = [];
    final stepNames = [
      '손을(내손 -> 고객 손) 소독하세요',
      '폴리쉬 제거 (모든 손가락)',
      '네일파일로 모양 만들기',
      '샌딩블록으로 표면 정리',
      '핑거볼에 손 담그기',
      '큐티클 오일 발라주기',
      '큐티클 푸셔로 밀어올리기',
      '니퍼로 큐티클 제거',
      '소독 스프레이 뿌리기',
      '코튼패드로 오일 제거',
      '컬러링 도포',
    ];
    
    for (int step = 1; step <= 11; step++) {
      if (!_isStepCompleted(step)) {
        missedSteps.add(stepNames[step - 1]);
      }
    }
    return missedSteps;
  }

  // Check if exam is completed (called when user clicks complete button)
  void completeExam() {
    if (!widget.isPracticeMode && widget.onExamCompleted != null) {
      final score = _calculateExamScore();
      final completedSteps = _getCompletedSteps();
      final missedSteps = _getMissedSteps();
      
      widget.onExamCompleted!({
        'score': score,
        'completedSteps': completedSteps,
        'missedSteps': missedSteps,
      });
    }
  }

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
                  child: () {
                    // Debug logging for color passing
                    print('🖼️🖼️🖼️ CREATING NAIL GRID DISPLAY 🖼️🖼️🖼️');
                    print('🖼️ currentPolishColor: ${widget.currentPolishColor}');
                    print('🖼️ isPracticeMode: ${widget.isPracticeMode}');
                    print('🖼️ Color application mode active: ${_isColorApplicationActive()}');
                    print('🖼️ Current step: $_currentStep');
                    print('🖼️ Current tool: ${widget.currentTool}');
                    
                    if (widget.currentPolishColor != null) {
                      print('✅ Color is being passed to NailGridDisplay!');
                      print('✅ Color details: ${widget.currentPolishColor!.toString()}');
                    } else {
                      print('❌ NO COLOR being passed to NailGridDisplay!');
                    }
                    
                    return NailGridDisplay(
                      nailStates: _nailStates,
                      isPracticeMode: widget.isPracticeMode,
                      selectedNail: _selectedFingerIndex,
                      onNailTap: _onNailTapped,
                      isPolishRemovalMode: _isPolishRemovalActive(),
                      onPolishRemovalProgress: _onPolishRemovalProgress,
                      isNailFilingMode: _isNailFilingActive(),
                      onNailFilingProgress: _onNailFilingProgress,
                      isFingerBowlMode: _isFingerBowlActive(),
                      onFingerBowlProgress: _onFingerBowlProgress,
                      isCuticlePushMode: _isCuticlePushActive(),
                      onCuticlePushProgress: _onCuticlePushProgress,
                      isCuticleTrimMode: _isCuticleTrimActive(),
                      onCuticleTrimProgress: _onCuticleTrimProgress,
                      isColorApplicationMode: _isColorApplicationActive(),
                      onColorApplicationProgress: _onColorApplicationProgress,
                      currentTool: widget.currentTool,
                      currentPolishColor: widget.currentPolishColor,
                    );
                  }(),
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