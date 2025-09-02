# Phase 1: Core Framework Setup - Detailed Development Specification

## Phase Overview
Establish the foundational architecture and core systems for the Nail Technician Exam Simulation app. This phase focuses on infrastructure without implementing actual exam content.

## Deliverables Checklist
- [ ] Flutter project initialization with proper structure
- [ ] MVP architecture implementation
- [ ] Singleton manager classes (Game, Timer, Storage)
- [ ] Local storage system with JSON serialization
- [ ] Basic navigation flow and screen routing
- [ ] Data model definitions
- [ ] Unit test framework setup

## Project Structure

### Directory Layout
```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   ├── exam_constants.dart
│   │   └── storage_keys.dart
│   ├── errors/
│   │   └── app_exceptions.dart
│   └── utils/
│       ├── logger.dart
│       └── id_generator.dart
├── data/
│   ├── models/
│   │   ├── exam_session.dart
│   │   ├── period_data.dart
│   │   ├── action_log.dart
│   │   ├── score_data.dart
│   │   └── tool.dart
│   └── repositories/
│       └── local_storage_repository.dart
├── presentation/
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── exam_setup_screen.dart
│   │   ├── exam_screen.dart
│   │   └── results_screen.dart
│   ├── presenters/
│   │   ├── base_presenter.dart
│   │   ├── home_presenter.dart
│   │   └── exam_presenter.dart
│   └── widgets/
│       └── common/
│           └── loading_indicator.dart
├── managers/
│   ├── game_manager.dart
│   ├── timer_manager.dart
│   └── local_storage_manager.dart
└── navigation/
    └── app_router.dart
```

## Detailed Implementation Requirements

### 1. Main Application Entry Point

**main.dart**
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'managers/game_manager.dart';
import 'managers/local_storage_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Force portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  // Initialize managers
  await LocalStorageManager.instance.initialize();
  GameManager.instance.initialize();
  
  runApp(NailExamApp());
}
```

**app.dart**
```dart
class NailExamApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nail Exam Simulator',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: AppRouter.home,
    );
  }
}
```

### 2. Core Constants

**exam_constants.dart**
```dart
class ExamConstants {
  static const int totalPeriods = 5;
  static const Duration periodDuration = Duration(minutes: 30);
  static const Duration totalExamDuration = Duration(hours: 2, minutes: 30);
  
  static const Map<int, List<String>> periodTechniques = {
    1: ['full_color', 'french', 'deep_french', 'gradient'],
    2: ['full_color', 'french', 'deep_french', 'gradient'],
    3: ['fan_pattern', 'line_marble'],
    4: ['silk', 'tip_silk', 'acrylic', 'gel'],
    5: ['removal'],
  };
  
  static const Map<String, double> scoreWeights = {
    'sequence': 0.4,
    'timing': 0.2,
    'hygiene': 0.2,
    'technique': 0.2,
  };
}
```

### 3. Data Models

**exam_session.dart**
```dart
import 'package:json_annotation/json_annotation.dart';

part 'exam_session.g.dart';

@JsonSerializable()
class ExamSession {
  final String sessionId;
  final DateTime startTime;
  final int currentPeriod;
  final Map<int, PeriodData> periodResults;
  final bool isPracticeMode;
  ExamStatus status;
  
  ExamSession({
    required this.sessionId,
    required this.startTime,
    this.currentPeriod = 1,
    Map<int, PeriodData>? periodResults,
    this.isPracticeMode = false,
    this.status = ExamStatus.notStarted,
  }) : periodResults = periodResults ?? {};
  
  factory ExamSession.fromJson(Map<String, dynamic> json) => 
      _$ExamSessionFromJson(json);
  
  Map<String, dynamic> toJson() => _$ExamSessionToJson(this);
  
  double get totalScore {
    if (periodResults.isEmpty) return 0.0;
    final scores = periodResults.values.map((p) => p.score);
    return scores.reduce((a, b) => a + b) / periodResults.length;
  }
  
  Duration get elapsedTime => DateTime.now().difference(startTime);
  
  bool get isComplete => periodResults.length == ExamConstants.totalPeriods;
}

enum ExamStatus {
  notStarted,
  inProgress,
  paused,
  completed,
  abandoned
}
```

**period_data.dart**
```dart
@JsonSerializable()
class PeriodData {
  final int periodNumber;
  final String assignedTechnique;
  final DateTime startTime;
  DateTime? endTime;
  final List<ActionLog> actions;
  final Map<String, double> scoreBreakdown;
  
