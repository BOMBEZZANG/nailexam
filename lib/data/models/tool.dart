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
  uvLamp,
  remover,
}

@JsonSerializable()
class Tool {
  final String id;
  final String name;
  final ToolType type;
  final String iconPath;
  final bool isConsumable;
  int usageCount;
  
  Tool({
    required this.id,
    required this.name,
    required this.type,
    required this.iconPath,
    this.isConsumable = false,
    this.usageCount = 0,
  });
  
  factory Tool.fromJson(Map<String, dynamic> json) => 
      _$ToolFromJson(json);
  
  Map<String, dynamic> toJson() => _$ToolToJson(this);
  
  void use() {
    usageCount++;
  }
  
  static List<Tool> getDefaultTools() {
    return [
      Tool(
        id: 'nail_file',
        name: 'Nail File',
        type: ToolType.nailFile,
        iconPath: 'assets/tools/nail_file.png',
      ),
      Tool(
        id: 'buffer',
        name: 'Buffer',
        type: ToolType.buffer,
        iconPath: 'assets/tools/buffer.png',
      ),
      Tool(
        id: 'cuticle_pusher',
        name: 'Cuticle Pusher',
        type: ToolType.cuticlePusher,
        iconPath: 'assets/tools/cuticle_pusher.png',
      ),
      Tool(
        id: 'polish_brush',
        name: 'Polish Brush',
        type: ToolType.polishBrush,
        iconPath: 'assets/tools/polish_brush.png',
      ),
      Tool(
        id: 'nail_tips',
        name: 'Nail Tips',
        type: ToolType.nailTips,
        iconPath: 'assets/tools/nail_tips.png',
        isConsumable: true,
      ),
      Tool(
        id: 'cotton_pad',
        name: 'Cotton Pad',
        type: ToolType.cottonPad,
        iconPath: 'assets/tools/cotton_pad.png',
        isConsumable: true,
      ),
      Tool(
        id: 'cuticle_nipper',
        name: 'Cuticle Nipper',
        type: ToolType.cuticleNipper,
        iconPath: 'assets/tools/cuticle_nipper.png',
      ),
    ];
  }
}