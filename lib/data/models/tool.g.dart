// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tool.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tool _$ToolFromJson(Map<String, dynamic> json) => Tool(
  id: json['id'] as String,
  name: json['name'] as String,
  type: $enumDecode(_$ToolTypeEnumMap, json['type']),
  description: json['description'] as String,
  isConsumable: json['isConsumable'] as bool? ?? false,
  usageCount: (json['usageCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ToolToJson(Tool instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': _$ToolTypeEnumMap[instance.type]!,
  'description': instance.description,
  'isConsumable': instance.isConsumable,
  'usageCount': instance.usageCount,
};

const _$ToolTypeEnumMap = {
  ToolType.nailFile: 'nailFile',
  ToolType.buffer: 'buffer',
  ToolType.cuticlePusher: 'cuticlePusher',
  ToolType.polishBrush: 'polishBrush',
  ToolType.nailTips: 'nailTips',
  ToolType.cottonPad: 'cottonPad',
  ToolType.cuticleNipper: 'cuticleNipper',
  ToolType.handSanitizer: 'handSanitizer',
  ToolType.uvLamp: 'uvLamp',
  ToolType.remover: 'remover',
  ToolType.sandingBlock: 'sandingBlock',
  ToolType.fingerBowl: 'fingerBowl',
  ToolType.cuticleOil: 'cuticleOil',
  ToolType.disinfectantSpray: 'disinfectantSpray',
  ToolType.sterilizedGauze: 'sterilizedGauze',
};
