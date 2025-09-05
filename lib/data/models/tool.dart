import 'package:json_annotation/json_annotation.dart';

part 'tool.g.dart';

enum ToolType {
  nailFile,
  buffer,
  cuticlePusher,
  polishBrush,
  nailTips,
  cottonPad,
  cuticleNipper,
  handSanitizer,
  uvLamp,
  remover,
  sandingBlock,
  fingerBowl,
  cuticleOil,
  disinfectantSpray,
  sterilizedGauze,
}

@JsonSerializable()
class Tool {
  final String id;
  final String name;
  final ToolType type;
  final String description;
  final bool isConsumable;
  int usageCount;

  Tool({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    this.isConsumable = false,
    this.usageCount = 0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tool && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  void use() {
    usageCount++;
  }

  Tool copyWith({
    String? id,
    String? name,
    ToolType? type,
    String? description,
    bool? isConsumable,
    int? usageCount,
  }) {
    return Tool(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      isConsumable: isConsumable ?? this.isConsumable,
      usageCount: usageCount ?? this.usageCount,
    );
  }

  factory Tool.fromJson(Map<String, dynamic> json) => _$ToolFromJson(json);
  Map<String, dynamic> toJson() => _$ToolToJson(this);

  @override
  String toString() {
    return 'Tool{id: $id, name: $name, type: $type, usageCount: $usageCount}';
  }
}