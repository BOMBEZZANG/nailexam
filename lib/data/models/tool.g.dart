// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tool.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tool _$ToolFromJson(Map<String, dynamic> json) => Tool(
      id: json['id'] as String,
      name: json['name'] as String,
      type: ToolType.values.firstWhere((e) => e.toString().split('.').last == json['type']),
      iconPath: json['iconPath'] as String,
      isConsumable: json['isConsumable'] as bool? ?? false,
      usageCount: json['usageCount'] as int? ?? 0,
    );

Map<String, dynamic> _$ToolToJson(Tool instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type.toString().split('.').last,
      'iconPath': instance.iconPath,
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
  ToolType.uvLamp: 'uvLamp',
  ToolType.remover: 'remover',
  ToolType.handSanitizer: 'handSanitizer',
  ToolType.sandingBlock: 'sandingBlock',
  ToolType.fingerBowl: 'fingerBowl',
  ToolType.cuticleOil: 'cuticleOil',
};