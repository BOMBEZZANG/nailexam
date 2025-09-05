import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/exam_constants.dart';
import '../../data/models/exam_session.dart';
import '../../navigation/app_router.dart';

class ResultsScreen extends StatelessWidget {
  final ExamSession session;

  const ResultsScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Results'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildScoreCard(context),
            const SizedBox(height: 24),
            _buildOverviewCard(context),
            const SizedBox(height: 24),
            _buildPerformanceBreakdown(context),
            const SizedBox(height: 24),
            _buildPeriodResults(context),
            const SizedBox(height: 32),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(BuildContext context) {
    final score = session.totalScore;
    final grade = _getGrade(score);
    final color = _getScoreColor(score);

    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          ),
        ),
        child: Column(
          children: [
            Text(
              session.isPracticeMode ? 'Practice Complete!' : 'Exam Complete!',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.1),
                border: Border.all(color: color, width: 3),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${score.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold, color: color),
                    ),
                    Text(
                      'Grade $grade',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _getScoreMessage(score),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(BuildContext context) {
    final duration = session.elapsedTime;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Session Overview',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildOverviewItem(
                    context,
                    Icons.access_time,
                    'Duration',
                    _formatDuration(duration),
                  ),
                ),
                Expanded(
                  child: _buildOverviewItem(
                    context,
                    Icons.layers,
                    'Periods',
                    '${session.completedPeriods}/${ExamConstants.totalPeriods}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildOverviewItem(
                    context,
                    Icons.school,
                    'Mode',
                    session.isPracticeMode ? 'Practice' : 'Exam',
                  ),
                ),
                Expanded(
                  child: _buildOverviewItem(
                    context,
                    Icons.calendar_today,
                    'Date',
                    _formatDate(session.startTime),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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

  Widget _buildPerformanceBreakdown(BuildContext context) {
    // Calculate average scores for breakdown
    final avgScores = <String, double>{};
    for (var key in ExamConstants.scoreWeights.keys) {
      double total = 0.0;
      int count = 0;

      for (var period in session.periodResults.values) {
        if (period.scoreBreakdown.containsKey(key)) {
          total += period.scoreBreakdown[key]!;
          count++;
        }
      }

      avgScores[key] = count > 0 ? total / count : 0.0;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Breakdown',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...avgScores.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildScoreBar(
                  context,
                  _getCategoryName(entry.key),
                  entry.value,
                  ExamConstants.scoreWeights[entry.key]! * 100,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBar(
    BuildContext context,
    String label,
    double score,
    double weight,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$label (${weight.toInt()}%)',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            Text(
              '${score.toStringAsFixed(1)}%',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: score / 100,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(score)),
        ),
      ],
    );
  }

  Widget _buildPeriodResults(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Period Results',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...session.periodResults.entries.map((entry) {
              final period = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getScoreColor(period.score),
                    child: Text(
                      '${period.periodNumber}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    ExamConstants.periodNames[period.periodNumber] ??
                        'Period ${period.periodNumber}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    ExamConstants.techniqueDisplayNames[period
                            .assignedTechnique] ??
                        period.assignedTechnique,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${period.score.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (period.duration != null)
                        Text(
                          _formatDuration(period.duration!),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () => _goHome(context),
          icon: const Icon(Icons.home),
          label: const Text('Return to Home'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (session.isPracticeMode)
          OutlinedButton.icon(
            onPressed: () => _startAgain(context, true),
            icon: const Icon(Icons.school),
            label: const Text('Practice Again'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
              ),
            ),
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _startAgain(context, false),
          icon: const Icon(Icons.quiz),
          label: const Text('Take Exam'),
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

  String _getGrade(double score) {
    if (score >= 90) return 'A';
    if (score >= 80) return 'B';
    if (score >= 70) return 'C';
    if (score >= 60) return 'D';
    return 'F';
  }

  Color _getScoreColor(double score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.lightGreen;
    if (score >= 70) return Colors.orange;
    if (score >= 60) return Colors.deepOrange;
    return Colors.red;
  }

  String _getScoreMessage(double score) {
    if (score >= 90)
      return 'Excellent performance! You\'re ready for the real exam.';
    if (score >= 80) return 'Good job! Keep practicing to improve further.';
    if (score >= 70) return 'Not bad, but there\'s room for improvement.';
    if (score >= 60) return 'You need more practice to pass the exam.';
    return 'Keep practicing! Focus on technique and timing.';
  }

  String _getCategoryName(String key) {
    switch (key) {
      case 'sequence':
        return 'Sequence Accuracy';
      case 'timing':
        return 'Time Management';
      case 'hygiene':
        return 'Hygiene Protocol';
      case 'technique':
        return 'Technique Quality';
      default:
        return key;
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m ${seconds}s';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _goHome(BuildContext context) {
    AppRouter.navigateAndRemoveUntil(context, AppRouter.home, (route) => false);
  }

  void _startAgain(BuildContext context, bool isPracticeMode) {
    AppRouter.navigateAndRemoveUntil(
      context,
      AppRouter.examSetup,
      (route) => false,
      arguments: {'isPracticeMode': isPracticeMode},
    );
  }
}
