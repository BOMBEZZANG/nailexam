// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'period_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PeriodData _$PeriodDataFromJson(Map<String, dynamic> json) => PeriodData(
      periodNumber: json['periodNumber'] as int,
      assignedTechnique: json['assignedTechnique'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      actions: (json['actions'] as List<dynamic>?)
          ?.map((e) => ActionLog.fromJson(e as Map<String, dynamic>))
          .toList(),
      scoreBreakdown: (json['scoreBreakdown'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
    );

Map<String, dynamic> _$PeriodDataToJson(PeriodData instance) =>
    <String, dynamic>{
      'periodNumber': instance.periodNumber,
      'assignedTechnique': instance.assignedTechnique,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'actions': instance.actions.map((e) => e.toJson()).toList(),
      'scoreBreakdown': instance.scoreBreakdown,
    };