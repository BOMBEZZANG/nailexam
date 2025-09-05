import 'package:json_annotation/json_annotation.dart';

part 'exam_progress.g.dart';

@JsonSerializable()
class ExamProgress {
  final String sessionId;
  final bool isPracticeMode;
  final DateTime savedAt;
  final int currentScore;
  
  // Step completion status
  final bool handSanitizerStepCompleted;
  final bool polishRemovalStepCompleted;
  final bool nailFilingStepCompleted;
  final bool sandingStepCompleted;
  final bool fingerBowlStepCompleted;
  final bool cuticleOilStepCompleted;
  final bool cuticlePusherStepCompleted;
  final bool cuticleNipperStepCompleted;
  final bool disinfectantSprayStepCompleted;
  final bool sterilizedGauzeStepCompleted;
  final bool polishBrushStepCompleted;
  
  // Nail-specific progress (which nails completed for each step)
  final Set<int> sanitizedNails;
  final Set<int> polishRemovedNails;
  final Set<int> filedNails;
  final Set<int> sandedNails;
  final Set<int> soakedNails;
  final Set<int> oiledNails;
  final Set<int> pushedNails;
  final Set<int> nippedNails;
  final Set<int> disinfectedNails;
  final Set<int> cleanedNails;
  final Set<int> coloredNails;

  const ExamProgress({
    required this.sessionId,
    required this.isPracticeMode,
    required this.savedAt,
    required this.currentScore,
    required this.handSanitizerStepCompleted,
    required this.polishRemovalStepCompleted,
    required this.nailFilingStepCompleted,
    required this.sandingStepCompleted,
    required this.fingerBowlStepCompleted,
    required this.cuticleOilStepCompleted,
    required this.cuticlePusherStepCompleted,
    required this.cuticleNipperStepCompleted,
    required this.disinfectantSprayStepCompleted,
    required this.sterilizedGauzeStepCompleted,
    required this.polishBrushStepCompleted,
    required this.sanitizedNails,
    required this.polishRemovedNails,
    required this.filedNails,
    required this.sandedNails,
    required this.soakedNails,
    required this.oiledNails,
    required this.pushedNails,
    required this.nippedNails,
    required this.disinfectedNails,
    required this.cleanedNails,
    required this.coloredNails,
  });

  factory ExamProgress.fromJson(Map<String, dynamic> json) => _$ExamProgressFromJson(json);
  Map<String, dynamic> toJson() => _$ExamProgressToJson(this);

  ExamProgress copyWith({
    String? sessionId,
    bool? isPracticeMode,
    DateTime? savedAt,
    int? currentScore,
    bool? handSanitizerStepCompleted,
    bool? polishRemovalStepCompleted,
    bool? nailFilingStepCompleted,
    bool? sandingStepCompleted,
    bool? fingerBowlStepCompleted,
    bool? cuticleOilStepCompleted,
    bool? cuticlePusherStepCompleted,
    bool? cuticleNipperStepCompleted,
    bool? disinfectantSprayStepCompleted,
    bool? sterilizedGauzeStepCompleted,
    bool? polishBrushStepCompleted,
    Set<int>? sanitizedNails,
    Set<int>? polishRemovedNails,
    Set<int>? filedNails,
    Set<int>? sandedNails,
    Set<int>? soakedNails,
    Set<int>? oiledNails,
    Set<int>? pushedNails,
    Set<int>? nippedNails,
    Set<int>? disinfectedNails,
    Set<int>? cleanedNails,
    Set<int>? coloredNails,
  }) {
    return ExamProgress(
      sessionId: sessionId ?? this.sessionId,
      isPracticeMode: isPracticeMode ?? this.isPracticeMode,
      savedAt: savedAt ?? this.savedAt,
      currentScore: currentScore ?? this.currentScore,
      handSanitizerStepCompleted: handSanitizerStepCompleted ?? this.handSanitizerStepCompleted,
      polishRemovalStepCompleted: polishRemovalStepCompleted ?? this.polishRemovalStepCompleted,
      nailFilingStepCompleted: nailFilingStepCompleted ?? this.nailFilingStepCompleted,
      sandingStepCompleted: sandingStepCompleted ?? this.sandingStepCompleted,
      fingerBowlStepCompleted: fingerBowlStepCompleted ?? this.fingerBowlStepCompleted,
      cuticleOilStepCompleted: cuticleOilStepCompleted ?? this.cuticleOilStepCompleted,
      cuticlePusherStepCompleted: cuticlePusherStepCompleted ?? this.cuticlePusherStepCompleted,
      cuticleNipperStepCompleted: cuticleNipperStepCompleted ?? this.cuticleNipperStepCompleted,
      disinfectantSprayStepCompleted: disinfectantSprayStepCompleted ?? this.disinfectantSprayStepCompleted,
      sterilizedGauzeStepCompleted: sterilizedGauzeStepCompleted ?? this.sterilizedGauzeStepCompleted,
      polishBrushStepCompleted: polishBrushStepCompleted ?? this.polishBrushStepCompleted,
      sanitizedNails: sanitizedNails ?? this.sanitizedNails,
      polishRemovedNails: polishRemovedNails ?? this.polishRemovedNails,
      filedNails: filedNails ?? this.filedNails,
      sandedNails: sandedNails ?? this.sandedNails,
      soakedNails: soakedNails ?? this.soakedNails,
      oiledNails: oiledNails ?? this.oiledNails,
      pushedNails: pushedNails ?? this.pushedNails,
      nippedNails: nippedNails ?? this.nippedNails,
      disinfectedNails: disinfectedNails ?? this.disinfectedNails,
      cleanedNails: cleanedNails ?? this.cleanedNails,
      coloredNails: coloredNails ?? this.coloredNails,
    );
  }
}