  PeriodData({
    required this.periodNumber,
    required this.assignedTechnique,
    required this.startTime,
    this.endTime,
    List<ActionLog>? actions,
    Map<String, double>? scoreBreakdown,
  }) : actions = actions ?? [],
        scoreBreakdown = scoreBreakdown ?? {};
  
  double get score {
    if (scoreBreakdown.isEmpty) return 0.0;
    double total = 0.0;
    ExamConstants.scoreWeights.forEach((key, weight) {
      total += (scoreBreakdown[key] ?? 0.0) * weight;
    });
    return total;
  }
  
  Duration? get duration {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }
  
  factory PeriodData.fromJson(Map<String, dynamic> json) => 
      _$PeriodDataFromJson(json);
  
  Map<String, dynamic> toJson() => _$PeriodDataToJson(this);
}
```

**action_log.dart**
```dart
@JsonSerializable()
class ActionLog {
  final String actionType;
  final DateTime timestamp;
  final Map<String, dynamic> data;
  
  ActionLog({
    required this.actionType,
    required this.timestamp,
    this.data = const {},
  });
  
  factory ActionLog.fromJson(Map<String, dynamic> json) => 
      _$ActionLogFromJson(json);
  
  Map<String, dynamic> toJson() => _$ActionLogToJson(this);
}
```

### 4. Singleton Managers

**game_manager.dart**
```dart
import 'dart:math';

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
    // Load any saved session from storage
    _loadSavedSession();
  }
  
  Future<void> _loadSavedSession() async {
    final saved = await LocalStorageManager.instance.loadSession();
    if (saved != null && saved.status != ExamStatus.completed) {
      _currentSession = saved;
    }
  }
  
  ExamSession startNewSession({bool isPractice = false}) {
    _currentSession = ExamSession(
      sessionId: IdGenerator.generateSessionId(),
      startTime: DateTime.now(),
      isPracticeMode: isPractice,
      status: ExamStatus.inProgress,
    );
    
    LocalStorageManager.instance.saveSession(_currentSession!);
    return _currentSession!;
  }
  
  void pauseSession() {
    if (_currentSession != null) {
      _currentSession!.status = ExamStatus.paused;
      LocalStorageManager.instance.saveSession(_currentSession!);
    }
  }
  
  void resumeSession() {
    if (_currentSession != null) {
      _currentSession!.status = ExamStatus.inProgress;
      LocalStorageManager.instance.saveSession(_currentSession!);
    }
  }
  
  String getRandomTechnique(int period) {
    final techniques = ExamConstants.periodTechniques[period];
    if (techniques == null || techniques.isEmpty) {
      throw Exception('No techniques defined for period $period');
    }
    return techniques[_random.nextInt(techniques.length)];
  }
  
  void startPeriod(int periodNumber) {
    if (_currentSession == null) {
      throw Exception('No active session');
    }
    
    final technique = getRandomTechnique(periodNumber);
    final periodData = PeriodData(
      periodNumber: periodNumber,
      assignedTechnique: technique,
      startTime: DateTime.now(),
    );
    
    _currentSession!.periodResults[periodNumber] = periodData;
    _currentSession!.currentPeriod = periodNumber;
    LocalStorageManager.instance.saveSession(_currentSession!);
  }
  
  void endPeriod(int periodNumber, Map<String, double> scores) {
    if (_currentSession == null) {
      throw Exception('No active session');
    }
    
    final periodData = _currentSession!.periodResults[periodNumber];
    if (periodData == null) {
      throw Exception('Period $periodNumber not started');
    }
    
    periodData.endTime = DateTime.now();
    periodData.scoreBreakdown.addAll(scores);
    
    if (_currentSession!.isComplete) {
      _currentSession!.status = ExamStatus.completed;
    }
    
    LocalStorageManager.instance.saveSession(_currentSession!);
  }
  
  void logAction(String actionType, Map<String, dynamic> data) {
    if (_currentSession == null) return;
    
    final currentPeriod = _currentSession!.currentPeriod;
    final periodData = _currentSession!.periodResults[currentPeriod];
    
    if (periodData != null) {
      periodData.actions.add(ActionLog(
        actionType: actionType,
        timestamp: DateTime.now(),
        data: data,
      ));
    }
  }
}
```

**timer_manager.dart**
```dart
import 'dart:async';

class TimerManager {
  static final TimerManager _instance = TimerManager._internal();
  static TimerManager get instance => _instance;
  
  TimerManager._internal();
  
