import 'package:json_annotation/json_annotation.dart';

part 'action_log.g.dart';

@JsonSerializable()
class ActionLog {
  final String actionType;
  final DateTime timestamp;
  final Map<String, dynamic> data;
  
  ActionLog({
    required this.actionType,
    required this.timestamp,
    Map<String, dynamic>? data,
  }) : data = data ?? {};
  
  factory ActionLog.fromJson(Map<String, dynamic> json) => 
      _$ActionLogFromJson(json);
  
  Map<String, dynamic> toJson() => _$ActionLogToJson(this);
  
  @override
  String toString() => 'ActionLog(type: $actionType, time: $timestamp)';
}