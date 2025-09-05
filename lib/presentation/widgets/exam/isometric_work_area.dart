import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../controllers/gesture_controller.dart';
import '../../../data/models/nail_state.dart';
import '../../../data/models/tool.dart';
import '../../../data/models/exam_progress.dart';
import '../../../core/utils/id_generator.dart';
import 'isometric_painter.dart';

class IsometricWorkArea extends StatefulWidget {
  final Function(Offset) onDragUpdate;
  final Function(Tool) onToolApplied;
  final Function(GestureType, Offset) onGesture;
  final Tool? currentTool;
  final Set<Tool>? selectedTools;
  final Color? currentPolishColor;
  final bool isPracticeMode;
  final Function(
    int score,
    List<String> completedSteps,
    List<String> missedSteps,
  )?
  onExamCompleted;

  const IsometricWorkArea({
    super.key,
    required this.onDragUpdate,
    required this.onToolApplied,
    required this.onGesture,
    this.currentTool,
    this.selectedTools,
    this.currentPolishColor,
    this.isPracticeMode = true,
    this.onExamCompleted,
  });

  @override
  State<IsometricWorkArea> createState() => IsometricWorkAreaState();
}

class IsometricWorkAreaState extends State<IsometricWorkArea>
    with TickerProviderStateMixin {
  // Isometric transformation matrix (30° rotation)
  final Matrix4 isometricTransform = Matrix4.identity()
    ..setEntry(3, 2, 0.001) // perspective
    ..rotateX(-0.5236) // ~30 degrees in radians
    ..rotateZ(0.7854); // 45 degrees in radians

  // Nail states for each finger (10 nails)
  late List<NailState> nailStates;

  // Gesture tracking
  Offset? _lastDragPosition;
  double _currentScale = 1.0;
  late GestureController _gestureController;
  final List<Offset> _dragPath = [];

  // Animation
  late AnimationController _highlightController;
  late Animation<double> _highlightAnimation;
  int? _highlightedNail;

  // Info toggle highlight animation
  late AnimationController _infoToggleController;
  late Animation<double> _infoToggleAnimation;

  // Instruction system
  String _currentInstruction = "1. 손을(내손 -> 고객 손) 소독하세요";
  bool _showInstruction = false;

  // Get required tools for current step
  Set<ToolType> getRequiredToolsForCurrentStep() {
    if (!_handSanitizerStepCompleted) {
      return {ToolType.handSanitizer};
    } else if (!_polishRemovalStepCompleted) {
      return {ToolType.remover, ToolType.cottonPad};
    } else if (!_nailFilingStepCompleted) {
      return {ToolType.nailFile};
    } else if (!_sandingStepCompleted) {
      return {ToolType.sandingBlock};
    } else if (!_fingerBowlStepCompleted) {
      return {ToolType.fingerBowl};
    } else if (!_cuticleOilStepCompleted) {
      return {ToolType.cuticleOil};
    } else if (!_cuticlePusherStepCompleted) {
      return {ToolType.cuticlePusher};
    } else if (!_cuticleNipperStepCompleted) {
      return {ToolType.cuticleNipper};
    } else if (!_disinfectantSprayStepCompleted) {
      return {ToolType.disinfectantSpray};
    } else if (!_sterilizedGauzeStepCompleted) {
      return {ToolType.sterilizedGauze};
    } else if (!_polishBrushStepCompleted) {
      return {ToolType.polishBrush};
    }
    return {};
  }

  int getCurrentScore() {
    int score = 0;
    if (_handSanitizerStepCompleted) score++;
    if (_polishRemovalStepCompleted) score++;
    if (_nailFilingStepCompleted) score++;
    if (_sandingStepCompleted) score++;
    if (_fingerBowlStepCompleted) score++;
    if (_cuticleOilStepCompleted) score++;
    if (_cuticlePusherStepCompleted) score++;
    if (_cuticleNipperStepCompleted) score++;
    if (_disinfectantSprayStepCompleted) score++;
    if (_sterilizedGauzeStepCompleted) score++;
    if (_polishBrushStepCompleted) score++;
    return score;
  }

  Map<String, bool> getStepCompletionStatus() {
    return {
      '1. 손소독': _handSanitizerStepCompleted,
      '2. 폴리쉬 제거': _polishRemovalStepCompleted,
      '3. 네일파일': _nailFilingStepCompleted,
      '4. 샌딩블록': _sandingStepCompleted,
      '5. 핑거볼': _fingerBowlStepCompleted,
      '6. 큐티클 오일': _cuticleOilStepCompleted,
      '7. 큐티클 푸셔': _cuticlePusherStepCompleted,
      '8. 니퍼로 큐티클 제거': _cuticleNipperStepCompleted,
      '9. 소독 스프레이': _disinfectantSprayStepCompleted,
      '10. 멸균거즈': _sterilizedGauzeStepCompleted,
      '11. 컬러링 도포': _polishBrushStepCompleted,
    };
  }

  ExamProgress saveCurrentProgress() {
    return ExamProgress(
      sessionId: IdGenerator.generateSessionId(),
      isPracticeMode: widget.isPracticeMode,
      savedAt: DateTime.now(),
      currentScore: getCurrentScore(),
      handSanitizerStepCompleted: _handSanitizerStepCompleted,
      polishRemovalStepCompleted: _polishRemovalStepCompleted,
      nailFilingStepCompleted: _nailFilingStepCompleted,
      sandingStepCompleted: _sandingStepCompleted,
      fingerBowlStepCompleted: _fingerBowlStepCompleted,
      cuticleOilStepCompleted: _cuticleOilStepCompleted,
      cuticlePusherStepCompleted: _cuticlePusherStepCompleted,
      cuticleNipperStepCompleted: _cuticleNipperStepCompleted,
      disinfectantSprayStepCompleted: _disinfectantSprayStepCompleted,
      sterilizedGauzeStepCompleted: _sterilizedGauzeStepCompleted,
      polishBrushStepCompleted: _polishBrushStepCompleted,
      sanitizedNails: _sanitizedNails,
      polishRemovedNails: _polishRemovedNails,
      filedNails: _filedNails,
      sandedNails: _sandedNails,
      soakedNails: _soakedNails,
      oiledNails: _oiledNails,
      pushedNails: _pushedNails,
      nippedNails: _nippedNails,
      disinfectedNails: _disinfectedNails,
      cleanedNails: _cleanedNails,
      coloredNails: _coloredNails,
    );
  }

  void restoreProgress(ExamProgress progress) {
    setState(() {
      _handSanitizerStepCompleted = progress.handSanitizerStepCompleted;
      _polishRemovalStepCompleted = progress.polishRemovalStepCompleted;
      _nailFilingStepCompleted = progress.nailFilingStepCompleted;
      _sandingStepCompleted = progress.sandingStepCompleted;
      _fingerBowlStepCompleted = progress.fingerBowlStepCompleted;
      _cuticleOilStepCompleted = progress.cuticleOilStepCompleted;
      _cuticlePusherStepCompleted = progress.cuticlePusherStepCompleted;
      _cuticleNipperStepCompleted = progress.cuticleNipperStepCompleted;
      _disinfectantSprayStepCompleted = progress.disinfectantSprayStepCompleted;
      _sterilizedGauzeStepCompleted = progress.sterilizedGauzeStepCompleted;
      _polishBrushStepCompleted = progress.polishBrushStepCompleted;

      _sanitizedNails.clear();
      _sanitizedNails.addAll(progress.sanitizedNails);
      _polishRemovedNails.clear();
      _polishRemovedNails.addAll(progress.polishRemovedNails);
      _filedNails.clear();
      _filedNails.addAll(progress.filedNails);
      _sandedNails.clear();
      _sandedNails.addAll(progress.sandedNails);
      _soakedNails.clear();
      _soakedNails.addAll(progress.soakedNails);
      _oiledNails.clear();
      _oiledNails.addAll(progress.oiledNails);
      _pushedNails.clear();
      _pushedNails.addAll(progress.pushedNails);
      _nippedNails.clear();
      _nippedNails.addAll(progress.nippedNails);
      _disinfectedNails.clear();
      _disinfectedNails.addAll(progress.disinfectedNails);
      _cleanedNails.clear();
      _cleanedNails.addAll(progress.cleanedNails);
      _coloredNails.clear();
      _coloredNails.addAll(progress.coloredNails);

      // Update instruction based on current progress
      _updateInstructionFromProgress();
    });
  }

  void _updateInstructionFromProgress() {
    if (!_handSanitizerStepCompleted) {
      _updateInstruction("1. 손을(내손 -> 고객 손) 소독하세요");
    } else if (!_polishRemovalStepCompleted) {
      _updateInstruction("2. 폴리쉬 제거(소지->약지)");
    } else if (!_nailFilingStepCompleted) {
      _updateInstruction("3. 네일파일로 모양 만들기");
    } else if (!_sandingStepCompleted) {
      _updateInstruction("4. 샌딩블록으로 표면 정리");
    } else if (!_fingerBowlStepCompleted) {
      _updateInstruction("5. 핑거볼에 손 담그기");
    } else if (!_cuticleOilStepCompleted) {
      _updateInstruction("6. 큐티클 오일 발라주기");
    } else if (!_cuticlePusherStepCompleted) {
      _updateInstruction("7. 큐티클 푸셔로 밀어올리기");
    } else if (!_cuticleNipperStepCompleted) {
      _updateInstruction("8. 니퍼로 큐티클 제거");
    } else if (!_disinfectantSprayStepCompleted) {
      _updateInstruction("9. 소독 스프레이 뿌리기");
    } else if (!_sterilizedGauzeStepCompleted) {
      _updateInstruction("10. 멸균거즈로 오일 제거");
    } else if (!_polishBrushStepCompleted) {
      _updateInstruction("11. 컬러링 도포");
    } else {
      _updateInstruction("완료! 모든 단계가 완료되었습니다.");
    }
  }

  // Step completion tracking
  final Set<int> _sanitizedNails = <int>{};
  bool _handSanitizerStepCompleted = false;
  final Set<int> _polishRemovedNails = <int>{};
  bool _polishRemovalStepCompleted = false;
  final Set<int> _filedNails = <int>{};
  bool _nailFilingStepCompleted = false;
  final Set<int> _sandedNails = <int>{};
  bool _sandingStepCompleted = false;
  final Set<int> _soakedNails = <int>{};
  bool _fingerBowlStepCompleted = false;
  final Set<int> _oiledNails = <int>{};
  bool _cuticleOilStepCompleted = false;
  final Set<int> _pushedNails = <int>{};
  bool _cuticlePusherStepCompleted = false;
  final Set<int> _nippedNails = <int>{};
  bool _cuticleNipperStepCompleted = false;
  final Set<int> _disinfectedNails = <int>{};
  bool _disinfectantSprayStepCompleted = false;
  final Set<int> _cleanedNails = <int>{};
  bool _sterilizedGauzeStepCompleted = false;
  final Set<int> _coloredNails = <int>{};
  bool _polishBrushStepCompleted = false;

  @override
  void initState() {
    super.initState();

    // Set initial instruction based on mode
    if (!widget.isPracticeMode) {
      _currentInstruction = "시험모드입니다";
    }

    // Initialize nail states - only right hand (5 nails)
    nailStates = List.generate(
      5,
      (index) => NailState(fingerIndex: index + 5), // Offset for right hand
    );

    // Initialize gesture controller
    _gestureController = GestureController(
      onGesture: (type, position, {data}) {
        widget.onGesture(type, position);
      },
    );

    // Initialize animations
    _highlightController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _highlightAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _highlightController, curve: Curves.easeInOut),
    );

    // Initialize info toggle highlight animation
    _infoToggleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _infoToggleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _infoToggleController, curve: Curves.elasticOut),
    );

    // Add listener to trigger repaints
    _highlightController.addListener(() {
      setState(() {});
    });

    _infoToggleController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onLongPressStart: _handleLongPress,
      onScaleStart: _handleScaleStart,
      onScaleUpdate: _handleScaleUpdate,
      onScaleEnd: _handleScaleEnd,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.grey[100]!, Colors.grey[200]!],
          ),
        ),
        child: Stack(
          children: [
            // Main nail work area with AnimatedBuilder to ensure repainting
            AnimatedBuilder(
              animation: _highlightController,
              builder: (context, child) {
                return CustomPaint(
                  painter: IsometricPainter(
                    nailStates: nailStates,
                    isometricTransform: isometricTransform,
                    scale: _currentScale,
                    currentTool: widget.currentTool,
                    highlightedNail: _highlightedNail,
                    highlightAnimation: _highlightAnimation,
                    dragPath: _dragPath,
                  ),
                  size: Size.infinite,
                );
              },
            ),

            // Instruction toggle button
            Positioned(top: 20, left: 20, child: _buildInstructionToggle()),

            // Instruction popup (when toggled)
            if (_showInstruction)
              Positioned(
                top: 70,
                left: 20,
                right: 20,
                child: _buildInstructionPopup(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionToggle() {
    return AnimatedBuilder(
      animation: _infoToggleAnimation,
      builder: (context, child) {
        final highlightValue = _infoToggleAnimation.value.clamp(0.0, 1.0);
        final scale = 1.0 + (highlightValue * 0.3); // Scale up to 1.3x
        final glowIntensity = (highlightValue * 0.8).clamp(0.0, 1.0);

        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _showInstruction = !_showInstruction;
              });
              HapticFeedback.lightImpact();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _showInstruction
                    ? Theme.of(context).primaryColor
                    : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                  // Add glowing effect when highlighting
                  if (highlightValue > 0)
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).primaryColor.withOpacity(glowIntensity),
                      blurRadius: 15 * highlightValue,
                      offset: const Offset(0, 0),
                    ),
                  if (highlightValue > 0)
                    BoxShadow(
                      color: Colors.orange.withOpacity(
                        (glowIntensity * 0.6).clamp(0.0, 1.0),
                      ),
                      blurRadius: 25 * highlightValue,
                      offset: const Offset(0, 0),
                    ),
                ],
              ),
              child: Icon(
                Icons.info_outline,
                color: _showInstruction
                    ? Colors.white
                    : Theme.of(context).primaryColor,
                size: 20,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInstructionPopup() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).primaryColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        _currentInstruction,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  void _handleTapDown(TapDownDetails details) {
    final position = details.localPosition;
    _gestureController.processTap(position);

    // Check if tapping on a nail
    final nailIndex = _getNailAtPosition(position);
    if (nailIndex != null) {
      print(
        'NailExam [DEBUG]: Tapped on nail $nailIndex. Current tool: ${widget.currentTool?.name ?? "none"}',
      );
      _highlightNail(nailIndex);

      // Check for dual tool selection (remover + cotton pad)
      final hasRemover =
          widget.selectedTools?.any((t) => t.type == ToolType.remover) ?? false;
      final hasCottonPad =
          widget.selectedTools?.any((t) => t.type == ToolType.cottonPad) ??
          false;

      if (hasRemover && hasCottonPad) {
        print(
          'NailExam [DEBUG]: Both remover and cotton pad selected - removing polish from nail $nailIndex',
        );
        _removePolishFromNail(nailIndex);
      } else if (widget.currentTool != null) {
        _applyToolToNail(nailIndex, widget.currentTool!);
      } else {
        print('NailExam [DEBUG]: No tool selected - cannot apply to nail');
      }
    }
  }

  void _handleLongPress(LongPressStartDetails details) {
    _gestureController.processLongPress(details.localPosition);
    HapticFeedback.mediumImpact();

    final nailIndex = _getNailAtPosition(details.localPosition);
    if (nailIndex != null) {
      _showNailDetails(nailIndex);
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _lastDragPosition = details.focalPoint;
    _dragPath.clear();
    _dragPath.add(details.focalPoint);
    _gestureController.processScale(1.0, details.focalPoint);
    _gestureController.processDragStart(details.focalPoint);
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (_lastDragPosition != null) {
      final delta = details.focalPoint - _lastDragPosition!;

      // Handle drag (when scale is near 1.0, treat as drag)
      if ((details.scale - 1.0).abs() < 0.1) {
        // Add to drag path for visual feedback
        _dragPath.add(details.focalPoint);
        if (_dragPath.length > 50) {
          _dragPath.removeAt(0); // Keep path manageable
        }

        // Check if dragging over a nail
        final nailIndex = _getNailAtPosition(details.focalPoint);
        if (nailIndex != null && widget.currentTool != null) {
          _applyToolToNail(nailIndex, widget.currentTool!);
          _highlightNail(nailIndex);
        }

        _gestureController.processDragUpdate(details.focalPoint, delta);
        widget.onDragUpdate(details.focalPoint);
      } else {
        // Handle scale/zoom
        setState(() {
          _currentScale = (_currentScale * details.scale).clamp(0.5, 2.0);
        });
      }

      _lastDragPosition = details.focalPoint;
      _gestureController.processScale(details.scale, details.focalPoint);
      setState(() {}); // Update drag path visualization
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    _gestureController.processDragEnd(_lastDragPosition ?? Offset.zero);
    _gestureController.processScaleEnd();
    _lastDragPosition = null;
    _dragPath.clear();
    _clearHighlight();
    setState(() {});
  }

  int? _getNailAtPosition(Offset position) {
    // Convert screen position to isometric coordinates
    // This is a simplified hit detection - in a real implementation,
    // you would transform the position using the inverse isometric transform

    final size = context.size ?? Size.zero;
    if (size == Size.zero) return null;

    // Get nail positions (simplified calculation)
    final nailPositions = _calculateNailPositions(size);

    for (int i = 0; i < nailPositions.length; i++) {
      final nailRect = Rect.fromCenter(
        center: nailPositions[i],
        width: 60 * _currentScale, // Bigger nails
        height: 75 * _currentScale, // Bigger nails
      );

      if (nailRect.contains(position)) {
        return i;
      }
    }

    return null;
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

  void _applyToolToNail(int nailIndex, Tool tool) {
    if (nailIndex >= 0 && nailIndex < nailStates.length) {
      // Debug logging
      print(
        'NailExam [DEBUG]: Applying tool ${tool.name} (${tool.type}) to nail $nailIndex',
      );

      setState(() {
        nailStates[nailIndex].applyTool(
          tool,
          additionalData: widget.currentPolishColor != null
              ? {'color': widget.currentPolishColor}
              : null,
        );
      });

      // Track hand sanitizer usage
      if (tool.type == ToolType.handSanitizer && !_handSanitizerStepCompleted) {
        _sanitizedNails.add(nailIndex);
        print(
          'NailExam [DEBUG]: Hand sanitizer applied to nail $nailIndex. Total sanitized nails: ${_sanitizedNails.length}',
        );
        _checkHandSanitizerCompletion();
      }

      // Track nail file usage
      if (tool.type == ToolType.nailFile &&
          _polishRemovalStepCompleted &&
          !_nailFilingStepCompleted) {
        _filedNails.add(nailIndex);
        print(
          'NailExam [DEBUG]: Nail file applied to nail $nailIndex. Total filed nails: ${_filedNails.length}',
        );
        _checkNailFilingCompletion();
      }

      // Track sanding block usage
      if (tool.type == ToolType.sandingBlock &&
          _nailFilingStepCompleted &&
          !_sandingStepCompleted) {
        _sandedNails.add(nailIndex);
        print(
          'NailExam [DEBUG]: Sanding block applied to nail $nailIndex. Total sanded nails: ${_sandedNails.length}',
        );
        _checkSandingCompletion();
      }

      // Track finger bowl usage
      if (tool.type == ToolType.fingerBowl &&
          _sandingStepCompleted &&
          !_fingerBowlStepCompleted) {
        _soakedNails.add(nailIndex);
        print(
          'NailExam [DEBUG]: Finger bowl applied to nail $nailIndex. Total soaked nails: ${_soakedNails.length}',
        );
        _checkFingerBowlCompletion();
      }

      // Track cuticle oil usage
      if (tool.type == ToolType.cuticleOil &&
          _fingerBowlStepCompleted &&
          !_cuticleOilStepCompleted) {
        _oiledNails.add(nailIndex);
        print(
          'NailExam [DEBUG]: Cuticle oil applied to nail $nailIndex. Total oiled nails: ${_oiledNails.length}',
        );
        _checkCuticleOilCompletion();
      }

      // Track cuticle pusher usage
      if (tool.type == ToolType.cuticlePusher &&
          _cuticleOilStepCompleted &&
          !_cuticlePusherStepCompleted) {
        _pushedNails.add(nailIndex);
        print(
          'NailExam [DEBUG]: Cuticle pusher applied to nail $nailIndex. Total pushed nails: ${_pushedNails.length}',
        );
        _checkCuticlePusherCompletion();
      }

      // Track cuticle nipper usage
      if (tool.type == ToolType.cuticleNipper &&
          _cuticlePusherStepCompleted &&
          !_cuticleNipperStepCompleted) {
        _nippedNails.add(nailIndex);
        print(
          'NailExam [DEBUG]: Cuticle nipper applied to nail $nailIndex. Total nipped nails: ${_nippedNails.length}',
        );
        _checkCuticleNipperCompletion();
      }

      // Track disinfectant spray usage
      if (tool.type == ToolType.disinfectantSpray &&
          _cuticleNipperStepCompleted &&
          !_disinfectantSprayStepCompleted) {
        _disinfectedNails.add(nailIndex);
        print(
          'NailExam [DEBUG]: Disinfectant spray applied to nail $nailIndex. Total disinfected nails: ${_disinfectedNails.length}',
        );
        _checkDisinfectantSprayCompletion();
      }

      // Track sterilized gauze usage
      if (tool.type == ToolType.sterilizedGauze &&
          _disinfectantSprayStepCompleted &&
          !_sterilizedGauzeStepCompleted) {
        _cleanedNails.add(nailIndex);
        print(
          'NailExam [DEBUG]: Sterilized gauze applied to nail $nailIndex. Total cleaned nails: ${_cleanedNails.length}',
        );
        _checkSterilizedGauzeCompletion();
      }

      // Track polish brush usage for final coloring step
      if (tool.type == ToolType.polishBrush &&
          _sterilizedGauzeStepCompleted &&
          !_polishBrushStepCompleted) {
        _coloredNails.add(nailIndex);
        print(
          'NailExam [DEBUG]: Polish brush applied to nail $nailIndex. Total colored nails: ${_coloredNails.length}',
        );
        _checkPolishBrushCompletion();
      }

      widget.onToolApplied(tool);
      HapticFeedback.lightImpact();
    }
  }

  void _removePolishFromNail(int nailIndex) {
    if (nailIndex >= 0 && nailIndex < nailStates.length) {
      final nail = nailStates[nailIndex];

      // Only proceed if the nail actually has polish to remove
      if (!nail.hasPolish) {
        print(
          'NailExam [DEBUG]: Nail $nailIndex already has no polish to remove',
        );
        return;
      }

      print('NailExam [DEBUG]: Removing polish from nail $nailIndex');

      setState(() {
        // Manually remove polish without using the tool's built-in logic
        nailStates[nailIndex].hasPolish = false;
        nailStates[nailIndex].polishColor = Colors.transparent;
        nailStates[nailIndex].polishCoverage = 0.0;
        nailStates[nailIndex].hasTopCoat = false;
        nailStates[nailIndex].hasBaseCoat = false;
        nailStates[nailIndex].shineLevel = 0.0;
      });

      // Track polish removal completion (only if hand sanitizer step is completed)
      if (_handSanitizerStepCompleted && !_polishRemovalStepCompleted) {
        _polishRemovedNails.add(nailIndex);
        print(
          'NailExam [DEBUG]: Polish removed from nail $nailIndex. Total nails with polish removed: ${_polishRemovedNails.length}',
        );
        _checkPolishRemovalCompletion();
      }

      // Find remover tool to trigger onToolApplied callback
      final removerTool = widget.selectedTools?.firstWhere(
        (t) => t.type == ToolType.remover,
        orElse: () => Tool(
          id: 'remover',
          name: 'Polish Remover',
          type: ToolType.remover,
          iconPath: 'assets/tools/remover.png',
        ),
      );

      if (removerTool != null) {
        widget.onToolApplied(removerTool);
      }

      HapticFeedback.lightImpact();
      print('NailExam [DEBUG]: Polish removed from nail $nailIndex');
    }
  }

  void _checkHandSanitizerCompletion() {
    // Check if all 5 nails have been sanitized
    if (_sanitizedNails.length == 5 && !_handSanitizerStepCompleted) {
      setState(() {
        _handSanitizerStepCompleted = true;
        _updateInstruction("2. 폴리쉬 제거(소지->약지)");
      });

      // Trigger info toggle highlight animation
      _highlightInfoToggle();

      print('Hand sanitizer step completed! All 5 nails sanitized.');
    }
  }

  void _checkPolishRemovalCompletion() {
    // Check if all 5 nails have had polish removed
    if (_polishRemovedNails.length == 5 && !_polishRemovalStepCompleted) {
      setState(() {
        _polishRemovalStepCompleted = true;
        _updateInstruction("3. 라운드 쉐입 파일링 하기");
      });

      // Trigger info toggle highlight animation
      _highlightInfoToggle();

      print('Polish removal step completed! All 5 nails have polish removed.');
    }
  }

  void _checkNailFilingCompletion() {
    // Check if all 5 nails have been filed
    if (_filedNails.length == 5 && !_nailFilingStepCompleted) {
      setState(() {
        _nailFilingStepCompleted = true;
        _updateInstruction("4. 에칭-거스러미 제거");
      });

      // Trigger info toggle highlight animation
      _highlightInfoToggle();

      print('Nail filing step completed! All 5 nails have been filed.');
    }
  }

  void _checkSandingCompletion() {
    // Check if all 5 nails have been sanded
    if (_sandedNails.length == 5 && !_sandingStepCompleted) {
      setState(() {
        _sandingStepCompleted = true;
        _updateInstruction("5. 핑거볼에 손 담구기");
      });

      // Trigger info toggle highlight animation
      _highlightInfoToggle();

      print('Sanding step completed! All 5 nails have been sanded.');
    }
  }

  void _checkFingerBowlCompletion() {
    // Check if all 5 nails have been soaked in finger bowl
    if (_soakedNails.length == 5 && !_fingerBowlStepCompleted) {
      setState(() {
        _fingerBowlStepCompleted = true;
        _updateInstruction("6. 큐티클 리무버 혹은 오일 바르기");
      });

      // Trigger info toggle highlight animation
      _highlightInfoToggle();

      print('Finger bowl step completed! All 5 nails have been soaked.');
    }
  }

  void _checkCuticleOilCompletion() {
    // Check if all 5 nails have been treated with cuticle oil
    if (_oiledNails.length == 5 && !_cuticleOilStepCompleted) {
      setState(() {
        _cuticleOilStepCompleted = true;
        _updateInstruction("7. 45º 각도 푸셔링");
      });

      // Trigger info toggle highlight animation
      _highlightInfoToggle();

      print('Cuticle oil step completed! All 5 nails have been oiled.');
    }
  }

  void _checkCuticlePusherCompletion() {
    // Check if all 5 nails have been treated with cuticle pusher
    if (_pushedNails.length == 5 && !_cuticlePusherStepCompleted) {
      setState(() {
        _cuticlePusherStepCompleted = true;
        _updateInstruction("8. 니퍼로 큐티클 제거");
      });

      // Trigger info toggle highlight animation
      _highlightInfoToggle();

      print(
        'Cuticle pusher step completed! All 5 nails have been pushed at 45º angle.',
      );
    }
  }

  void _checkCuticleNipperCompletion() {
    // Check if all 5 nails have been treated with cuticle nipper
    if (_nippedNails.length == 5 && !_cuticleNipperStepCompleted) {
      setState(() {
        _cuticleNipperStepCompleted = true;
        _updateInstruction("9. 소독제 스프레이");
      });

      // Trigger info toggle highlight animation
      _highlightInfoToggle();

      print(
        'Cuticle nipper step completed! All 5 cuticles have been removed with nipper.',
      );
    }
  }

  void _checkDisinfectantSprayCompletion() {
    // Check if all 5 nails have been treated with disinfectant spray
    if (_disinfectedNails.length == 5 && !_disinfectantSprayStepCompleted) {
      setState(() {
        _disinfectantSprayStepCompleted = true;
        _updateInstruction("10. 유분기 제거하기");
      });

      // Trigger info toggle highlight animation
      _highlightInfoToggle();

      print(
        'Disinfectant spray step completed! All 5 nails have been disinfected.',
      );
    }
  }

  void _checkSterilizedGauzeCompletion() {
    // Check if all 5 nails have been cleaned with sterilized gauze
    if (_cleanedNails.length == 5 && !_sterilizedGauzeStepCompleted) {
      setState(() {
        _sterilizedGauzeStepCompleted = true;
        _updateInstruction("11. 컬러링 도포");
      });

      // Trigger info toggle highlight animation
      _highlightInfoToggle();

      print(
        'Sterilized gauze step completed! All 5 nails have been cleaned of oil residue.',
      );
    }
  }

  void _checkPolishBrushCompletion() {
    // Check if all 5 nails have been colored with polish brush
    if (_coloredNails.length == 5 && !_polishBrushStepCompleted) {
      setState(() {
        _polishBrushStepCompleted = true;
        _updateInstruction("완료! 모든 단계가 완료되었습니다.");
      });

      // Trigger info toggle highlight animation
      _highlightInfoToggle();

      print(
        'Polish brush step completed! All 5 nails have been colored. All 11 steps completed!',
      );

      // Calculate and report exam score if in exam mode
      if (!widget.isPracticeMode && widget.onExamCompleted != null) {
        _calculateAndReportScore();
      }
    }
  }

  void _updateInstruction(String instruction) {
    // Only update instruction text in practice mode
    if (widget.isPracticeMode) {
      _currentInstruction = instruction;
    }
  }

  void _calculateAndReportScore() {
    List<String> completedSteps = [];
    List<String> missedSteps = [];

    // Check each step completion and add to appropriate list
    if (_handSanitizerStepCompleted) {
      completedSteps.add("1. 손소독");
    } else {
      missedSteps.add("1. 손소독");
    }

    if (_polishRemovalStepCompleted) {
      completedSteps.add("2. 폴리쉬 제거");
    } else {
      missedSteps.add("2. 폴리쉬 제거");
    }

    if (_nailFilingStepCompleted) {
      completedSteps.add("3. 네일파일");
    } else {
      missedSteps.add("3. 네일파일");
    }

    if (_sandingStepCompleted) {
      completedSteps.add("4. 샌딩블록");
    } else {
      missedSteps.add("4. 샌딩블록");
    }

    if (_fingerBowlStepCompleted) {
      completedSteps.add("5. 핑거볼");
    } else {
      missedSteps.add("5. 핑거볼");
    }

    if (_cuticleOilStepCompleted) {
      completedSteps.add("6. 큐티클 오일");
    } else {
      missedSteps.add("6. 큐티클 오일");
    }

    if (_cuticlePusherStepCompleted) {
      completedSteps.add("7. 큐티클 푸셔");
    } else {
      missedSteps.add("7. 큐티클 푸셔");
    }

    if (_cuticleNipperStepCompleted) {
      completedSteps.add("8. 니퍼로 큐티클 제거");
    } else {
      missedSteps.add("8. 니퍼로 큐티클 제거");
    }

    if (_disinfectantSprayStepCompleted) {
      completedSteps.add("9. 소독 스프레이");
    } else {
      missedSteps.add("9. 소독 스프레이");
    }

    if (_sterilizedGauzeStepCompleted) {
      completedSteps.add("10. 멸균거즈");
    } else {
      missedSteps.add("10. 멸균거즈");
    }

    if (_polishBrushStepCompleted) {
      completedSteps.add("11. 컬러링 도포");
    } else {
      missedSteps.add("11. 컬러링 도포");
    }

    // Calculate total score (1 point per completed step)
    int totalScore = completedSteps.length;

    // Report the score via callback
    widget.onExamCompleted!(totalScore, completedSteps, missedSteps);
  }

  void _highlightInfoToggle() {
    // Only highlight info toggle in practice mode
    if (!widget.isPracticeMode) return;

    _infoToggleController.reset();
    _infoToggleController.forward().then((_) {
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            _infoToggleController.reverse();
          }
        });
      }
    });
  }

  void _highlightNail(int nailIndex) {
    setState(() {
      _highlightedNail = nailIndex;
    });

    // Stop any ongoing animation first
    _highlightController.stop();
    _highlightController.reset();

    // Start the animation with proper timing
    _highlightController.forward().then((_) {
      if (mounted) {
        // Hold the effect for longer to make it visible
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            _highlightController.reverse().then((_) {
              if (mounted) {
                setState(() {
                  _highlightedNail = null;
                });
              }
            });
          }
        });
      }
    });

    // Debug print to verify animation is triggered
    print('Highlighting nail $nailIndex');
  }

  void _clearHighlight() {
    if (_highlightedNail != null) {
      setState(() {
        _highlightedNail = null;
      });
      _highlightController.reset();
    }
  }

  void _showNailDetails(int nailIndex) {
    final nail = nailStates[nailIndex];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nail ${nailIndex + 1} Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cuticle: ${nail.hasCuticle ? "Needs attention" : "Clean"}'),
            Text('Polish: ${nail.hasPolish ? "Applied" : "None"}'),
            Text('Coverage: ${(nail.polishCoverage * 100).toInt()}%'),
            Text('Filing: ${nail.needsFiling ? "Needed" : "Done"}'),
            Text('Shine: ${(nail.shineLevel * 100).toInt()}%'),
            Text(
              'Completion: ${(nail.calculateCompletionScore() * 100).toInt()}%',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Public method to reset all nails
  void resetAllNails() {
    setState(() {
      for (final nail in nailStates) {
        nail.reset();
      }
    });
  }

  // Public method to get completion percentage
  double getOverallCompletion() {
    if (nailStates.isEmpty) return 0.0;

    final totalScore = nailStates
        .map((nail) => nail.calculateCompletionScore())
        .reduce((a, b) => a + b);

    return totalScore / nailStates.length;
  }

  // Public method to check if sequence is correct for all nails
  bool isOverallSequenceCorrect() {
    return nailStates.every((nail) => nail.isSequenceCorrect());
  }

  @override
  void dispose() {
    _highlightController.dispose();
    _infoToggleController.dispose();
    _gestureController.reset();
    super.dispose();
  }
}
