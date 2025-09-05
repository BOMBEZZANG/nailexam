import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/exam_session.dart';
import '../../data/models/tool.dart';
import '../../data/models/exam_progress.dart';
import '../../navigation/app_router.dart';
import '../widgets/common/loading_indicator.dart';
import '../widgets/common/banner_ad_widget.dart';
import '../widgets/exam/isometric_work_area.dart';
import '../widgets/exam/tool_tray.dart';
import '../widgets/exam/color_palette.dart';
import '../widgets/exam/feedback_overlay.dart';

// Temporary FeedbackController class (until implemented)
class FeedbackController {
  final _streamController = StreamController<String>.broadcast();
  Stream<String> get stream => _streamController.stream;
  
  void showFeedback(String message) {
    _streamController.add(message);
  }
  
  void dispose() {
    _streamController.close();
  }
}

// Temporary ExamView interface (until implemented)
abstract class ExamView {
  void showLoading();
  void hideLoading();
  void updateExamTime(Duration time);
  void updatePeriodTime(Duration time);
  void updatePeriodInfo(String info);
  void updateProgress(double progress);
  void showExamComplete(ExamSession session);
  void showError(String message);
}

// Temporary ExamPresenter class (until implemented)
class ExamPresenter {
  ExamView? _view;
  
  void attachView(ExamView view) {
    _view = view;
  }
  
  void startExam({required bool isPracticeMode}) {
    _view?.updatePeriodInfo(isPracticeMode ? '손을(내손 -> 고객 손) 소독하세요' : '1차: 매니큐어 - 기본 매니큐어');
    _view?.updateProgress(0.0);
  }
  
  void dispose() {
    _view = null;
  }
}

class ExamScreen extends StatefulWidget {
  final bool isPracticeMode;
  final String? sessionId;

