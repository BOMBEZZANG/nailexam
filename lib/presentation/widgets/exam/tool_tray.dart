import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/models/tool.dart';

class ToolTray extends StatefulWidget {
  final Tool? selectedTool;
  final Set<Tool>? selectedTools;
  final Function(Tool) onToolSelected;
  final bool isCompact;
  final Set<ToolType>? highlightedTools;

  const ToolTray({
    super.key,
    this.selectedTool,
    this.selectedTools,
    required this.onToolSelected,
    this.isCompact = false,
    this.highlightedTools,
  });

  @override
  State<ToolTray> createState() => _ToolTrayState();
}

class _ToolTrayState extends State<ToolTray> {
  final List<Tool> _tools = [
    // Original tools
    Tool(
      id: 'nail_file',
      name: '네일파일',
      type: ToolType.nailFile,
      description: '네일 모양을 다듬는 도구',
    ),
    Tool(
      id: 'buffer',
      name: '버퍼',
      type: ToolType.buffer,
      description: '네일 표면을 매끄럽게 만드는 도구',
    ),
    Tool(
      id: 'cuticle_pusher',
      name: '큐티클 푸셔',
      type: ToolType.cuticlePusher,
      description: '큐티클을 밀어주는 도구',
    ),
    Tool(
      id: 'polish_brush',
      name: '폴리시 브러시',
      type: ToolType.polishBrush,
      description: '매니큐어를 바르는 브러시',
    ),
    Tool(
      id: 'nail_tips',
      name: '네일팁',
      type: ToolType.nailTips,
      description: '인조 네일 연장용',
    ),
    Tool(
      id: 'cotton_pad',
      name: '코튼패드',
      type: ToolType.cottonPad,
      description: '매니큐어 제거용',
      isConsumable: true,
    ),
    // New 7 tools
    Tool(
      id: 'hand_sanitizer',
      name: '손소독제',
      type: ToolType.handSanitizer,
      description: '손을 소독하는 소독제',
    ),
    Tool(
      id: 'disinfectant_spray',
      name: '소독 스프레이',
      type: ToolType.disinfectantSpray,
      description: '도구를 소독하는 스프레이',
    ),
    Tool(
      id: 'cuticle_oil',
      name: '큐티클 오일',
      type: ToolType.cuticleOil,
      description: '큐티클을 부드럽게 하는 오일',
    ),
    Tool(
      id: 'finger_bowl',
      name: '핑거볼',
      type: ToolType.fingerBowl,
      description: '손가락을 담그는 그릇',
    ),
    Tool(
      id: 'sanding_block',
      name: '샌딩블록',
      type: ToolType.sandingBlock,
      description: '네일을 다듬는 블록',
    ),
    Tool(
      id: 'remover',
      name: '제거제',
      type: ToolType.remover,
      description: '매니큐어를 제거하는 제거제',
    ),
    Tool(
      id: 'cuticle_nipper',
      name: '니퍼',
      type: ToolType.cuticleNipper,
      description: '큐티클을 자르는 도구',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.isCompact) {
      return _buildHorizontalLayout();
    } else {
      return _buildVerticalLayout();
    }
  }

