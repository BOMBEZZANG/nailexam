// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'score_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScoreData _$ScoreDataFromJson(Map<String, dynamic> json) => ScoreData(
      sequenceScore: (json['sequenceScore'] as num).toDouble(),
      timingScore: (json['timingScore'] as num).toDouble(),
      hygieneScore: (json['hygieneScore'] as num).toDouble(),
      techniqueScore: (json['techniqueScore'] as num).toDouble(),
      totalScore: (json['totalScore'] as num).toDouble(),
      scoredAt: DateTime.parse(json['scoredAt'] as String),
      feedback: json['feedback'] as String?,
    );

Map<String, dynamic> _$ScoreDataToJson(ScoreData instance) => <String, dynamic>{
      'sequenceScore': instance.sequenceScore,
      'timingScore': instance.timingScore,
      'hygieneScore': instance.hygieneScore,
      'techniqueScore': instance.techniqueScore,
      'totalScore': instance.totalScore,
      'scoredAt': instance.scoredAt.toIso8601String(),
      'feedback': instance.feedback,
    };