  const ExamScreen({super.key, required this.isPracticeMode, this.sessionId});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> implements ExamView {
  late ExamPresenter _presenter;
  bool _isLoading = false;
  Duration _examTime = Duration.zero;
  Duration _periodTime = Duration.zero;
  String _currentPeriodInfo = '';
  double _progress = 0.0;

  bool _didInitializePresenter = false;

  // Phase 2 UI state
  Tool? _selectedTool;
  final Set<Tool> _selectedTools = <Tool>{}; // Track multiple selected tools
  Color? _selectedColor;
  bool _showToolTray = true; // Default to tool tray
  bool _showColorPalette = false;
  final FeedbackController _feedbackController = FeedbackController();
  // Track work area state through GlobalKey
  final GlobalKey<IsometricWorkAreaState> _workAreaKey =
      GlobalKey<IsometricWorkAreaState>();
  
  // Tutorial step tracking
  int _currentTutorialStep = 1;
  final List<String> _tutorialSteps = [
    '손을(내손 -> 고객 손) 소독하세요',
    '폴리쉬 제거(소지->약지)',
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

  // Exam results for score tracking (exam mode only)
  int? _examScore;
  List<String>? _completedSteps;
  List<String>? _missedSteps;

  @override
  void initState() {
    super.initState();
    _presenter = ExamPresenter();
    // Force rebuild to ensure UI is properly updated for both modes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
      _loadSavedProgress();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInitializePresenter) {
      _didInitializePresenter = true;
      _presenter.attachView(this);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _presenter.startExam(isPracticeMode: widget.isPracticeMode);
      });
    }
  }

  @override
  void dispose() {
    _presenter.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _showExitDialog();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isPracticeMode ? '연습 모드' : '시험 모드'),
          actions: [
            // Overall progress bar for both modes
            Container(
              width: 120,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '전체 진행과정',
                    style: TextStyle(fontSize: 9, color: Colors.black),
                  ),
                  const SizedBox(height: 1),
                  SizedBox(
                    height: 3,
                    child: LinearProgressIndicator(
                      value: _progress,
                      backgroundColor: Colors.grey.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Add exit/complete buttons in landscape mode
            if (MediaQuery.of(context).orientation == Orientation.landscape) ...[
              TextButton(
                onPressed: _showExitDialog,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: const Text('나가기'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _completePeriod,
                child: const Text('완료'),
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),
        body: _isLoading
            ? const LoadingIndicator(message: 'Starting exam...')
            : Stack(
                children: [
                  _buildExamContent(),
                  FeedbackOverlay(feedbackStream: _feedbackController.stream),
                ],
              ),
      ),
    );
  }

  Widget _buildExamContent() {
    // Debug print to verify this is being called for both modes
    print(
      'DEBUG: Building exam content for ${widget.isPracticeMode ? "Practice" : "Exam"} mode',
    );

    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.landscape) {
          return _buildLandscapeLayout();
        } else {
          return _buildPortraitLayout();
        }
      },
    );
  }

  Widget _buildPortraitLayout() {
    return Column(
      children: [
        // 상단 정보 섹션 (Period Info + Score)
        _buildTopInfoSection(),
        
        // 메인 작업 영역 (Isometric Work Area)
        Expanded(
          flex: 3, // 60% of available space
          child: _buildMainWorkArea(),
        ),
        
        // 하단 도구/컬러 섹션
        _buildBottomToolSection(),
      ],
    );
  }

  Widget _buildLandscapeLayout() {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              // 왼쪽 도구 섹션
              Container(
                width: 200,
                color: Theme.of(context).cardColor,
                child: Column(
                  children: [
                    // 상단 정보 섹션
                    _buildTopInfoSection(),
                    const Divider(height: 1),
                    // 도구/컬러 토글
                    _buildToolToggleSection(),
                    const Divider(height: 1),
                    // 도구 트레이 또는 색상 팔레트
                    Expanded(
                      child: _showColorPalette ? _buildColorPalette() : _buildToolTray(),
                    ),
                  ],
                ),
              ),
              // 메인 작업 영역
              Expanded(
                child: _buildMainWorkArea(),
              ),
            ],
          ),
        ),
        // Banner ads section for landscape mode
        _buildBannerAdsSection(),
      ],
    );
  }

  Widget _buildTopInfoSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Theme.of(context).cardColor,
      child: Row(
        children: [
          // Period Info Card
          Expanded(
            flex: 2,
            child: _buildPeriodInfoCard(),
          ),
          const SizedBox(width: 12),
          // Score Display (exam mode only)
          if (!widget.isPracticeMode)
            Expanded(
              flex: 1,
              child: _buildScoreDisplay(),
            ),
        ],
      ),
    );
  }

  Widget _buildPeriodInfoCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.isPracticeMode ? Colors.blue.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.isPracticeMode ? Colors.blue.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                widget.isPracticeMode ? Icons.school : Icons.timer,
                size: 16,
                color: widget.isPracticeMode ? Colors.blue.shade700 : Colors.orange.shade700,
              ),
              const SizedBox(width: 6),
              Text(
                widget.isPracticeMode ? '연습모드' : '시험모드',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: widget.isPracticeMode ? Colors.blue.shade700 : Colors.orange.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _getTutorialStepMessage(),
            style: const TextStyle(fontSize: 11, color: Colors.black87),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDisplay() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.star,
            size: 16,
            color: Colors.green.shade700,
          ),
          const SizedBox(height: 4),
          Text(
            '${_examScore ?? 0}/11',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
          Text(
            '점수',
            style: TextStyle(
              fontSize: 10,
              color: Colors.green.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainWorkArea() {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor, width: 2),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[50],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: _buildIsometricWorkArea(),
      ),
    );
  }

  Widget _buildIsometricWorkArea() {
    print(
      'DEBUG: Building isometric work area for ${widget.isPracticeMode ? "Practice" : "Exam"} mode',
    );

    return IsometricWorkArea(
      key: _workAreaKey,
      onDragUpdate: _onDragUpdate,
      onToolApplied: _onToolApplied,
      onGesture: _onGesture,
      currentTool: _selectedTool,
      selectedTools: _selectedTools,
      currentPolishColor: _selectedColor,
      isPracticeMode: widget.isPracticeMode,
      onExamCompleted: widget.isPracticeMode ? null : _onExamCompleted,
      onStepChanged: widget.isPracticeMode ? _onTutorialStepChanged : null,
    );
  }

  Widget _buildBottomToolSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tool section
        Container(
          height: 150, // Fixed height for tool section
          color: Theme.of(context).cardColor,
          child: Column(
            children: [
              // Tool/Color toggle buttons with exit/complete buttons
              _buildPortraitToolToggleSection(),
              const Divider(height: 1),
              // Tool Tray or Color Palette
              Expanded(
                child: _showColorPalette ? _buildColorPalette() : _buildToolTray(),
              ),
            ],
          ),
        ),
        // Banner ads section
        _buildBannerAdsSection(),
      ],
    );
  }

  Widget _buildPortraitToolToggleSection() {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          // Tool Tray Button
          Expanded(
            child: InkWell(
              onTap: () => setState(() {
                _showColorPalette = false;
                _showToolTray = true;
              }),
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  color: _showToolTray 
                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                    : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _showToolTray 
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.build,
                      size: 18,
                      color: _showToolTray 
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '도구',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: _showToolTray ? FontWeight.bold : FontWeight.normal,
                        color: _showToolTray 
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Color Palette Button
          Expanded(
            child: InkWell(
              onTap: () => setState(() {
                _showColorPalette = true;
                _showToolTray = false;
              }),
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  color: _showColorPalette 
                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                    : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _showColorPalette 
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.palette,
                      size: 18,
                      color: _showColorPalette 
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '색상',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: _showColorPalette ? FontWeight.bold : FontWeight.normal,
                        color: _showColorPalette 
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Spacer(),
          // Exit and Complete buttons
          TextButton(
            onPressed: _showExitDialog,
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              minimumSize: const Size(50, 36),
            ),
            child: const Text('나가기', style: TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _completePeriod,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(50, 36),
            ),
            child: const Text('완료', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildToolToggleSection() {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        children: [
          Row(
            children: [
              // Tool Tray Button
              Expanded(
                child: InkWell(
                  onTap: () => setState(() {
                    _showColorPalette = false;
                    _showToolTray = true;
                  }),
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: _showToolTray 
                        ? Theme.of(context).primaryColor.withOpacity(0.1)
                        : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _showToolTray 
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.build,
                          size: 18,
                          color: _showToolTray 
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '도구',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: _showToolTray ? FontWeight.bold : FontWeight.normal,
                            color: _showToolTray 
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Color Palette Button
              Expanded(
                child: InkWell(
                  onTap: () => setState(() {
                    _showColorPalette = true;
                    _showToolTray = false;
                  }),
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: _showColorPalette 
                        ? Theme.of(context).primaryColor.withOpacity(0.1)
                        : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _showColorPalette 
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.palette,
                          size: 18,
                          color: _showColorPalette 
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '색상',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: _showColorPalette ? FontWeight.bold : FontWeight.normal,
                            color: _showColorPalette 
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolTray() {
    // Get highlighted tools from work area if in practice mode
    Set<ToolType>? highlightedTools;
    if (widget.isPracticeMode && _workAreaKey.currentState != null) {
      highlightedTools = _workAreaKey.currentState!.getCurrentStepRequiredTools();
    }
    
    return ToolTray(
      selectedTool: _selectedTool,
      selectedTools: _selectedTools,
      highlightedTools: highlightedTools,
      onToolSelected: (tool) {
        setState(() {
          // Special handling for step 2 - allow multiple tool selection
          if (widget.isPracticeMode && _currentTutorialStep == 2) {
            // For step 2, allow selecting both remover and cotton pad
            if (_selectedTools.contains(tool)) {
              // If tool is already selected, deselect it
              _selectedTools.remove(tool);
              if (_selectedTool == tool) {
                _selectedTool = _selectedTools.isNotEmpty ? _selectedTools.first : null;
              }
            } else {
              // Add tool to selection if it's required for step 2
              if (tool.type == ToolType.remover || tool.type == ToolType.cottonPad) {
                _selectedTools.add(tool);
                _selectedTool = tool; // Set as primary selected tool
              }
            }
          } else {
            // For other steps, single tool selection
            _selectedTool = tool;
            _selectedTools.clear();
            _selectedTools.add(tool);
          }
        });
        
        // Provide haptic feedback
        HapticFeedback.lightImpact();
        
        // Clear color selection when tool is selected
        if (_selectedColor != null) {
          setState(() {
            _selectedColor = null;
          });
        }
        
        // Removed tool selection feedback message
        print('DEBUG: Tool selected: ${tool.name}');
      },
      isCompact: true, // Horizontal layout for bottom section
    );
  }

  Widget _buildColorPalette() {
    return ColorPalette(
      selectedColor: _selectedColor,
      onColorSelected: (color) {
        setState(() {
          _selectedColor = color;
        });
        
        // Provide haptic feedback
        HapticFeedback.lightImpact();
        
        // Removed color selection feedback message
        print('DEBUG: Color selected: ${color.toString()}');
      },
      isCompact: true, // Horizontal layout for bottom section
    );
  }

  // Gesture handlers
  void _onDragUpdate(Offset position) {
    // Check if tools are selected
    if (_selectedTools.isEmpty) {
      _feedbackController.showFeedback('먼저 도구를 선택하세요');
      return;
    }
    
    // Special check for step 2 - both tools required
    if (widget.isPracticeMode && _currentTutorialStep == 2) {
      bool hasRemover = _selectedTools.any((tool) => tool.type == ToolType.remover);
      bool hasCottonPad = _selectedTools.any((tool) => tool.type == ToolType.cottonPad);
      
      if (!hasRemover || !hasCottonPad) {
        _feedbackController.showFeedback('폴리쉬 제거를 위해 제거제와 코튼패드를 모두 선택하세요');
        return;
      }
    }
    
    // Handle drag gesture with selected tool
    if (_selectedTool != null) {
      print('DEBUG: Drag at position: $position with tool: ${_selectedTool!.name}');
    }
  }

  void _onToolApplied(dynamic tool, Offset position) {
    // Handle tool application
    if (tool is Tool) {
      setState(() {
        tool.usageCount++;
      });
      
      // Removed tool usage feedback message
      print('DEBUG: Tool applied: ${tool.name} at position: $position');
    }
  }

  void _onGesture(String gestureType, Offset position) {
    print('DEBUG: Gesture detected: $gestureType at position: $position');
  }

  void _onExamCompleted(Map<String, dynamic> results) {
    setState(() {
      _examScore = results['score'] as int?;
      _completedSteps = (results['completedSteps'] as List?)?.cast<String>();
      _missedSteps = (results['missedSteps'] as List?)?.cast<String>();
    });
    
    _showExamResults();
  }

  void _completePeriod() {
    if (widget.isPracticeMode) {
      _showPracticeCompleteDialog();
    } else {
      // For exam mode, trigger exam completion
      _onExamCompleted({
        'score': _examScore ?? 5,
        'completedSteps': _completedSteps ?? ['기본 매니큐어 완료'],
        'missedSteps': _missedSteps ?? [],
      });
    }
  }

  void _showPracticeCompleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('연습 완료'),
          content: const Text('연습을 마치시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('계속 연습'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Return to home
              },
              child: const Text('완료'),
            ),
          ],
        );
      },
    );
  }

  void _showExamResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('시험 완료'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '최종 점수: ${_examScore ?? 0}/11',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            if (_completedSteps?.isNotEmpty == true) ...[
              Text(
                '완료한 단계:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ..._completedSteps!.map(
                (step) => Text(
                  '✓ $step',
                  style: TextStyle(color: Colors.green.shade600),
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (_missedSteps?.isNotEmpty == true) ...[
              Text(
                '놓친 단계:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ..._missedSteps!.map(
                (step) => Text(
                  '✗ $step',
                  style: TextStyle(color: Colors.red.shade600),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Return to home screen
            },
            child: const Text('홈으로'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              // Restart exam
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ExamScreen(isPracticeMode: false),
                ),
              );
            },
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(widget.isPracticeMode ? '연습 종료' : '시험 종료'),
          content: Text(widget.isPracticeMode 
            ? '연습을 종료하시겠습니까?' 
            : '시험을 종료하시겠습니까? 진행 상황이 저장되지 않습니다.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Return to home
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('종료'),
            ),
          ],
        );
      },
    );
  }

  void _loadSavedProgress() {
    // Load any saved progress for practice mode
    // This is where you'd load from local storage if implemented
    print('DEBUG: Loading saved progress...');
  }

  // ExamView interface implementations
  @override
  void showLoading() {
    setState(() {
      _isLoading = true;
    });
  }

  @override
  void hideLoading() {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void updateExamTime(Duration time) {
    setState(() {
      _examTime = time;
    });
  }

  @override
  void updatePeriodTime(Duration time) {
    setState(() {
      _periodTime = time;
    });
  }

  @override
  void updatePeriodInfo(String info) {
    setState(() {
      _currentPeriodInfo = info;
    });
  }

  @override
  void updateProgress(double progress) {
    setState(() {
      _progress = progress;
    });
  }
  
  String _getTutorialStepMessage() {
    if (widget.isPracticeMode && _currentTutorialStep <= _tutorialSteps.length) {
      return 'Step ${_currentTutorialStep}/11: ${_tutorialSteps[_currentTutorialStep - 1]}';
    }
    return _currentPeriodInfo.isNotEmpty ? _currentPeriodInfo : 
           (widget.isPracticeMode ? '자유롭게 연습하세요' : '1차: 매니큐어 - 기본 매니큐어');
  }
  
  void _onTutorialStepChanged(int newStep) {
    setState(() {
      _currentTutorialStep = newStep;
      // Update progress based on step completion
      _progress = (newStep - 1) / 11.0;
    });
    
    // Show feedback for step completion
    if (newStep - 1 >= 1 && newStep - 1 <= _tutorialSteps.length) {
      _feedbackController.showFeedback('${_tutorialSteps[newStep - 2]} 완료');
    }
    
    // Show special guide for step 2 (polish removal)
    if (newStep == 2) {
      Future.delayed(const Duration(milliseconds: 800), () {
        _feedbackController.showFeedback('네일을 꾹 누르고 문질러 주세요');
      });
    }
    
    if (newStep > 11) {
      // All steps completed
      _showTutorialCompleteDialog();
    }
  }
  
  void _showTutorialCompleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('🎉 튜토리얼 완료!'),
          content: const Text('11단계 튜토리얼을 모두 완료했습니다!\n계속해서 자유롭게 연습하시거나 홈으로 돌아가세요.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Reset tutorial to continue practicing
                setState(() {
                  _currentTutorialStep = 1;
                  _progress = 0.0;
                });
              },
              child: const Text('다시 연습'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Return to home
              },
              child: const Text('홈으로'),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildBannerAdsSection() {
    return const BannerAdWidget();
  }

  @override
  void showExamComplete(ExamSession session) {
    AppRouter.navigateAndReplace(
      context,
      AppRouter.results,
      arguments: session,
    );
  }

  @override
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}