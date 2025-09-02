import 'package:json_annotation/json_annotation.dart';
import '../../core/constants/exam_constants.dart';
import 'action_log.dart';

part 'period_data.g.dart';

@JsonSerializable(explicitToJson: true)
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
  
  bool get isComplete => endTime != null;
  
  void addAction(ActionLog action) {
    actions.add(action);
  }
  
  void complete(Map<String, double> scores) {
    endTime = DateTime.now();
    scoreBreakdown.addAll(scores);
  }
  
  factory PeriodData.fromJson(Map<String, dynamic> json) => 
      _$PeriodDataFromJson(json);
  
  Map<String, dynamic> toJson() => _$PeriodDataToJson(this);
}