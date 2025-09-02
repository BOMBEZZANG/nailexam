import '../../core/utils/logger.dart';
import '../../data/models/exam_session.dart';
import '../../managers/game_manager.dart';
import '../../managers/local_storage_manager.dart';
import 'base_presenter.dart';

abstract class HomeView extends BaseView {
  void showSessionHistory(List<ExamSession> sessions);
  void navigateToExam(bool isPracticeMode);
  void showResumeOption(ExamSession session);
  void updateStats(int totalSessions, double highScore);
}

class HomePresenter extends BasePresenter<HomeView> {
  final GameManager _gameManager = GameManager.instance;
  final LocalStorageManager _storageManager = LocalStorageManager.instance;
  
  @override
  void onViewAttached() {
    super.onViewAttached();
    _loadInitialData();
  }
  
  Future<void> _loadInitialData() async {
    try {
      view?.showLoading();
      
      await _checkForActiveSession();
      await _loadStats();
      await loadSessionHistory();
      
      view?.hideLoading();
    } catch (e) {
      Logger.e('Failed to load initial data', error: e);
      view?.hideLoading();
      view?.showError('Failed to load data');
    }
  }
  
  Future<void> _checkForActiveSession() async {
    final activeSession = _gameManager.currentSession;
    if (activeSession != null && activeSession.status != ExamStatus.completed) {
      view?.showResumeOption(activeSession);
    }
  }
  
  Future<void> _loadStats() async {
    final totalSessions = _storageManager.getIntSetting(
      'total_sessions_completed',
      defaultValue: 0,
    );
    
    final highScore = _storageManager.getDoubleSetting(
      'practice_high_score',
      defaultValue: 0.0,
    );
    
    view?.updateStats(totalSessions, highScore);
  }
  
  Future<void> loadSessionHistory() async {
    try {
      final sessions = await _gameManager.getSessionHistory();
      view?.showSessionHistory(sessions);
    } catch (e) {
      Logger.e('Failed to load session history', error: e);
      view?.showError('Failed to load history');
    }
  }
  
  void startNewExam(bool isPracticeMode) {
    try {
      if (_gameManager.hasActiveSession) {
        view?.showError('Please complete or abandon current session first');
        return;
      }
      
      view?.navigateToExam(isPracticeMode);
    } catch (e) {
      Logger.e('Failed to start new exam', error: e);
      view?.showError('Failed to start exam');
    }
  }
  
  void resumeExam() {
    if (_gameManager.currentSession != null) {
      _gameManager.resumeSession();
      view?.navigateToExam(_gameManager.currentSession!.isPracticeMode);
    }
  }
  
  void abandonCurrentSession() {
    try {
      _gameManager.abandonSession();
      view?.showSuccess('Session abandoned');
      _loadInitialData();
    } catch (e) {
      Logger.e('Failed to abandon session', error: e);
      view?.showError('Failed to abandon session');
    }
  }
  
  Future<void> clearAllData() async {
    try {
      view?.showLoading();
      await _storageManager.clearAll();
      _gameManager.reset();
      view?.hideLoading();
      view?.showSuccess('All data cleared');
      _loadInitialData();
    } catch (e) {
      Logger.e('Failed to clear data', error: e);
      view?.hideLoading();
      view?.showError('Failed to clear data');
    }
  }
}