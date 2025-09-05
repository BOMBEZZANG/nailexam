// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nail_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NailState _$NailStateFromJson(Map<String, dynamic> json) => NailState(
  fingerIndex: (json['fingerIndex'] as num).toInt(),
  hasCuticle: json['hasCuticle'] as bool? ?? true,
  hasPolish: json['hasPolish'] as bool? ?? true,
  polishColor:
      json['polishColor'] == null
          ? Colors.red
          : NailState._colorFromJson((json['polishColor'] as num).toInt()),
  polishCoverage: (json['polishCoverage'] as num?)?.toDouble() ?? 1.0,
  needsFiling: json['needsFiling'] as bool? ?? true,
  hasExtension: json['hasExtension'] as bool? ?? false,
  extensionType: $enumDecodeNullable(
    _$ExtensionTypeEnumMap,
    json['extensionType'],
  ),
  condition:
      $enumDecodeNullable(_$NailConditionEnumMap, json['condition']) ??
      NailCondition.clean,
  shineLevel: (json['shineLevel'] as num?)?.toDouble() ?? 0.0,
  length: (json['length'] as num?)?.toDouble() ?? 0.5,
  hasBaseCoat: json['hasBaseCoat'] as bool? ?? false,
  hasTopCoat: json['hasTopCoat'] as bool? ?? false,
  appliedActions:
      (json['appliedActions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
);

Map<String, dynamic> _$NailStateToJson(NailState instance) => <String, dynamic>{
  'fingerIndex': instance.fingerIndex,
  'hasCuticle': instance.hasCuticle,
  'hasPolish': instance.hasPolish,
  'polishColor': NailState._colorToJson(instance.polishColor),
  'polishCoverage': instance.polishCoverage,
  'needsFiling': instance.needsFiling,
  'hasExtension': instance.hasExtension,
  'extensionType': _$ExtensionTypeEnumMap[instance.extensionType],
  'condition': _$NailConditionEnumMap[instance.condition]!,
  'shineLevel': instance.shineLevel,
  'length': instance.length,
  'hasBaseCoat': instance.hasBaseCoat,
  'hasTopCoat': instance.hasTopCoat,
  'appliedActions': instance.appliedActions,
};

const _$ExtensionTypeEnumMap = {
  ExtensionType.silk: 'silk',
  ExtensionType.tipWithSilk: 'tipWithSilk',
  ExtensionType.acrylic: 'acrylic',
  ExtensionType.gel: 'gel',
};

const _$NailConditionEnumMap = {
  NailCondition.clean: 'clean',
  NailCondition.dirty: 'dirty',
  NailCondition.damaged: 'damaged',
  NailCondition.healthy: 'healthy',
};
