import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ColorPalette extends StatefulWidget {
  final Color? selectedColor;
  final Function(Color) onColorSelected;
  final bool isCompact;

  const ColorPalette({
    super.key,
    this.selectedColor,
    required this.onColorSelected,
    this.isCompact = false,
  });

  @override
  State<ColorPalette> createState() => _ColorPaletteState();
}

class _ColorPaletteState extends State<ColorPalette> {
  final List<Color> _baseColors = [
    // Basic nail polish colors
    const Color(0xFFE8B4B8), // Light Pink
    const Color(0xFFD63384), // Hot Pink
    const Color(0xFFDC3545), // Red
    const Color(0xFF6F42C1), // Purple
    const Color(0xFF0D6EFD), // Blue
    const Color(0xFF198754), // Green
    const Color(0xFFFFC107), // Yellow
    const Color(0xFFFD7E14), // Orange
    const Color(0xFF6C757D), // Gray
    const Color(0xFF212529), // Black
    const Color(0xFFFFFFFF), // White
    const Color(0xFFF8F9FA), // Clear/Base
  ];

  final List<Color> _popularColors = [
    // Popular nail polish shades
    const Color(0xFFFFB6C1), // Light Pink
    const Color(0xFFFF69B4), // Hot Pink
    const Color(0xFFFF1493), // Deep Pink
    const Color(0xFFB22222), // Fire Brick
    const Color(0xFF8B0000), // Dark Red
    const Color(0xFF4B0082), // Indigo
    const Color(0xFF9370DB), // Medium Purple
    const Color(0xFF20B2AA), // Light Sea Green
    const Color(0xFF00CED1), // Dark Turquoise
    const Color(0xFFFFD700), // Gold
    const Color(0xFFFFA500), // Orange
    const Color(0xFF2F4F4F), // Dark Slate Gray
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
          children: [
            ..._baseColors.map((color) => _buildHorizontalColorItem(color)),
            const SizedBox(width: 8),
            Container(
              width: 1,
              height: 40,
              color: Colors.grey.shade300,
            ),
            const SizedBox(width: 8),
            ..._popularColors.take(8).map((color) => _buildHorizontalColorItem(color)),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalLayout() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '기본 색상',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: _baseColors.length,
            itemBuilder: (context, index) => _buildVerticalColorItem(_baseColors[index]),
          ),
          const SizedBox(height: 16),
          Text(
            '인기 색상',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: _popularColors.length,
            itemBuilder: (context, index) => _buildVerticalColorItem(_popularColors[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalColorItem(Color color) {
    final isSelected = widget.selectedColor == color;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: GestureDetector(
        onTap: () => _selectColor(color),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected 
                  ? Theme.of(context).primaryColor
                  : (color == Colors.white || color == const Color(0xFFF8F9FA))
                      ? Colors.grey.shade400
                      : Colors.transparent,
              width: isSelected ? 3 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? Theme.of(context).primaryColor.withOpacity(0.4)
                    : Colors.black.withOpacity(0.1),
                blurRadius: isSelected ? 8 : 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: isSelected
              ? Icon(
                  Icons.check,
                  color: _getContrastColor(color),
                  size: 20,
                  shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildVerticalColorItem(Color color) {
    final isSelected = widget.selectedColor == color;
    
    return GestureDetector(
      onTap: () => _selectColor(color),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).primaryColor
                : (color == Colors.white || color == const Color(0xFFF8F9FA))
                    ? Colors.grey.shade400
                    : Colors.transparent,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Theme.of(context).primaryColor.withOpacity(0.4)
                  : Colors.black.withOpacity(0.1),
              blurRadius: isSelected ? 8 : 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isSelected
            ? Icon(
                Icons.check,
                color: _getContrastColor(color),
                size: 18,
                shadows: const [Shadow(color: Colors.black26, blurRadius: 1)],
              )
            : null,
      ),
    );
  }

  void _selectColor(Color color) {
    HapticFeedback.lightImpact();
    widget.onColorSelected(color);
  }

  Color _getContrastColor(Color color) {
    // Calculate luminance to determine if we need white or black text
    final luminance = (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}