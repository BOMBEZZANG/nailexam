import 'package:json_annotation/json_annotation.dart';
import '../../core/constants/exam_constants.dart';
import 'period_data.dart';

part 'exam_session.g.dart';

enum ExamStatus {
  notStarted,
  inProgress,
  paused,
  completed,
  abandoned
}

@JsonSerializable(explicitToJson: true)
class ExamSession {
  final String sessionId;
  final DateTime startTime;
  int currentPeriod;
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
  
  bool get isActive => status == ExamStatus.inProgress;
  
  int get completedPeriods => periodResults.values.where((p) => p.isComplete).length;
  
  double get progressPercentage => completedPeriods / ExamConstants.totalPeriods;
  
  PeriodData? getCurrentPeriod() {
    return periodResults[currentPeriod];
  }
  
  void startPeriod(int periodNumber, String technique) {
    currentPeriod = periodNumber;
    periodResults[periodNumber] = PeriodData(
      periodNumber: periodNumber,
      assignedTechnique: technique,
      startTime: DateTime.now(),
    );
  }
  
  void completePeriod(int periodNumber, Map<String, double> scores) {
    final period = periodResults[periodNumber];
    if (period != null) {
      period.complete(scores);
    }
    
    if (isComplete) {
      status = ExamStatus.completed;
    }
  }
}