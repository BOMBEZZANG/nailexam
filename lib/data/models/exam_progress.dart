import 'package:json_annotation/json_annotation.dart';

part 'exam_progress.g.dart';

@JsonSerializable()
class ExamProgress {
  final String sessionId;
  final int currentPeriod;
  final double progress;
  final DateTime lastUpdated;
  final Map<String, dynamic> data;
  final List<String> completedActions;
  final Map<int, PeriodProgress> periodProgress;
  final bool isPracticeMode;

  ExamProgress({
    required this.sessionId,
    required this.currentPeriod,
    required this.progress,
    required this.lastUpdated,
    this.data = const {},
    this.completedActions = const [],
    this.periodProgress = const {},
    this.isPracticeMode = false,
  });

  bool get isCompleted => progress >= 1.0;
  
  PeriodProgress? getCurrentPeriodProgress() {
    return periodProgress[currentPeriod];
  }

  double getOverallProgress() {
    if (periodProgress.isEmpty) return progress;
    
    double totalProgress = 0.0;
    for (final period in periodProgress.values) {
      totalProgress += period.progress;
    }
    return totalProgress / periodProgress.length;
  }

  ExamProgress copyWith({
    String? sessionId,
    int? currentPeriod,
    double? progress,
    DateTime? lastUpdated,
    Map<String, dynamic>? data,
    List<String>? completedActions,
    Map<int, PeriodProgress>? periodProgress,
    bool? isPracticeMode,
  }) {
    return ExamProgress(
      sessionId: sessionId ?? this.sessionId,
      currentPeriod: currentPeriod ?? this.currentPeriod,
      progress: progress ?? this.progress,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      data: data ?? this.data,
      completedActions: completedActions ?? this.completedActions,
      periodProgress: periodProgress ?? this.periodProgress,
      isPracticeMode: isPracticeMode ?? this.isPracticeMode,
    );
  }

  factory ExamProgress.fromJson(Map<String, dynamic> json) => _$ExamProgressFromJson(json);
  Map<String, dynamic> toJson() => _$ExamProgressToJson(this);

  @override
  String toString() {
    return 'ExamProgress{sessionId: $sessionId, currentPeriod: $currentPeriod, progress: $progress}';
  }
}

@JsonSerializable()
class PeriodProgress {
  final int periodNumber;
  final String periodName;
  final double progress;
  final DateTime startTime;
  final DateTime? endTime;
  final Map<String, dynamic> stepProgress;
  final List<String> completedSteps;
  final int score;

  PeriodProgress({
    required this.periodNumber,
    required this.periodName,
    required this.progress,
    required this.startTime,
    this.endTime,
    this.stepProgress = const {},
    this.completedSteps = const [],
    this.score = 0,
  });

  bool get isCompleted => endTime != null;
  
  Duration get elapsedTime {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  PeriodProgress copyWith({
    int? periodNumber,
    String? periodName,
    double? progress,
    DateTime? startTime,
    DateTime? endTime,
    Map<String, dynamic>? stepProgress,
    List<String>? completedSteps,
    int? score,
  }) {
    return PeriodProgress(
      periodNumber: periodNumber ?? this.periodNumber,
      periodName: periodName ?? this.periodName,
      progress: progress ?? this.progress,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      stepProgress: stepProgress ?? this.stepProgress,
      completedSteps: completedSteps ?? this.completedSteps,
      score: score ?? this.score,
    );
  }

  factory PeriodProgress.fromJson(Map<String, dynamic> json) => _$PeriodProgressFromJson(json);
  Map<String, dynamic> toJson() => _$PeriodProgressToJson(this);

  @override
  String toString() {
    return 'PeriodProgress{periodNumber: $periodNumber, progress: $progress, score: $score}';
  }
}

// Temporary managers for the exam progress system
class ExamProgressManager {
  static final ExamProgressManager _instance = ExamProgressManager._internal();
  static ExamProgressManager get instance => _instance;
  ExamProgressManager._internal();
  
  ExamProgress? _currentProgress;
  
  ExamProgress? getCurrentProgress() {
    return _currentProgress;
  }
  
  void saveProgress(ExamProgress progress) {
    _currentProgress = progress;
    // TODO: Implement local storage save
    print('DEBUG: Saving progress for session: ${progress.sessionId}');
  }
  
  Future<ExamProgress?> loadProgress(String sessionId) async {
    // TODO: Implement local storage load
    print('DEBUG: Loading progress for session: $sessionId');
    return _currentProgress?.sessionId == sessionId ? _currentProgress : null;
  }
  
  void clearProgress() {
    _currentProgress = null;
    // TODO: Implement local storage clear
    print('DEBUG: Clearing progress');
  }
  
  List<ExamProgress> getAllProgress() {
    // TODO: Implement local storage get all
    return _currentProgress != null ? [_currentProgress!] : [];
  }
}