  Timer? _examTimer;
  Timer? _periodTimer;
  StreamController<Duration> _examTimeController = StreamController.broadcast();
  StreamController<Duration> _periodTimeController = StreamController.broadcast();
  
  Stream<Duration> get examTimeStream => _examTimeController.stream;
  Stream<Duration> get periodTimeStream => _periodTimeController.stream;
  
  Duration _examElapsed = Duration.zero;
  Duration _periodElapsed = Duration.zero;
  bool _isPaused = false;
  
  void startExamTimer() {
    _examTimer?.cancel();
    _examElapsed = Duration.zero;
    _isPaused = false;
    
    _examTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        _examElapsed += Duration(seconds: 1);
        _examTimeController.add(_examElapsed);
        
        // Check for time warnings
        final remaining = ExamConstants.totalExamDuration - _examElapsed;
        if (remaining.inMinutes == 30 || 
            remaining.inMinutes == 10 || 
            remaining.inMinutes == 5) {
          _notifyTimeWarning(remaining);
        }
      }
    });
  }
  
  void startPeriodTimer() {
    _periodTimer?.cancel();
    _periodElapsed = Duration.zero;
    
    _periodTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        _periodElapsed += Duration(seconds: 1);
        _periodTimeController.add(_periodElapsed);
        
        // Check for period warnings
        final remaining = ExamConstants.periodDuration - _periodElapsed;
        if (remaining.inMinutes == 5 || remaining.inMinutes == 1) {
          _notifyPeriodWarning(remaining);
        }
      }
    });
  }
  
  void pause() {
    _isPaused = true;
  }
  
  void resume() {
    _isPaused = false;
  }
  
  void reset() {
    _examTimer?.cancel();
    _periodTimer?.cancel();
    _examElapsed = Duration.zero;
    _periodElapsed = Duration.zero;
    _isPaused = false;
  }
  
  void _notifyTimeWarning(Duration remaining) {
    // Will be implemented with UI notifications in later phases
    print('Warning: ${remaining.inMinutes} minutes remaining in exam');
  }
  
  void _notifyPeriodWarning(Duration remaining) {
    print('Warning: ${remaining.inMinutes} minutes remaining in period');
  }
  
  void dispose() {
    _examTimer?.cancel();
    _periodTimer?.cancel();
    _examTimeController.close();
    _periodTimeController.close();
  }
}
```

**local_storage_manager.dart**
```dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageManager {
  static final LocalStorageManager _instance = LocalStorageManager._internal();
  static LocalStorageManager get instance => _instance;
  
  LocalStorageManager._internal();
  
  late SharedPreferences _prefs;
  
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  Future<void> saveSession(ExamSession session) async {
    final json = jsonEncode(session.toJson());
    await _prefs.setString(StorageKeys.currentSession, json);
    
    // Also save to session history
    final history = await getSessionHistory();
    history[session.sessionId] = session;
    await _saveSessionHistory(history);
  }
  
  Future<ExamSession?> loadSession() async {
    final json = _prefs.getString(StorageKeys.currentSession);
    if (json == null) return null;
    
    try {
      final data = jsonDecode(json);
      return ExamSession.fromJson(data);
    } catch (e) {
      print('Error loading session: $e');
      return null;
    }
  }
  
  Future<Map<String, ExamSession>> getSessionHistory() async {
    final json = _prefs.getString(StorageKeys.sessionHistory);
    if (json == null) return {};
    
    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      return data.map((key, value) => 
        MapEntry(key, ExamSession.fromJson(value)));
    } catch (e) {
      print('Error loading session history: $e');
      return {};
    }
  }
  
  Future<void> _saveSessionHistory(Map<String, ExamSession> history) async {
    final data = history.map((key, value) => 
      MapEntry(key, value.toJson()));
    final json = jsonEncode(data);
    await _prefs.setString(StorageKeys.sessionHistory, json);
  }
  
  Future<void> clearCurrentSession() async {
    await _prefs.remove(StorageKeys.currentSession);
  }
  
  Future<void> clearAll() async {
    await _prefs.clear();
  }
  
  // Settings storage
  Future<void> saveSetting(String key, dynamic value) async {
    if (value is bool) {
      await _prefs.setBool(key, value);
    } else if (value is int) {
      await _prefs.setInt(key, value);
    } else if (value is double) {
      await _prefs.setDouble(key, value);
    } else if (value is String) {
      await _prefs.setString(key, value);
    }
  }
  
  dynamic getSetting(String key, {dynamic defaultValue}) {
    return _prefs.get(key) ?? defaultValue;
  }
}

