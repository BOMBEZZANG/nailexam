import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/exam_constants.dart';
import '../../navigation/app_router.dart';

class ExamSetupScreen extends StatefulWidget {
  final bool isPracticeMode;

  const ExamSetupScreen({super.key, required this.isPracticeMode});

  @override
  State<ExamSetupScreen> createState() => _ExamSetupScreenState();
}

class _ExamSetupScreenState extends State<ExamSetupScreen> {
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _showInstructions = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isPracticeMode ? 'Practice Setup' : 'Exam Setup'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildModeCard(),
            const SizedBox(height: 24),
            _buildExamInfoCard(),
            const SizedBox(height: 24),
            _buildSettingsCard(),
            if (_showInstructions) ...[
              const SizedBox(height: 24),
              _buildInstructionsCard(),
            ],
            const SizedBox(height: 32),
            _buildStartButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildModeCard() {
    return Card(
      color: widget.isPracticeMode
          ? Colors.blue.shade50
          : Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            Icon(
              widget.isPracticeMode ? Icons.school : Icons.quiz,
              size: 48,
              color: widget.isPracticeMode
                  ? Colors.blue.shade600
                  : Colors.orange.shade600,
            ),
            const SizedBox(height: 12),
            Text(
              widget.isPracticeMode ? 'Practice Mode' : 'Exam Mode',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: widget.isPracticeMode
                    ? Colors.blue.shade700
                    : Colors.orange.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.isPracticeMode
                  ? 'Learn and practice without time pressure'
                  : 'Full exam simulation with strict timing',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exam Structure',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.schedule,
              'Total Duration',
              '${ExamConstants.totalExamDuration.inHours}h ${ExamConstants.totalExamDuration.inMinutes.remainder(60)}m',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.layers,
              'Number of Periods',
              '${ExamConstants.totalPeriods} periods',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.timer,
              'Period Duration',
              '${ExamConstants.periodDuration.inMinutes} minutes each',
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Periods Overview:',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...ExamConstants.periodNames.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '${entry.key}. ${entry.value}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildSettingsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Sound Notifications'),
              subtitle: const Text('Audio alerts for time warnings'),
              value: _soundEnabled,
              onChanged: (value) {
                setState(() {
                  _soundEnabled = value;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Vibration'),
              subtitle: const Text('Haptic feedback for interactions'),
              value: _vibrationEnabled,
              onChanged: (value) {
                setState(() {
                  _vibrationEnabled = value;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Show Instructions'),
              subtitle: const Text('Display technique guidance'),
              value: _showInstructions,
              onChanged: (value) {
                setState(() {
                  _showInstructions = value;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Card(
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber.shade700),
                const SizedBox(width: 8),
                Text(
                  'Instructions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.isPracticeMode
                  ? '• Take your time to learn each technique\n'
                        '• Use pause feature if needed\n'
                        '• Review feedback after each period\n'
                        '• Focus on proper sequence and hygiene'
                  : '• Complete all 5 periods within time limits\n'
                        '• Follow proper technique sequences\n'
                        '• Maintain hygiene protocols\n'
                        '• No pausing allowed during exam',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return ElevatedButton.icon(
      onPressed: _startExam,
      icon: const Icon(Icons.play_arrow),
      label: Text(widget.isPracticeMode ? 'Start Practice' : 'Begin Exam'),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
        backgroundColor: widget.isPracticeMode
            ? Colors.blue.shade600
            : Colors.orange.shade600,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _startExam() {
    AppRouter.navigateAndReplace(
      context,
      AppRouter.exam,
      arguments: {
        'isPracticeMode': widget.isPracticeMode,
        'soundEnabled': _soundEnabled,
        'vibrationEnabled': _vibrationEnabled,
        'showInstructions': _showInstructions,
      },
    );
  }
}
