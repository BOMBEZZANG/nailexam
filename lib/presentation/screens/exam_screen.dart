import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/exam_session.dart';
import '../../navigation/app_router.dart';
import '../presenters/exam_presenter.dart';
import '../widgets/common/loading_indicator.dart';

class ExamScreen extends StatefulWidget {
  final bool isPracticeMode;
  final String? sessionId;

  const ExamScreen({
    Key? key,
    required this.isPracticeMode,
    this.sessionId,
  }) : super(key: key);

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
  bool _isPaused = false;

  bool _didInitializePresenter = false;

  @override
  void initState() {
    super.initState();
    _presenter = ExamPresenter();
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
          title: Text(widget.isPracticeMode ? 'Practice Mode' : 'Exam Mode'),
          actions: [
            if (widget.isPracticeMode)
              IconButton(
                icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                onPressed: _togglePause,
              ),
          ],
        ),
        body: _isLoading
            ? const LoadingIndicator(message: 'Starting exam...')
            : _buildExamContent(),
      ),
    );
  }

  Widget _buildExamContent() {
    return Column(
      children: [
        _buildTimerSection(),
        _buildProgressBar(),
        _buildPeriodInfoCard(),
        Expanded(
          child: _buildWorkArea(),
        ),
        _buildControlsSection(),
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
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
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
        Icon(
          icon,
          size: 24,
          color: Theme.of(context).primaryColor,
        ),
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
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
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
              Text(
                'Overall Progress',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '${(_progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
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
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            children: [
              Text(
                _currentPeriodInfo.isNotEmpty 
                    ? _currentPeriodInfo 
                    : 'Getting ready...',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (_isPaused) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'PAUSED',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkArea() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 2,
        ),
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
                Icon(
                  Icons.touch_app,
                  size: 64,
                  color: Colors.grey,
                ),
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
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
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
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _showExitDialog,
              icon: const Icon(Icons.exit_to_app),
              label: const Text('Exit'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _completePeriod,
              icon: const Icon(Icons.check),
              label: const Text('Complete Period'),
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

  void _togglePause() {
    if (_isPaused) {
      _presenter.resumeExam();
    } else {
      _presenter.pauseExam();
    }
  }

  void _completePeriod() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Period'),
        content: const Text(
          'Are you sure you want to complete this period? '
          'You cannot return to make changes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _presenter.completePeriod();
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }


  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Exam'),
        content: Text(
          widget.isPracticeMode
              ? 'Your progress will be saved and you can resume later.'
              : 'Exiting will abandon the exam. All progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              AppRouter.navigateAndRemoveUntil(
                context,
                AppRouter.home,
                (route) => false,
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(widget.isPracticeMode ? 'Save & Exit' : 'Abandon'),
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
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  void showPeriodInfo(int periodNumber, String technique) {
    setState(() {
      _currentPeriodInfo = 'Period $periodNumber: $technique';
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

  @override
  void enablePauseResume(bool isPaused) {
    setState(() {
      _isPaused = isPaused;
    });
  }
}