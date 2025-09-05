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
  handSanitizer,
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
        id: 'hand_sanitizer',
        name: '손소독제',
        type: ToolType.handSanitizer,
        iconPath: 'assets/tools/hand_sanitizer.png',
        isConsumable: true,
      ),
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
        name: '큐티클 푸셔',
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
      Tool(
        id: 'remover',
        name: 'Polish Remover',
        type: ToolType.remover,
        iconPath: 'assets/tools/remover.png',
        isConsumable: true,
      ),
      Tool(
        id: 'sanding_block',
        name: 'Sanding Block',
        type: ToolType.sandingBlock,
        iconPath: 'assets/tools/sanding_block.png',
      ),
      Tool(
        id: 'finger_bowl',
        name: '핑거볼',
        type: ToolType.fingerBowl,
        iconPath: 'assets/tools/finger_bowl.png',
      ),
      Tool(
        id: 'cuticle_oil',
        name: '큐티클 오일',
        type: ToolType.cuticleOil,
        iconPath: 'assets/tools/cuticle_oil.png',
        isConsumable: true,
      ),
      Tool(
        id: 'disinfectant_spray',
        name: '소독제 스프레이',
        type: ToolType.disinfectantSpray,
        iconPath: 'assets/tools/disinfectant_spray.png',
        isConsumable: true,
      ),
      Tool(
        id: 'sterilized_gauze',
        name: '멸균 거즈',
        type: ToolType.sterilizedGauze,
        iconPath: 'assets/tools/sterilized_gauze.png',
        isConsumable: true,
      ),
    ];
  }
}