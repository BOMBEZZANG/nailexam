import 'dart:math';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'tool.dart';

part 'nail_state.g.dart';

enum ExtensionType {
  silk,
  tipWithSilk,
  acrylic,
  gel,
}

enum NailCondition {
  clean,
  dirty,
  damaged,
  healthy,
}

@JsonSerializable()
class NailState {
  final int fingerIndex;
  bool hasCuticle;
  bool hasPolish;
  @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson)
  Color polishColor;
  double polishCoverage;
  bool needsFiling;
  bool hasExtension;
  ExtensionType? extensionType;
  NailCondition condition;
  double shineLevel;
  double length;
  bool hasBaseCoat;
  bool hasTopCoat;
  List<String> appliedActions;
  
  NailState({
    required this.fingerIndex,
    this.hasCuticle = true,
    this.hasPolish = true,
    this.polishColor = Colors.red,
    this.polishCoverage = 1.0,
    this.needsFiling = true,
    this.hasExtension = false,
    this.extensionType,
    this.condition = NailCondition.clean,
    this.shineLevel = 0.0,
    this.length = 0.5,
    this.hasBaseCoat = false,
    this.hasTopCoat = false,
    List<String>? appliedActions,
  }) : appliedActions = appliedActions ?? [];
  
  // JSON conversion helpers for Color
  static Color _colorFromJson(int value) => Color(value);
  static int _colorToJson(Color color) => color.value;
  
  NailState copyWith({
    int? fingerIndex,
    bool? hasCuticle,
    bool? hasPolish,
    Color? polishColor,
    double? polishCoverage,
    bool? needsFiling,
    bool? hasExtension,
    ExtensionType? extensionType,
    NailCondition? condition,
    double? shineLevel,
    double? length,
    bool? hasBaseCoat,
    bool? hasTopCoat,
    List<String>? appliedActions,
  }) {
    return NailState(
      fingerIndex: fingerIndex ?? this.fingerIndex,
      hasCuticle: hasCuticle ?? this.hasCuticle,
      hasPolish: hasPolish ?? this.hasPolish,
      polishColor: polishColor ?? this.polishColor,
      polishCoverage: polishCoverage ?? this.polishCoverage,
      needsFiling: needsFiling ?? this.needsFiling,
      hasExtension: hasExtension ?? this.hasExtension,
      extensionType: extensionType ?? this.extensionType,
      condition: condition ?? this.condition,
      shineLevel: shineLevel ?? this.shineLevel,
      length: length ?? this.length,
      hasBaseCoat: hasBaseCoat ?? this.hasBaseCoat,
      hasTopCoat: hasTopCoat ?? this.hasTopCoat,
      appliedActions: appliedActions ?? List<String>.from(this.appliedActions),
    );
  }
  
  factory NailState.fromJson(Map<String, dynamic> json) => 
      _$NailStateFromJson(json);
  
  Map<String, dynamic> toJson() => _$NailStateToJson(this);
  
  void applyTool(Tool tool, {Map<String, dynamic>? additionalData}) {
    switch (tool.type) {
      case ToolType.cuticlePusher:
        _applyCuticlePusher();
        break;
      case ToolType.nailFile:
        _applyNailFile();
        break;
      case ToolType.polishBrush:
        _applyPolishBrush(additionalData?['color'] ?? Colors.red);
        break;
      case ToolType.buffer:
        _applyBuffer();
        break;
      case ToolType.cuticleNipper:
        _applyCuticleNipper();
        break;
      case ToolType.cottonPad:
        _applyCottonPad();
        break;
      case ToolType.nailTips:
        _applyNailTip();
        break;
      case ToolType.handSanitizer:
        _applyHandSanitizer();
        break;
      case ToolType.uvLamp:
        _applyUvLamp();
        break;
      case ToolType.remover:
        _applyRemover();
        break;
      case ToolType.sandingBlock:
        _applySandingBlock();
        break;
      case ToolType.fingerBowl:
        _applyFingerBowl();
        break;
      case ToolType.cuticleOil:
        _applyCuticleOil();
        break;
      case ToolType.disinfectantSpray:
        _applyDisinfectantSpray();
        break;
      case ToolType.sterilizedGauze:
        _applySterilizedGauze();
        break;
      default:
        break;
    }
    
    appliedActions.add('${tool.type.toString().split('.').last}_${DateTime.now().millisecondsSinceEpoch}');
    tool.use();
  }
  
  void _applyCuticlePusher() {
    if (hasCuticle) {
      hasCuticle = false;
      condition = NailCondition.clean;
    }
  }
  
  void _applyNailFile() {
    if (needsFiling) {
      needsFiling = false;
      length = min(1.0, length + 0.1);
      condition = NailCondition.healthy;
    }
  }
  
  void _applyPolishBrush(Color color) {
    polishColor = color;
    hasPolish = true;
    polishCoverage = min(1.0, polishCoverage + 0.25);
    
    // Base coat should be applied first
    if (!hasBaseCoat && polishCoverage <= 0.25) {
      hasBaseCoat = true;
    }
  }
  
  void _applyBuffer() {
    shineLevel = min(1.0, shineLevel + 0.3);
    condition = NailCondition.healthy;
  }
  
  void _applyCuticleNipper() {
    if (hasCuticle) {
      hasCuticle = false;
      // More aggressive than pusher
      condition = NailCondition.clean;
    }
  }
  
  void _applyCottonPad() {
    // Used for cleaning or polish removal
    if (hasPolish && polishCoverage < 0.5) {
      hasPolish = false;
      polishCoverage = 0.0;
      polishColor = Colors.transparent;
    }
    condition = NailCondition.clean;
  }
  
  void _applyNailTip() {
    if (!hasExtension) {
      hasExtension = true;
      extensionType = ExtensionType.tipWithSilk;
      length = min(1.0, length + 0.4);
    }
  }
  
  void _applyHandSanitizer() {
    // Hand sanitizer doesn't change nail appearance but marks it as sanitized
    condition = NailCondition.clean;
  }
  
  void _applyUvLamp() {
    // UV lamp cures gel polish and increases shine
    if (hasPolish) {
      shineLevel = min(1.0, shineLevel + 0.4);
    }
  }
  
  void _applyRemover() {
    // Polish remover removes existing polish
    if (hasPolish) {
      hasPolish = false;
      polishCoverage = 0.0;
      polishColor = Colors.transparent;
      hasTopCoat = false;
      hasBaseCoat = false;
      shineLevel = max(0.0, shineLevel - 0.3);
    }
  }
  
  void _applySandingBlock() {
    // Sanding block smooths nail surface and removes etching/burrs
    shineLevel = min(1.0, shineLevel + 0.2);
    condition = NailCondition.healthy;
    // Additional smoothing effect could be added here
  }
  
  void _applyFingerBowl() {
    // Finger bowl soaks and softens cuticles for easier removal
    condition = NailCondition.clean;
    // Softens cuticles making them easier to push back or remove
    if (hasCuticle) {
      // Bowl treatment makes cuticle softer
      hasCuticle = true; // Keep cuticle but mark it as softened
    }
  }
  
  void _applyCuticleOil() {
    // Cuticle oil nourishes and moisturizes the cuticles
    condition = NailCondition.healthy;
    shineLevel = min(1.0, shineLevel + 0.1);
    // Oil makes cuticles healthier and easier to work with
    if (hasCuticle) {
      // Oil treatment nourishes the cuticle area
      hasCuticle = true; // Keep cuticle but it's now treated
    }
  }
  
  void _applyDisinfectantSpray() {
    // Final disinfectant spray for nail and finger sterilization
    condition = NailCondition.clean;
    // Disinfection adds a protective effect
    shineLevel = min(1.0, shineLevel + 0.05);
  }
  
  void _applySterilizedGauze() {
    // Remove oil residue and clean nail surface
    condition = NailCondition.clean;
    // Gauze cleaning removes excess oils and prepares surface
    shineLevel = max(0.0, shineLevel - 0.1); // Slight reduction as oils are removed
  }
  
  void applyPolish(Color color, double amount) {
    polishColor = color;
    hasPolish = true;
    polishCoverage = min(1.0, polishCoverage + amount);
    
    if (polishCoverage >= 1.0 && !hasTopCoat) {
      hasTopCoat = true;
    }
  }
  
  void applyBaseCoat() {
    hasBaseCoat = true;
    appliedActions.add('base_coat_${DateTime.now().millisecondsSinceEpoch}');
  }
  
  void applyTopCoat() {
    if (hasPolish && polishCoverage >= 0.75) {
      hasTopCoat = true;
      shineLevel = min(1.0, shineLevel + 0.5);
      appliedActions.add('top_coat_${DateTime.now().millisecondsSinceEpoch}');
    }
  }
  
  void reset() {
    hasCuticle = true;
    hasPolish = true;
    polishColor = Colors.red;
    polishCoverage = 1.0;
    needsFiling = true;
    hasExtension = false;
    extensionType = null;
    condition = NailCondition.clean;
    shineLevel = 0.0;
    length = 0.5;
    hasBaseCoat = false;
    hasTopCoat = false;
    appliedActions.clear();
  }
  
  // Calculate completion score for this nail
  double calculateCompletionScore() {
    double score = 0.0;
    
    // Base preparation (20%)
    if (!hasCuticle) score += 0.1;
    if (!needsFiling) score += 0.1;
    
    // Polish application (60%)
    if (hasBaseCoat) score += 0.15;
    if (hasPolish) {
      score += 0.3 * polishCoverage;
    }
    if (hasTopCoat) score += 0.15;
    
    // Finishing (20%)
    score += 0.1 * shineLevel;
    if (condition == NailCondition.healthy) score += 0.1;
    
    return min(1.0, score);
  }
  
  // Check if technique sequence is correct
  bool isSequenceCorrect() {
    // Basic sequence: cuticle care -> filing -> base coat -> polish -> top coat
    final actions = appliedActions.map((a) => a.split('_')[0]).toList();
    
    // Check for proper sequence
    int cuticleIndex = -1;
    int fileIndex = -1;
    int baseIndex = -1;
    int polishIndex = -1;
    int topIndex = -1;
    
    for (int i = 0; i < actions.length; i++) {
      switch (actions[i]) {
        case 'cuticlePusher':
        case 'cuticleNipper':
          if (cuticleIndex == -1) cuticleIndex = i;
          break;
        case 'nailFile':
          if (fileIndex == -1) fileIndex = i;
          break;
        case 'base':
          if (baseIndex == -1) baseIndex = i;
          break;
        case 'polishBrush':
          if (polishIndex == -1) polishIndex = i;
          break;
        case 'top':
          if (topIndex == -1) topIndex = i;
          break;
      }
    }
    
    // Sequence should be: cuticle < file < base < polish < top
    if (cuticleIndex >= 0 && fileIndex >= 0 && cuticleIndex > fileIndex) return false;
    if (fileIndex >= 0 && baseIndex >= 0 && fileIndex > baseIndex) return false;
    if (baseIndex >= 0 && polishIndex >= 0 && baseIndex > polishIndex) return false;
    if (polishIndex >= 0 && topIndex >= 0 && polishIndex > topIndex) return false;
    
    return true;
  }
  
  // Get visual representation data
  Map<String, dynamic> getVisualData() {
    return {
      'hasCuticle': hasCuticle,
      'hasPolish': hasPolish,
      'polishColor': polishColor.value,
      'polishCoverage': polishCoverage,
      'shineLevel': shineLevel,
      'hasExtension': hasExtension,
      'condition': condition.toString().split('.').last,
      'length': length,
    };
  }
  
  @override
  String toString() {
    return 'NailState(finger: $fingerIndex, polish: $hasPolish, coverage: ${(polishCoverage * 100).toInt()}%)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NailState &&
        other.fingerIndex == fingerIndex &&
        other.hasPolish == hasPolish &&
        other.polishColor == polishColor &&
        other.polishCoverage == polishCoverage;
  }
  
  @override
  int get hashCode {
    return Object.hash(
      fingerIndex,
      hasPolish,
      polishColor,
      polishCoverage,
    );
  }
}