// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nail_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NailState _$NailStateFromJson(Map<String, dynamic> json) => NailState(
      fingerIndex: json['fingerIndex'] as int,
      hasCuticle: json['hasCuticle'] as bool? ?? true,
      hasPolish: json['hasPolish'] as bool? ?? true,
      polishColor: json['polishColor'] == null
          ? const Color(0xFFFF0000)
          : Color(json['polishColor'] as int),
      polishCoverage: (json['polishCoverage'] as num?)?.toDouble() ?? 1.0,
      needsFiling: json['needsFiling'] as bool? ?? true,
      hasExtension: json['hasExtension'] as bool? ?? false,
      extensionType: json['extensionType'] == null
          ? null
          : ExtensionType.values[json['extensionType'] as int],
      condition: json['condition'] == null
          ? NailCondition.clean
          : NailCondition.values[json['condition'] as int],
      shineLevel: (json['shineLevel'] as num?)?.toDouble() ?? 0.0,
      length: (json['length'] as num?)?.toDouble() ?? 0.5,
      hasBaseCoat: json['hasBaseCoat'] as bool? ?? false,
      hasTopCoat: json['hasTopCoat'] as bool? ?? false,
      appliedActions: (json['appliedActions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$NailStateToJson(NailState instance) => <String, dynamic>{
      'fingerIndex': instance.fingerIndex,
      'hasCuticle': instance.hasCuticle,
      'hasPolish': instance.hasPolish,
      'polishColor': instance.polishColor.value,
      'polishCoverage': instance.polishCoverage,
      'needsFiling': instance.needsFiling,
      'hasExtension': instance.hasExtension,
      'extensionType': instance.extensionType?.index,
      'condition': instance.condition.index,
      'shineLevel': instance.shineLevel,
      'length': instance.length,
      'hasBaseCoat': instance.hasBaseCoat,
      'hasTopCoat': instance.hasTopCoat,
      'appliedActions': instance.appliedActions,
    };