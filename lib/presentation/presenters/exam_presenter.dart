import '../../core/constants/exam_constants.dart';
import '../../core/utils/logger.dart';
import '../../data/models/exam_session.dart';
import '../../managers/game_manager.dart';
import '../../managers/timer_manager.dart';
import 'base_presenter.dart';

abstract class ExamView extends BaseView {
  void updateTimer(Duration examTime, Duration periodTime);
  void showTimeWarning(String message);
  void showPeriodInfo(int periodNumber, String technique);
  void updateProgress(double progress);
  void navigateToResults(ExamSession session);
}

class ExamPresenter extends BasePresenter<ExamView> {
  final GameManager _gameManager = GameManager.instance;
  final TimerManager _timerManager = TimerManager.instance;

  ExamSession? _currentSession;

  @override
  void onViewAttached() {
    super.onViewAttached();
    _initializeExam();
    _setupTimerListeners();
  }

  void _initializeExam() {
    _currentSession = _gameManager.currentSession;

    // If there's no current session, that's okay - startExam will create one
    if (_currentSession == null) {
      return;
    }

    _updatePeriodInfo();
    _updateProgress();
  }

  void _setupTimerListeners() {
    _timerManager.examTimeStream.listen((duration) {
      view?.updateTimer(duration, _timerManager.periodElapsed);
    });

    _timerManager.periodTimeStream.listen((duration) {
      view?.updateTimer(_timerManager.examElapsed, duration);
    });

    // Time warning notifications disabled
    // _timerManager.warningStream.listen((warning) {
    //   view?.showTimeWarning(warning.message);
    // });
  }

  void startExam({bool isPracticeMode = false}) {
    try {
      _currentSession ??= _gameManager.startNewSession(
        isPractice: isPracticeMode,
      );

      _timerManager.startExamTimer();
      startPeriod(1);

      // Removed 'Exam started' message
    } catch (e) {
      Logger.e('Failed to start exam', error: e);
      view?.showError('Failed to start exam');
    }
  }

  void startPeriod(int periodNumber) {
    try {
      _gameManager.startPeriod(periodNumber);
      _timerManager.startPeriodTimer();

      _updatePeriodInfo();
      _updateProgress();

      Logger.i('Started period $periodNumber');
    } catch (e) {
      Logger.e('Failed to start period $periodNumber', error: e);
      view?.showError('Failed to start period');
    }
  }

  void completePeriod() {
    if (_currentSession == null) return;

    final currentPeriod = _currentSession!.currentPeriod;

    final scores = _calculateScores();
    _gameManager.endPeriod(currentPeriod, scores);

    _timerManager.stopPeriodTimer();

    if (_currentSession!.isComplete) {
      _completeExam();
    } else {
      startPeriod(currentPeriod + 1);
    }
  }

  Map<String, double> _calculateScores() {
    return {
      'sequence': 85.0,
      'timing': 90.0,
      'hygiene': 95.0,
      'technique': 88.0,
    };
  }

  void _completeExam() {
    _timerManager.stopAll();

    if (_currentSession != null) {
      view?.showSuccess('Exam completed!');
      view?.navigateToResults(_currentSession!);
    }
  }

  void logUserAction(String actionType, {Map<String, dynamic>? data}) {
    _gameManager.logAction(actionType, data: data);
  }

  void _updatePeriodInfo() {
    if (_currentSession == null) return;

    final periodData = _currentSession!.getCurrentPeriod();
    if (periodData != null) {
      final periodName =
          ExamConstants.periodNames[periodData.periodNumber] ?? 'Unknown';
      final techniqueName =
          ExamConstants.techniqueDisplayNames[periodData.assignedTechnique] ??
          periodData.assignedTechnique;

      view?.showPeriodInfo(
        periodData.periodNumber,
        '$periodName - $techniqueName',
      );
    }
  }

  void _updateProgress() {
    if (_currentSession != null) {
      view?.updateProgress(_currentSession!.progressPercentage);
    }
  }

  @override
  void onViewDetached() {
    super.onViewDetached();
  }
}
