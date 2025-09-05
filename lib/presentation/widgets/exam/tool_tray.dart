import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/models/tool.dart';
import '../../../managers/asset_manager.dart';

class ToolTray extends StatefulWidget {
  final Function(Tool) onToolSelected;
  final Tool? selectedTool;
  final Set<Tool>? selectedTools; // Add support for multiple selected tools
  final bool isVisible;
  final bool isHorizontal; // Add horizontal layout option
  final Set<ToolType> requiredTools; // Required tools for current step

  const ToolTray({
    super.key,
    required this.onToolSelected,
    this.selectedTool,
    this.selectedTools,
    this.isVisible = true,
    this.isHorizontal = false,
    this.requiredTools = const {},
  });

  @override
  State<ToolTray> createState() => _ToolTrayState();
}

class _ToolTrayState extends State<ToolTray>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  final List<Tool> _availableTools = Tool.getDefaultTools();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    if (widget.isVisible) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(ToolTray oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // vertical 모드일 때 적절한 높이 계산
    final containerHeight = widget.isHorizontal
        ? 120.0 // Single row height
        : MediaQuery.of(context).size.height *
              0.5; // 화면 높이의 50% 또는 원하는 고정값(예: 400.0)

    final containerWidth = widget.isHorizontal
        ? MediaQuery.of(context)
              .size
              .width // horizontal일 때 전체 너비
        : 200.0; // vertical일 때 고정 너비

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: widget.isHorizontal
              ? Offset(0, 60 * _slideAnimation.value)
              : Offset(120 * _slideAnimation.value, 0),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: containerWidth,
              height: containerHeight,
              // constraints: BoxConstraints(
              //   maxHeight: MediaQuery.of(context).size.height * 0.7, // 최대 높이 제한
              //   minHeight: 200, // 최소 높이 보장
              // ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: widget.isHorizontal
                  ? _buildHorizontalToolSelection()
                  : Column(
                      children: [
                        // Handle bar (vertical)
                        Container(
                          width: 4,
                          height: 40,
                          margin: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),

                        // Tool selection area
                        Expanded(child: _buildVerticalToolSelection()),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHorizontalToolSelection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 80, // Fixed height for single row
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _availableTools.length,
          itemBuilder: (context, index) {
            final tool = _availableTools[index];
            return Container(
              width: 70,
              margin: const EdgeInsets.only(right: 12),
              child: _buildHorizontalGridToolItem(tool, index),
            );
          },
        ),
      ),
    );
  }

  Widget _buildVerticalToolSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Column(
        children: [
          // Tool grid (vertical)
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.vertical,
              itemCount: _availableTools.length,
              itemBuilder: (context, index) {
                return _buildVerticalToolItem(_availableTools[index], index);
              },
            ),
          ),

          // Selected tool indicator
          if (widget.selectedTool != null)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.check,
                size: 12,
                color: Theme.of(context).primaryColor,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildToolItem(Tool tool, int index) {
    final isSelected = widget.selectedTool?.id == tool.id;
    final isUsed = tool.usageCount > 0;

    return GestureDetector(
      onTap: () => _selectTool(tool),
      onLongPress: () => _showToolDetails(tool),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.all(6),
        width: 64,
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.15)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tool icon with usage indicator
            Stack(
              alignment: Alignment.topRight,
              children: [
                _buildToolIcon(tool, isSelected),
                if (isUsed)
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: Center(
                      child: Text(
                        tool.usageCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 4),

            // Tool name
            Text(
              tool.name,
              style: TextStyle(
                fontSize: 9,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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

  Widget _buildVerticalToolItem(Tool tool, int index) {
    final isSelected =
        widget.selectedTool?.id == tool.id ||
        (widget.selectedTools?.contains(tool) ?? false);
    final isUsed = tool.usageCount > 0;

    return GestureDetector(
      onTap: () => _selectTool(tool),
      onLongPress: () => _showToolDetails(tool),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.all(6),
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.15)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Tool icon
            AssetManager.instance.getToolImage(tool.id, size: 32),

            // Usage indicator
            if (isUsed)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: Center(
                    child: Text(
                      tool.usageCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalGridToolItem(Tool tool, int index) {
    final isSelected =
        widget.selectedTool?.id == tool.id ||
        (widget.selectedTools?.contains(tool) ?? false);
    final isUsed = tool.usageCount > 0;
    final isRequired = widget.requiredTools.contains(tool.type);

    return GestureDetector(
      onTap: () => _selectTool(tool),
      onLongPress: () => _showToolDetails(tool),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tool label (only show when selected or required)
          if (isSelected || isRequired)
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isRequired
                    ? Colors.orange
                    : Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getToolLabel(tool.type),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          // Tool icon container
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isRequired
                    ? Colors.orange.withOpacity(0.2)
                    : Colors.grey[100],
                border: Border.all(
                  color: isRequired
                      ? Colors.orange
                      : isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey.withOpacity(0.4),
                  width: isRequired || isSelected ? 3 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isRequired
                        ? Colors.orange.withOpacity(0.4)
                        : isSelected
                        ? Theme.of(context).primaryColor.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.2),
                    blurRadius: isRequired || isSelected ? 8 : 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Tool icon - made bigger
                  Center(
                    child: AssetManager.instance.getToolImage(
                      tool.id,
                      size: 36,
                    ),
                  ),

                  // Selection indicator
                  if (isSelected)
                    const Center(
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 24,
                        shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                      ),
                    ),

                  // Usage indicator
                  if (isUsed)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Center(
                          child: Text(
                            tool.usageCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalToolItem(Tool tool, int index) {
    final isSelected =
        widget.selectedTool?.id == tool.id ||
        (widget.selectedTools?.contains(tool) ?? false);
    final isUsed = tool.usageCount > 0;

    return GestureDetector(
      onTap: () => _selectTool(tool),
      onLongPress: () => _showToolDetails(tool),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(6),
        width: 80,
        height: 90,
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.15)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tool icon with usage indicator
            Stack(
              alignment: Alignment.topRight,
              children: [
                AssetManager.instance.getToolImage(tool.id, size: 32),
                if (isUsed)
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: Center(
                      child: Text(
                        tool.usageCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 6,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 4),

            // Tool name
            Text(
              tool.name,
              style: TextStyle(
                fontSize: 8,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
      width: 32,
      height: 32,
      child: AssetManager.instance.getToolImage(tool.id, size: 32),
    );
  }

  Widget _buildToolInfoPanel() {
    if (widget.selectedTool == null) {
      return Container(
        width: 80,
        padding: const EdgeInsets.all(8),
        child: Center(
          child: Text(
            '도구\n선택',
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final tool = widget.selectedTool!;

    return Container(
      width: 80,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getToolStatusIcon(tool),
            size: 20,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 4),
          Text(
            '활성',
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (tool.isConsumable)
            Text(
              '${tool.usageCount}x',
              style: TextStyle(fontSize: 8, color: Colors.grey[600]),
            ),
        ],
      ),
    );
  }

  IconData _getToolStatusIcon(Tool tool) {
    switch (tool.type) {
      case ToolType.nailFile:
        return Icons.straighten;
      case ToolType.buffer:
        return Icons.square_rounded;
      case ToolType.cuticlePusher:
        return Icons.push_pin;
      case ToolType.polishBrush:
        return Icons.brush;
      case ToolType.nailTips:
        return Icons.layers;
      case ToolType.cottonPad:
        return Icons.circle;
      case ToolType.cuticleNipper:
        return Icons.content_cut;
      case ToolType.handSanitizer:
        return Icons.local_hospital;
      case ToolType.uvLamp:
        return Icons.lightbulb;
      case ToolType.remover:
        return Icons.invert_colors_off;
      case ToolType.sandingBlock:
        return Icons.grid_on;
      case ToolType.fingerBowl:
        return Icons.local_drink;
      case ToolType.cuticleOil:
        return Icons.colorize;
      case ToolType.disinfectantSpray:
        return Icons.air;
      case ToolType.sterilizedGauze:
        return Icons.healing;
      default:
        return Icons.build;
    }
  }

  void _selectTool(Tool tool) {
    widget.onToolSelected(tool);
    HapticFeedback.selectionClick();

    // Animate selection
    _animateToolSelection();
  }

  void _animateToolSelection() {
    _animationController.reverse().then((_) {
      _animationController.forward();
    });
  }

  void _showToolDetails(Tool tool) {
    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildToolDetailsSheet(tool),
    );
  }

  Widget _buildToolDetailsSheet(Tool tool) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              AssetManager.instance.getToolImage(tool.id, size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tool.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getToolDescription(tool.type),
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Usage stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('사용', '${tool.usageCount}번'),
              _buildStatItem('유형', tool.isConsumable ? '소모품' : '재사용'),
              _buildStatItem('상태', '준비됨'),
            ],
          ),

          const SizedBox(height: 16),

          // Instructions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '사용 방법:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  _getToolInstructions(tool.type),
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }

  String _getToolDescription(ToolType type) {
    switch (type) {
      case ToolType.nailFile:
        return '네일 모양을 다듬고 매끄럽게 만듬';
      case ToolType.buffer:
        return '네일 표면을 광택나게 만듬';
      case ToolType.cuticlePusher:
        return '큐티클을 밀어올림';
      case ToolType.polishBrush:
        return '네일 폴리쉬를 바름';
      case ToolType.nailTips:
        return '네일 익스텐션을 붙임';
      case ToolType.cottonPad:
        return '네일을 세정하고 폴리쉬를 제거';
      case ToolType.cuticleNipper:
        return '과도한 큐티클을 자름';
      case ToolType.handSanitizer:
        return '손과 네일을 소독하여 위생을 유지';
      case ToolType.uvLamp:
        return '젤 네일을 경화시킴';
      case ToolType.remover:
        return '네일 폴리쉬를 제거함';
      case ToolType.sandingBlock:
        return '네일 표면을 매끄럽게 하고 거스러미 제거';
      case ToolType.fingerBowl:
        return '손가락을 담가 큐티클을 부드럽게 함';
      case ToolType.cuticleOil:
        return '큐티클을 영양 공급하고 보습';
      case ToolType.disinfectantSpray:
        return '네일과 손가락 최종 소독';
      case ToolType.sterilizedGauze:
        return '유분기 제거 및 표면 정리';
      default:
        return '네일 케어 도구';
    }
  }

  String _getToolInstructions(ToolType type) {
    switch (type) {
      case ToolType.nailFile:
        return '네일 가장자리를 한 방향으로 드래그하세요. 부드럽게 압력을 가하세요.';
      case ToolType.buffer:
        return '네일 표면에 원형 운동으로 매끄럽게 만듭니다.';
      case ToolType.cuticlePusher:
        return '큐티클을 부드럽게 밀어올리세요. 부드럽게 만든 후 사용하세요.';
      case ToolType.polishBrush:
        return '얇고 균등하게 바르세요. 베이스코트부터 시작하세요.';
      case ToolType.nailTips:
        return '적절한 크기를 선택하고 네일글루로 붙이세요.';
      case ToolType.cottonPad:
        return '리무버와 함께 사용하여 네일과 큐티클을 세정하세요.';
      case ToolType.cuticleNipper:
        return '과도한 죽은 피부만 조심스럽게 자르세요.';
      case ToolType.handSanitizer:
        return '각 손가락에 터치하여 소독합니다. 모든 5개 손가락을 소독하세요.';
      case ToolType.uvLamp:
        return '손을 램프 아래에 두고 젤을 경화시키세요.';
      case ToolType.remover:
        return '코튼패드와 함께 사용하여 기존 폴리쉬를 제거하세요.';
      case ToolType.sandingBlock:
        return '네일 표면을 부드럽게 샌딩하여 거스러미를 제거하세요.';
      case ToolType.fingerBowl:
        return '각 손가락을 볼에 담가 큐티클을 부드럽게 만드세요.';
      case ToolType.cuticleOil:
        return '각 큐티클 주변에 오일을 바르고 마사지하세요.';
      case ToolType.disinfectantSpray:
        return '네일과 손가락에 스프레이하여 최종 소독을 완료하세요.';
      case ToolType.sterilizedGauze:
        return '멸균된 거즈로 네일 표면의 유분기를 제거하세요.';
      default:
        return '네일 케어 베스트 프랙티스에 따라 사용하세요.';
    }
  }

  String _getToolLabel(ToolType type) {
    switch (type) {
      case ToolType.nailFile:
        return '네일파일';
      case ToolType.buffer:
        return '버퍼';
      case ToolType.cuticlePusher:
        return '푸셔';
      case ToolType.polishBrush:
        return '브러시';
      case ToolType.nailTips:
        return '팁';
      case ToolType.cottonPad:
        return '코튼패드';
      case ToolType.cuticleNipper:
        return '니퍼';
      case ToolType.handSanitizer:
        return '손소독제';
      case ToolType.uvLamp:
        return 'UV램프';
      case ToolType.remover:
        return '제거제';
      case ToolType.sandingBlock:
        return '샌딩블록';
      case ToolType.fingerBowl:
        return '핑거볼';
      case ToolType.cuticleOil:
        return '큐티클오일';
      case ToolType.disinfectantSpray:
        return '소독스프레이';
      case ToolType.sterilizedGauze:
        return '멸균거즈';
      default:
        return '도구';
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
