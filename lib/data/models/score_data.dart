import 'package:json_annotation/json_annotation.dart';

part 'score_data.g.dart';

@JsonSerializable()
class ScoreData {
  final double sequenceScore;
  final double timingScore;
  final double hygieneScore;
  final double techniqueScore;
  final double totalScore;
  final DateTime scoredAt;
  final String? feedback;
  
  ScoreData({
    required this.sequenceScore,
    required this.timingScore,
    required this.hygieneScore,
    required this.techniqueScore,
    required this.totalScore,
    required this.scoredAt,
    this.feedback,
  });
  
  factory ScoreData.calculate({
    required double sequence,
    required double timing,
    required double hygiene,
    required double technique,
    String? feedback,
  }) {
    final total = (sequence * 0.4) + (timing * 0.2) + (hygiene * 0.2) + (technique * 0.2);
    return ScoreData(
      sequenceScore: sequence,
      timingScore: timing,
      hygieneScore: hygiene,
      techniqueScore: technique,
      totalScore: total,
      scoredAt: DateTime.now(),
      feedback: feedback,
    );
  }
  
  factory ScoreData.fromJson(Map<String, dynamic> json) => 
      _$ScoreDataFromJson(json);
  
  Map<String, dynamic> toJson() => _$ScoreDataToJson(this);
  
  Map<String, double> toBreakdownMap() => {
    'sequence': sequenceScore,
    'timing': timingScore,
    'hygiene': hygieneScore,
    'technique': techniqueScore,
  };
  
  String get grade {
    if (totalScore >= 90) return 'A';
    if (totalScore >= 80) return 'B';
    if (totalScore >= 70) return 'C';
    if (totalScore >= 60) return 'D';
    return 'F';
  }
}