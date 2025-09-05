// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExamProgress _$ExamProgressFromJson(Map<String, dynamic> json) => ExamProgress(
  sessionId: json['sessionId'] as String,
  currentPeriod: (json['currentPeriod'] as num).toInt(),
  progress: (json['progress'] as num).toDouble(),
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
  data: json['data'] as Map<String, dynamic>? ?? const {},
  completedActions:
      (json['completedActions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  periodProgress:
      (json['periodProgress'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          int.parse(k),
          PeriodProgress.fromJson(e as Map<String, dynamic>),
        ),
      ) ??
      const {},
  isPracticeMode: json['isPracticeMode'] as bool? ?? false,
);

Map<String, dynamic> _$ExamProgressToJson(ExamProgress instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'currentPeriod': instance.currentPeriod,
      'progress': instance.progress,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'data': instance.data,
      'completedActions': instance.completedActions,
      'periodProgress': instance.periodProgress.map(
        (k, e) => MapEntry(k.toString(), e),
      ),
      'isPracticeMode': instance.isPracticeMode,
    };

PeriodProgress _$PeriodProgressFromJson(Map<String, dynamic> json) =>
    PeriodProgress(
      periodNumber: (json['periodNumber'] as num).toInt(),
      periodName: json['periodName'] as String,
      progress: (json['progress'] as num).toDouble(),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime:
          json['endTime'] == null
              ? null
              : DateTime.parse(json['endTime'] as String),
      stepProgress: json['stepProgress'] as Map<String, dynamic>? ?? const {},
      completedSteps:
          (json['completedSteps'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      score: (json['score'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$PeriodProgressToJson(PeriodProgress instance) =>
    <String, dynamic>{
      'periodNumber': instance.periodNumber,
      'periodName': instance.periodName,
      'progress': instance.progress,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'stepProgress': instance.stepProgress,
      'completedSteps': instance.completedSteps,
      'score': instance.score,
    };