class StorageKeys {
  static const String currentSession = 'current_session';
  static const String sessionHistory = 'session_history';
  static const String soundEnabled = 'sound_enabled';
  static const String vibrationEnabled = 'vibration_enabled';
  static const String practiceHighScore = 'practice_high_score';
}
```

### 5. Navigation Router

**app_router.dart**
```dart
import 'package:flutter/material.dart';

class AppRouter {
  static const String home = '/';
  static const String examSetup = '/exam-setup';
  static const String exam = '/exam';
  static const String results = '/results';
  
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => HomeScreen(),
        );
      case examSetup:
        return MaterialPageRoute(
          builder: (_) => ExamSetupScreen(),
        );
      case exam:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ExamScreen(
            isPracticeMode: args?['isPracticeMode'] ?? false,
          ),
        );
      case results:
        final session = settings.arguments as ExamSession;
        return MaterialPageRoute(
          builder: (_) => ResultsScreen(session: session),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route ${settings.name} not found'),
            ),
          ),
        );
    }
  }
}
```

### 6. Base Presenter

**base_presenter.dart**
```dart
abstract class BasePresenter<V> {
  V? _view;
  
  V? get view => _view;
  
  void attachView(V view) {
    _view = view;
  }
  
  void detachView() {
    _view = null;
  }
  
  bool get isViewAttached => _view != null;
}

abstract class BaseView {
  void showLoading();
  void hideLoading();
  void showError(String message);
}
```

### 7. Basic Screens (Skeleton Only)

**home_screen.dart**
```dart
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> implements HomeView {
  late HomePresenter _presenter;
  
  @override
  void initState() {
    super.initState();
    _presenter = HomePresenter();
    _presenter.attachView(this);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nail Exam Simulator'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _startExam(false),
              child: Text('Start Exam'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 50),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _startExam(true),
              child: Text('Practice Mode'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 50),
              ),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: _viewHistory,
              child: Text('View History'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _startExam(bool isPracticeMode) {
    Navigator.pushNamed(
      context, 
      AppRouter.exam,
      arguments: {'isPracticeMode': isPracticeMode},
    );
  }
  
  void _viewHistory() {
    // To be implemented
  }
  
  @override
  void showLoading() {}
  
  @override
  void hideLoading() {}
  
  @override
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  
  @override
  void dispose() {
    _presenter.detachView();
    super.dispose();
  }
}

abstract class HomeView extends BaseView {}

class HomePresenter extends BasePresenter<HomeView> {
  // Presenter logic to be implemented
}
```

## Testing Requirements

### Unit Tests Structure
```
test/
├── managers/
│   ├── game_manager_test.dart
│   ├── timer_manager_test.dart
│   └── local_storage_manager_test.dart
├── models/
│   ├── exam_session_test.dart
│   └── period_data_test.dart
└── utils/
    └── id_generator_test.dart
```

### Sample Test Case
```dart
// game_manager_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameManager', () {
    test('should create new session', () {
      final manager = GameManager.instance;
      final session = manager.startNewSession();
      
      expect(session, isNotNull);
      expect(session.sessionId, isNotEmpty);
      expect(session.status, ExamStatus.inProgress);
    });
    
    test('should select random technique', () {
      final manager = GameManager.instance;
      final technique = manager.getRandomTechnique(1);
      
      expect(
        ExamConstants.periodTechniques[1]!.contains(technique),
        isTrue,
      );
    });
  });
}
```

## Success Criteria for Phase 1

1. **Architecture Setup** ✓
   - MVP pattern properly implemented
   - Clear separation of concerns
   - All managers following singleton pattern

2. **Data Persistence** ✓
   - Session saves/loads correctly
   - JSON serialization working
   - No data loss on app restart

3. **Navigation** ✓
   - All routes defined and working
   - Proper parameter passing between screens
   - Back navigation handled correctly

4. **Timer System** ✓
   - Accurate time tracking
   - Pause/resume functionality
   - Warning notifications at correct intervals

5. **Testing** ✓
   - All core managers have unit tests
   - Models have serialization tests
   - Minimum 80% code coverage for Phase 1 code

## Notes for Developer

- Use `json_serializable` package for model serialization
- Follow Flutter's official style guide
- Implement proper error handling with try-catch blocks
- Add logging for debugging (consider using `logger` package)
- Keep UI minimal in Phase 1 - focus on architecture
- Document all public methods and classes
- Create README.md with setup instructions

---

*Upon completion of Phase 1, the app should have a robust foundation ready for UI implementation and exam period development in subsequent phases.*