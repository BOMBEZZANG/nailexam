import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/exam_session.dart';
import '../../navigation/app_router.dart';
import '../presenters/home_presenter.dart';
import '../widgets/common/loading_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> implements HomeView {
  late HomePresenter _presenter;
  bool _isLoading = false;
  List<ExamSession> _sessionHistory = [];
  ExamSession? _activeSession;
  int _totalSessions = 0;
  double _highScore = 0.0;

  @override
  void initState() {
    super.initState();
    _presenter = HomePresenter();
    _presenter.attachView(this);
  }

  @override
  void dispose() {
    _presenter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        centerTitle: true,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading...')
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildWelcomeSection(),
          const SizedBox(height: 24),
          _buildActiveSessionCard(),
          const SizedBox(height: 24),
          _buildActionButtons(),
          const SizedBox(height: 24),
          _buildStatsCard(),
          const SizedBox(height: 24),
          _buildHistorySection(),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to Nail Exam Simulator',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Practice and perfect your nail technician skills',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSessionCard() {
    if (_activeSession == null) return const SizedBox.shrink();

    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                Text(
                  'Active Session',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'You have an incomplete ${_activeSession!.isPracticeMode ? 'practice' : 'exam'} session.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _presenter.resumeExam(),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Resume'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _showAbandonDialog(),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Abandon'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: _activeSession != null ? null : () => _startExam(false),
          icon: const Icon(Icons.quiz),
          label: const Text('Start Exam'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _activeSession != null ? null : () => _startExam(true),
          icon: const Icon(Icons.school),
          label: const Text('Practice Mode'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Progress',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Sessions\nCompleted',
                    _totalSessions.toString(),
                    Icons.check_circle,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Practice\nHigh Score',
                    '${_highScore.toStringAsFixed(1)}%',
                    Icons.star,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildHistorySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Sessions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_sessionHistory.isNotEmpty)
                  TextButton(
                    onPressed: () => _showClearDataDialog(),
                    child: const Text('Clear All'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _sessionHistory.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No sessions yet'),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _sessionHistory.take(5).length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final session = _sessionHistory[index];
                      return _buildHistoryItem(session);
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(ExamSession session) {
    return ListTile(
      dense: true,
      leading: Icon(
        session.isPracticeMode ? Icons.school : Icons.quiz,
        color: session.status == ExamStatus.completed 
            ? Colors.green 
            : Colors.grey,
      ),
      title: Text(
        session.isPracticeMode ? 'Practice Session' : 'Exam Session',
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        '${_formatDate(session.startTime)} • '
        '${session.status == ExamStatus.completed ? '${session.totalScore.toStringAsFixed(1)}%' : 'Incomplete'}',
      ),
      trailing: session.status == ExamStatus.completed
          ? Icon(Icons.check_circle, color: Colors.green.shade600)
          : Icon(Icons.cancel, color: Colors.grey.shade600),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _startExam(bool isPracticeMode) {
    AppRouter.navigateTo(
      context,
      AppRouter.examSetup,
      arguments: {'isPracticeMode': isPracticeMode},
    );
  }

  void _showAbandonDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abandon Session'),
        content: const Text(
          'Are you sure you want to abandon the current session? '
          'All progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _presenter.abandonCurrentSession();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Abandon'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all session history and settings. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _presenter.clearAllData();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
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
  void showSessionHistory(List<ExamSession> sessions) {
    setState(() {
      _sessionHistory = sessions;
    });
  }

  @override
  void navigateToExam(bool isPracticeMode) {
    AppRouter.navigateTo(
      context,
      AppRouter.exam,
      arguments: {'isPracticeMode': isPracticeMode},
    );
  }

  @override
  void showResumeOption(ExamSession session) {
    setState(() {
      _activeSession = session;
    });
  }

  @override
  void updateStats(int totalSessions, double highScore) {
    setState(() {
      _totalSessions = totalSessions;
      _highScore = highScore;
    });
  }
}