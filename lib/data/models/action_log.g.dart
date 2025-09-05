// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'action_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActionLog _$ActionLogFromJson(Map<String, dynamic> json) => ActionLog(
  actionType: json['actionType'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  data: json['data'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$ActionLogToJson(ActionLog instance) => <String, dynamic>{
  'actionType': instance.actionType,
  'timestamp': instance.timestamp.toIso8601String(),
  'data': instance.data,
};
