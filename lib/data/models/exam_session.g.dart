// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExamSession _$ExamSessionFromJson(Map<String, dynamic> json) => ExamSession(
      sessionId: json['sessionId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      currentPeriod: json['currentPeriod'] as int? ?? 1,
      periodResults: (json['periodResults'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(int.parse(k),
                PeriodData.fromJson(e as Map<String, dynamic>)),
          ) ??
          <int, PeriodData>{},
      isPracticeMode: json['isPracticeMode'] as bool? ?? false,
      status: json['status'] != null
          ? ExamStatus.values.firstWhere((e) => e.toString().split('.').last == json['status'])
          : ExamStatus.notStarted,
    );

Map<String, dynamic> _$ExamSessionToJson(ExamSession instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'startTime': instance.startTime.toIso8601String(),
      'currentPeriod': instance.currentPeriod,
      'periodResults': instance.periodResults
          .map((k, e) => MapEntry(k.toString(), e.toJson())),
      'isPracticeMode': instance.isPracticeMode,
      'status': instance.status.toString().split('.').last,
    };

const _$ExamStatusEnumMap = {
  ExamStatus.notStarted: 'notStarted',
  ExamStatus.inProgress: 'inProgress',
  ExamStatus.paused: 'paused',
  ExamStatus.completed: 'completed',
  ExamStatus.abandoned: 'abandoned',
};