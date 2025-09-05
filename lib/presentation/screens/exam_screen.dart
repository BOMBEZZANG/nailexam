import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../controllers/gesture_controller.dart';
import '../../data/models/exam_session.dart';
import '../../data/models/tool.dart';
import '../../data/models/exam_progress.dart';
import '../../navigation/app_router.dart';
import '../presenters/exam_presenter.dart';
import '../widgets/common/loading_indicator.dart';
import '../widgets/exam/isometric_work_area.dart';
import '../widgets/exam/tool_tray.dart';
import '../widgets/exam/color_palette.dart';
import '../widgets/exam/feedback_overlay.dart';
import '../../managers/exam_progress_manager.dart';

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

    return Row(
      children: [
        // Left panel - Controls and information
        SizedBox(
          width: 320,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Timer section hidden for both modes (can be shown later if needed)
                // _buildTimerSection(),
                // Progress bar hidden for both modes (already in app bar for practice mode)
                // _buildProgressBar(),
                // Show period info card for both modes (exam mode shows "시험모드입니다")
                _buildPeriodInfoCard(),
                // Score display for exam mode
                if (!widget.isPracticeMode) _buildScoreDisplay(),
                // Main UI: Tools and Palette - same for both modes
                // Show either palette or tools in the same space
                if (_showColorPalette || _showToolTray)
                  SizedBox(
                    height: _showColorPalette
                        ? 200
                        : 120, // Smaller height for tool tray
                    child: _showColorPalette
                        ? ColorPalette(
                            onColorSelected: _onColorSelected,
                            selectedColor: _selectedColor,
                            isVisible: _showColorPalette,
                          )
                        : ToolTray(
                            onToolSelected: _onToolSelected,
                            selectedTool: _selectedTool,
                            selectedTools: _selectedTools,
                            isVisible: _showToolTray,
                            isHorizontal:
                                true, // Horizontal layout in left panel
                            requiredTools: widget.isPracticeMode
                                ? (_workAreaKey.currentState
                                          ?.getRequiredToolsForCurrentStep() ??
                                      {})
                                : {}, // No tool highlighting in exam mode
                          ),
                  ),
                const SizedBox(height: 16),
                // Use compact controls for both modes
                _buildCompactControls(),
              ],
            ),
          ),
        ),

        // Right side - Main work area
        Expanded(child: _buildIsometricWorkArea()),
      ],
    );
  }

  Widget _buildTimerSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTimerCard(
            'Exam Time',
            _formatDuration(_examTime),
            Icons.schedule,
          ),
          _buildTimerCard(
            'Period Time',
            _formatDuration(_periodTime),
            Icons.timer,
          ),
        ],
      ),
    );
  }

  Widget _buildTimerCard(String label, String time, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).primaryColor),
        const SizedBox(height: 4),
        Text(
          time,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('전체 진행과정', style: Theme.of(context).textTheme.bodySmall),
              Text(
                '${(_progress * 100).toInt()}%',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: _progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodInfoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: 4,
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            children: [
              Text(
                _currentPeriodInfo.isNotEmpty ? _currentPeriodInfo : '준비 중...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreDisplay() {
    // Calculate current progress score based on completed steps
    int currentScore = 0;
    final workAreaState = _workAreaKey.currentState;

    if (workAreaState != null) {
      currentScore = workAreaState.getCurrentScore();
    }

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: 4,
      ),
      child: Card(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '현재 점수:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                '$currentScore/11',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactControls() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: 8,
      ),
      child: Row(
        children: [
          // Toggle buttons (compact) - only one can be active at a time
          IconButton(
            onPressed: () => setState(() {
              _showColorPalette = false;
              _showToolTray = true;
            }),
            icon: Icon(
              Icons.build,
              color: _showToolTray
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
              size: 20,
            ),
            tooltip: '도구 트레이',
          ),
          IconButton(
            onPressed: () => setState(() {
              _showColorPalette = true;
              _showToolTray = false;
            }),
            icon: Icon(
              Icons.palette,
              color: _showColorPalette
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
              size: 20,
            ),
            tooltip: '색상 팔레트',
          ),
          const Spacer(),
          // Compact exit and complete buttons
          TextButton(
            onPressed: _showExitDialog,
            child: const Text('나가기', style: TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _completePeriod,
            child: const Text('완료', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkArea() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor, width: 2),
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        child: Container(
          color: Colors.grey[50],
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.touch_app, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Work Area',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Isometric view and tools will be implemented in Phase 2',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIsometricWorkArea() {
    print(
      'DEBUG: Building isometric work area for ${widget.isPracticeMode ? "Practice" : "Exam"} mode',
    );

    return Container(
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor, width: 2),
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        child: IsometricWorkArea(
          key: _workAreaKey,
          onDragUpdate: _onDragUpdate,
          onToolApplied: _onToolApplied,
          onGesture: _onGesture,
          currentTool: _selectedTool,
          selectedTools: _selectedTools,
          currentPolishColor: _selectedColor,
          isPracticeMode: widget.isPracticeMode,
          onExamCompleted: widget.isPracticeMode ? null : _onExamCompleted,
        ),
      ),
    );
  }

  Widget _buildControlsSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _showExitDialog,
              icon: const Icon(Icons.exit_to_app),
              label: const Text('나가기'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => setState(() {
              _showColorPalette = false;
              _showToolTray = true;
            }),
            icon: Icon(
              Icons.build,
              color: _showToolTray
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
            ),
            tooltip: '도구 트레이',
          ),
          IconButton(
            onPressed: () => setState(() {
              _showColorPalette = true;
              _showToolTray = false;
            }),
            icon: Icon(
              Icons.palette,
              color: _showColorPalette
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
            ),
            tooltip: '색상 팔레트',
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _completePeriod,
              icon: const Icon(Icons.check),
              label: const Text('구간 완료'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
  }

  void _completePeriod() {
    // Get current progress from work area
    final workAreaState = _workAreaKey.currentState;
    List<String> completedSteps = [];
    List<String> remainingSteps = [];
    int currentScore = 0;

    if (workAreaState != null) {
      currentScore = workAreaState.getCurrentScore();
      final stepStatus = workAreaState.getStepCompletionStatus();

      // Categorize steps as completed or remaining
      stepStatus.forEach((stepName, isCompleted) {
        if (isCompleted) {
          completedSteps.add(stepName);
        } else {
          remainingSteps.add(stepName);
        }
      });
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('완료 확인'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '현재 진행 상황:',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '완료된 단계: $currentScore/11',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              if (completedSteps.isNotEmpty) ...[
                Text(
                  '✅ 완료한 단계:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                ...completedSteps.map(
                  (step) => Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 2),
                    child: Text(
                      step,
                      style: TextStyle(color: Colors.green.shade600),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              if (remainingSteps.isNotEmpty) ...[
                Text(
                  '⏳ 남은 단계:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                ...remainingSteps.map(
                  (step) => Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 2),
                    child: Text(
                      step,
                      style: TextStyle(color: Colors.orange.shade600),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              const Text(
                '정말로 완료하시겠습니까?\n완료 후에는 수정할 수 없습니다.',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _presenter.completePeriod();
            },
            child: const Text('완료'),
          ),
        ],
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.isPracticeMode ? '연습 끝내기' : '시험 끝내기'),
        content: Text(
          widget.isPracticeMode ? '정말 연습을 끝내겠습니까?' : '정말 시험을 끝내겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('계속하기'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _saveAndExit();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('저장하고 나가기'),
          ),
        ],
      ),
    );
  }

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
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  void updateTimer(Duration examTime, Duration periodTime) {
    setState(() {
      _examTime = examTime;
      _periodTime = periodTime;
    });
  }

  @override
  void showTimeWarning(String message) {
    // Time warning messages disabled - no longer showing time remaining notifications
  }

  @override
  void showPeriodInfo(int periodNumber, String technique) {
    setState(() {
      _currentPeriodInfo = '1과제 (매니큐어/오른손) 30분 / 20점';
    });
  }

  @override
  void updateProgress(double progress) {
    setState(() {
      _progress = progress;
    });
  }

  @override
  void navigateToResults(ExamSession session) {
    AppRouter.navigateAndReplace(
      context,
      AppRouter.results,
      arguments: session,
    );
  }

  // Phase 2 callback methods
  void _onToolSelected(Tool tool) {
    setState(() {
      // Handle special multi-tool selection for polish removal
      if (tool.type == ToolType.remover || tool.type == ToolType.cottonPad) {
        // Toggle tool in the selected set
        if (_selectedTools.contains(tool)) {
          _selectedTools.remove(tool);
        } else {
          _selectedTools.add(tool);
        }

        // Check if both remover and cotton pad are selected
        final hasRemover = _selectedTools.any(
          (t) => t.type == ToolType.remover,
        );
        final hasCottonPad = _selectedTools.any(
          (t) => t.type == ToolType.cottonPad,
        );

        if (hasRemover && hasCottonPad) {
          // Both tools selected - create a combined tool
          _selectedTool = tool; // Keep reference to last selected tool
        } else {
          _selectedTool = null; // Clear single tool selection
        }
      } else {
        // Normal single tool selection
        _selectedTool = tool;
        _selectedTools.clear(); // Clear multi-selection
      }
    });
    // Removed feedback modal - just update selection silently
  }

  void _onColorSelected(Color color) {
    setState(() {
      _selectedColor = color;
    });
    // Removed feedback modal - just update selection silently
  }

  void _onDragUpdate(Offset position) {
    // Handle drag updates for real-time feedback
    // This could show drag path or update tool preview
  }

  void _onToolApplied(Tool tool) {
    // Update progress based on tool application
    // In a real implementation, this would calculate progress from work area state
    setState(() {
      _progress = (_progress + 0.05).clamp(0.0, 1.0);
      // Force refresh to update required tools highlighting
    });

    // Removed feedback modals - no visual feedback when clicking nails
  }

  void _onGesture(GestureType type, Offset position) {
    // Handle different gesture types
    switch (type) {
      case GestureType.tap:
        // Handle tap gesture
        break;
      case GestureType.drag:
        // Handle drag gesture
        break;
      case GestureType.dragStart:
        // Handle drag start gesture
        break;
      case GestureType.dragEnd:
        // Handle drag end gesture
        break;
      case GestureType.pinch:
        // Handle pinch/zoom gesture
        break;
      case GestureType.swipe:
        // Handle swipe gesture
        break;
      case GestureType.longPress:
        // Handle long press gesture
        break;
      case GestureType.doubleTab:
        // Handle double tap gesture
        break;
    }
  }

  Future<void> _loadSavedProgress() async {
    try {
      final savedProgress = await ExamProgressManager.instance.loadProgress(
        isPracticeMode: widget.isPracticeMode,
      );

      if (savedProgress != null) {
        // Show dialog asking if user wants to continue from saved progress
        if (mounted) {
          _showLoadProgressDialog(savedProgress);
        }
      }
    } catch (e) {
      print('Error loading saved progress: $e');
    }
  }

  void _showLoadProgressDialog(ExamProgress savedProgress) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('저장된 진행상황'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('저장된 진행상황이 있습니다.'),
            const SizedBox(height: 8),
            Text('점수: ${savedProgress.currentScore}/11'),
            Text('저장 시간: ${_formatDateTime(savedProgress.savedAt)}'),
            const SizedBox(height: 8),
            const Text('계속하시겠습니까?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Start fresh
            },
            child: const Text('새로 시작'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _restoreProgress(savedProgress);
            },
            child: const Text('이어서 하기'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _restoreProgress(ExamProgress progress) {
    final workAreaState = _workAreaKey.currentState;
    if (workAreaState != null) {
      workAreaState.restoreProgress(progress);
      setState(() {}); // Refresh UI
    }
  }

  Future<void> _saveAndExit() async {
    try {
      final workAreaState = _workAreaKey.currentState;
      if (workAreaState != null) {
        final currentProgress = workAreaState.saveCurrentProgress();
        await ExamProgressManager.instance.saveProgress(currentProgress);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('진행상황이 저장되었습니다'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }

      // Navigate to home
      AppRouter.navigateAndRemoveUntil(
        context,
        AppRouter.home,
        (route) => false,
      );
    } catch (e) {
      print('Error saving progress: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('저장에 실패했습니다'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onExamCompleted(
    int score,
    List<String> completedSteps,
    List<String> missedSteps,
  ) {
    setState(() {
      _examScore = score;
      _completedSteps = completedSteps;
      _missedSteps = missedSteps;
    });

    // Clear saved progress since exam is completed
    ExamProgressManager.instance.clearProgress(
      isPracticeMode: widget.isPracticeMode,
    );

    // Show exam completion dialog with results
    _showExamResultsDialog();
  }

  void _showExamResultsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('시험 완료!'),
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
}
