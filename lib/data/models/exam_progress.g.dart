// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExamProgress _$ExamProgressFromJson(Map<String, dynamic> json) => ExamProgress(
      sessionId: json['sessionId'] as String,
      isPracticeMode: json['isPracticeMode'] as bool,
      savedAt: DateTime.parse(json['savedAt'] as String),
      currentScore: (json['currentScore'] as num).toInt(),
      handSanitizerStepCompleted: json['handSanitizerStepCompleted'] as bool,
      polishRemovalStepCompleted: json['polishRemovalStepCompleted'] as bool,
      nailFilingStepCompleted: json['nailFilingStepCompleted'] as bool,
      sandingStepCompleted: json['sandingStepCompleted'] as bool,
      fingerBowlStepCompleted: json['fingerBowlStepCompleted'] as bool,
      cuticleOilStepCompleted: json['cuticleOilStepCompleted'] as bool,
      cuticlePusherStepCompleted: json['cuticlePusherStepCompleted'] as bool,
      cuticleNipperStepCompleted: json['cuticleNipperStepCompleted'] as bool,
      disinfectantSprayStepCompleted: json['disinfectantSprayStepCompleted'] as bool,
      sterilizedGauzeStepCompleted: json['sterilizedGauzeStepCompleted'] as bool,
      polishBrushStepCompleted: json['polishBrushStepCompleted'] as bool,
      sanitizedNails: (json['sanitizedNails'] as List<dynamic>).map((e) => (e as num).toInt()).toSet(),
      polishRemovedNails: (json['polishRemovedNails'] as List<dynamic>).map((e) => (e as num).toInt()).toSet(),
      filedNails: (json['filedNails'] as List<dynamic>).map((e) => (e as num).toInt()).toSet(),
      sandedNails: (json['sandedNails'] as List<dynamic>).map((e) => (e as num).toInt()).toSet(),
      soakedNails: (json['soakedNails'] as List<dynamic>).map((e) => (e as num).toInt()).toSet(),
      oiledNails: (json['oiledNails'] as List<dynamic>).map((e) => (e as num).toInt()).toSet(),
      pushedNails: (json['pushedNails'] as List<dynamic>).map((e) => (e as num).toInt()).toSet(),
      nippedNails: (json['nippedNails'] as List<dynamic>).map((e) => (e as num).toInt()).toSet(),
      disinfectedNails: (json['disinfectedNails'] as List<dynamic>).map((e) => (e as num).toInt()).toSet(),
      cleanedNails: (json['cleanedNails'] as List<dynamic>).map((e) => (e as num).toInt()).toSet(),
      coloredNails: (json['coloredNails'] as List<dynamic>).map((e) => (e as num).toInt()).toSet(),
    );

Map<String, dynamic> _$ExamProgressToJson(ExamProgress instance) => <String, dynamic>{
      'sessionId': instance.sessionId,
      'isPracticeMode': instance.isPracticeMode,
      'savedAt': instance.savedAt.toIso8601String(),
      'currentScore': instance.currentScore,
      'handSanitizerStepCompleted': instance.handSanitizerStepCompleted,
      'polishRemovalStepCompleted': instance.polishRemovalStepCompleted,
      'nailFilingStepCompleted': instance.nailFilingStepCompleted,
      'sandingStepCompleted': instance.sandingStepCompleted,
      'fingerBowlStepCompleted': instance.fingerBowlStepCompleted,
      'cuticleOilStepCompleted': instance.cuticleOilStepCompleted,
      'cuticlePusherStepCompleted': instance.cuticlePusherStepCompleted,
      'cuticleNipperStepCompleted': instance.cuticleNipperStepCompleted,
      'disinfectantSprayStepCompleted': instance.disinfectantSprayStepCompleted,
      'sterilizedGauzeStepCompleted': instance.sterilizedGauzeStepCompleted,
      'polishBrushStepCompleted': instance.polishBrushStepCompleted,
      'sanitizedNails': instance.sanitizedNails.toList(),
      'polishRemovedNails': instance.polishRemovedNails.toList(),
      'filedNails': instance.filedNails.toList(),
      'sandedNails': instance.sandedNails.toList(),
      'soakedNails': instance.soakedNails.toList(),
      'oiledNails': instance.oiledNails.toList(),
      'pushedNails': instance.pushedNails.toList(),
      'nippedNails': instance.nippedNails.toList(),
      'disinfectedNails': instance.disinfectedNails.toList(),
      'cleanedNails': instance.cleanedNails.toList(),
      'coloredNails': instance.coloredNails.toList(),
    };