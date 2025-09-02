import 'dart:math';
import '../core/constants/exam_constants.dart';
import '../core/errors/app_exceptions.dart';
import '../core/utils/id_generator.dart';
import '../core/utils/logger.dart';
import '../data/models/exam_session.dart';
import '../data/models/period_data.dart';
import '../data/models/action_log.dart';
import 'local_storage_manager.dart';

class GameManager {
  static final GameManager _instance = GameManager._internal();
  static GameManager get instance => _instance;
  
  GameManager._internal();
  
  ExamSession? _currentSession;
  final Random _random = Random();
  
  ExamSession? get currentSession => _currentSession;
  bool get hasActiveSession => _currentSession != null && 
      _currentSession!.status == ExamStatus.inProgress;
  
  void initialize() {
    Logger.i('GameManager initializing...');
    _loadSavedSession();
  }
  
  Future<void> _loadSavedSession() async {
    try {
      final saved = await LocalStorageManager.instance.loadSession();
      if (saved != null && saved.status != ExamStatus.completed) {
        _currentSession = saved;
        Logger.i('Loaded saved session: ${saved.sessionId}');
      }
    } catch (e) {
      Logger.e('Failed to load saved session', error: e);
    }
  }
  
  ExamSession startNewSession({bool isPractice = false}) {
    if (hasActiveSession) {
      throw SessionException('Cannot start new session while one is active');
    }
    
    _currentSession = ExamSession(
      sessionId: IdGenerator.generateSessionId(),
      startTime: DateTime.now(),
      isPracticeMode: isPractice,
      status: ExamStatus.inProgress,
    );
    
    Logger.i('Started new session: ${_currentSession!.sessionId}');
    LocalStorageManager.instance.saveSession(_currentSession!);
    return _currentSession!;
  }
  
  void pauseSession() {
    if (_currentSession == null) {
      throw SessionException('No active session to pause');
    }
    
    _currentSession!.status = ExamStatus.paused;
    LocalStorageManager.instance.saveSession(_currentSession!);
    Logger.i('Session paused: ${_currentSession!.sessionId}');
  }
  
  void resumeSession() {
    if (_currentSession == null) {
      throw SessionException('No active session to resume');
    }
    
    _currentSession!.status = ExamStatus.inProgress;
    LocalStorageManager.instance.saveSession(_currentSession!);
    Logger.i('Session resumed: ${_currentSession!.sessionId}');
  }
  
  void abandonSession() {
    if (_currentSession == null) {
      throw SessionException('No active session to abandon');
    }
    
    _currentSession!.status = ExamStatus.abandoned;
    LocalStorageManager.instance.saveSession(_currentSession!);
    Logger.i('Session abandoned: ${_currentSession!.sessionId}');
    _currentSession = null;
  }
  
  String getRandomTechnique(int period) {
    final techniques = ExamConstants.periodTechniques[period];
    if (techniques == null || techniques.isEmpty) {
      throw ValidationException('No techniques defined for period $period');
    }
    
    final technique = techniques[_random.nextInt(techniques.length)];
    Logger.d('Selected technique for period $period: $technique');
    return technique;
  }
  
  void startPeriod(int periodNumber) {
    if (_currentSession == null) {
      throw SessionException('No active session');
    }
    
    if (periodNumber < 1 || periodNumber > ExamConstants.totalPeriods) {
      throw ValidationException('Invalid period number: $periodNumber');
    }
    
    final technique = getRandomTechnique(periodNumber);
    _currentSession!.startPeriod(periodNumber, technique);
    
    LocalStorageManager.instance.saveSession(_currentSession!);
    Logger.i('Started period $periodNumber with technique: $technique');
  }
  
  void endPeriod(int periodNumber, Map<String, double> scores) {
    if (_currentSession == null) {
      throw SessionException('No active session');
    }
    
    final periodData = _currentSession!.periodResults[periodNumber];
    if (periodData == null) {
      throw SessionException('Period $periodNumber not started');
    }
    
    _currentSession!.completePeriod(periodNumber, scores);
    
    LocalStorageManager.instance.saveSession(_currentSession!);
    Logger.i('Ended period $periodNumber with score: ${periodData.score}');
  }
  
  void logAction(String actionType, {Map<String, dynamic>? data}) {
    if (_currentSession == null) return;
    
    final currentPeriod = _currentSession!.currentPeriod;
    final periodData = _currentSession!.periodResults[currentPeriod];
    
    if (periodData != null) {
      final action = ActionLog(
        actionType: actionType,
        timestamp: DateTime.now(),
        data: data,
      );
      periodData.addAction(action);
      Logger.d('Action logged: $actionType');
    }
  }
  
  Future<List<ExamSession>> getSessionHistory() async {
    try {
      final history = await LocalStorageManager.instance.getSessionHistory();
      return history.values.toList()
        ..sort((a, b) => b.startTime.compareTo(a.startTime));
    } catch (e) {
      Logger.e('Failed to get session history', error: e);
      return [];
    }
  }
  
  void reset() {
    _currentSession = null;
    Logger.i('GameManager reset');
  }
}