  Widget _buildHorizontalLayout() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _tools.map((tool) => _buildHorizontalToolItem(tool)).toList(),
        ),
      ),
    );
  }

  Widget _buildVerticalLayout() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.85,
        ),
        itemCount: _tools.length,
        itemBuilder: (context, index) => _buildVerticalToolItem(_tools[index]),
      ),
    );
  }

  Widget _buildHorizontalToolItem(Tool tool) {
    final isSelected = widget.selectedTool?.id == tool.id ||
        (widget.selectedTools?.contains(tool) ?? false);
    final isHighlighted = widget.highlightedTools?.contains(tool.type) ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: () => _selectTool(tool),
        onLongPress: () => _showToolDetails(tool),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 70,
          height: 90,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).primaryColor.withOpacity(0.15)
                : isHighlighted
                    ? Colors.orange.withOpacity(0.1)
                    : Colors.white,
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : isHighlighted
                      ? Colors.orange
                      : Colors.grey.withOpacity(0.3),
              width: isSelected || isHighlighted ? 2.5 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? Theme.of(context).primaryColor.withOpacity(0.3)
                    : isHighlighted
                        ? Colors.orange.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.1),
                blurRadius: isSelected || isHighlighted ? 8 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Tool icon
              _buildToolIcon(tool, isSelected),
              const SizedBox(height: 6),
              // Tool name
              Text(
                tool.name,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : isHighlighted
                          ? Colors.orange
                          : Colors.grey[700],
                  fontWeight: isSelected || isHighlighted ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalToolItem(Tool tool) {
    final isSelected = widget.selectedTool?.id == tool.id ||
        (widget.selectedTools?.contains(tool) ?? false);
    final isHighlighted = widget.highlightedTools?.contains(tool.type) ?? false;

    return GestureDetector(
      onTap: () => _selectTool(tool),
      onLongPress: () => _showToolDetails(tool),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.15)
              : isHighlighted
                  ? Colors.orange.withOpacity(0.1)
                  : Colors.white,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : isHighlighted
                    ? Colors.orange
                    : Colors.grey.withOpacity(0.3),
            width: isSelected || isHighlighted ? 2.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Theme.of(context).primaryColor.withOpacity(0.3)
                  : isHighlighted
                      ? Colors.orange.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.1),
              blurRadius: isSelected || isHighlighted ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tool icon
            _buildToolIcon(tool, isSelected),
            const SizedBox(height: 8),
            // Tool name
            Text(
              tool.name,
              style: TextStyle(
                fontSize: 11,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : isHighlighted
                        ? Colors.orange
                        : Colors.grey[700],
                fontWeight: isSelected || isHighlighted ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolIcon(Tool tool, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: widget.isCompact ? 32 : 40,
      height: widget.isCompact ? 32 : 40,
      child: _getToolIcon(tool, isSelected),
    );
  }

  Widget _getToolIcon(Tool tool, bool isSelected) {
    // For now, use basic icons. Later this will use AssetManager.instance.getToolImage()
    IconData iconData;
    final isHighlighted = widget.highlightedTools?.contains(tool.type) ?? false;
    Color iconColor = isSelected 
        ? Theme.of(context).primaryColor 
        : isHighlighted
            ? Colors.orange
            : Colors.grey.shade600;

    switch (tool.type) {
      // Original tools
      case ToolType.nailFile:
        iconData = Icons.straighten;
        break;
      case ToolType.buffer:
        iconData = Icons.rectangle;
        break;
      case ToolType.cuticlePusher:
        iconData = Icons.push_pin;
        break;
      case ToolType.polishBrush:
        iconData = Icons.brush;
        break;
      case ToolType.nailTips:
        iconData = Icons.layers;
        break;
      case ToolType.cottonPad:
        iconData = Icons.circle;
        break;
      // New 7 tools
      case ToolType.handSanitizer:
        iconData = Icons.local_pharmacy;
        break;
      case ToolType.disinfectantSpray:
        iconData = Icons.cleaning_services;
        break;
      case ToolType.cuticleOil:
        iconData = Icons.water_drop;
        break;
      case ToolType.fingerBowl:
        iconData = Icons.water;
        break;
      case ToolType.sandingBlock:
        iconData = Icons.square;
        break;
      case ToolType.remover:
        iconData = Icons.delete;
        break;
      case ToolType.cuticleNipper:
        iconData = Icons.content_cut;
        break;
      default:
        iconData = Icons.build;
    }

    return Icon(
      iconData,
      size: widget.isCompact ? 24 : 28,
      color: iconColor,
    );
  }

  void _selectTool(Tool tool) {
    HapticFeedback.lightImpact();
    widget.onToolSelected(tool);
  }

  void _showToolDetails(Tool tool) {
    HapticFeedback.mediumImpact();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(tool.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tool.description),
              const SizedBox(height: 8),
              if (tool.isConsumable)
                Text(
                  '소모품: 사용 횟수 ${tool.usageCount}회',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade700,
                  ),
                ),
              Text(
                '도구 타입: ${_getToolTypeName(tool.type)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  String _getToolTypeName(ToolType type) {
    switch (type) {
      case ToolType.nailFile:
        return '네일파일';
      case ToolType.buffer:
        return '버퍼';
      case ToolType.cuticlePusher:
        return '큐티클 푸셔';
      case ToolType.polishBrush:
        return '폴리시 브러시';
      case ToolType.nailTips:
        return '네일팁';
      case ToolType.cottonPad:
        return '코튼패드';
      default:
        return '기타';
    }
  }
}