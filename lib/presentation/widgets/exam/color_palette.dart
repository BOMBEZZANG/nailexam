import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ColorPalette extends StatefulWidget {
  final Function(Color) onColorSelected;
  final Color? selectedColor;
  final bool isVisible;

  const ColorPalette({
    super.key,
    required this.onColorSelected,
    this.selectedColor,
    this.isVisible = true,
  });

  @override
  State<ColorPalette> createState() => _ColorPaletteState();
}

class _ColorPaletteState extends State<ColorPalette>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  // Polish color categories
  static const List<ColorCategory> colorCategories = [
    ColorCategory(
      name: '클래식',
      colors: [
        PolishColor(name: '클래식 레드', color: Color(0xFFDC143C), finish: '광택'),
        PolishColor(name: '핑크', color: Color(0xFFFFB6C1), finish: '광택'),
        PolishColor(name: '누드', color: Color(0xFFF5DEB3), finish: '광택'),
        PolishColor(name: '화이트', color: Color(0xFFFFFFFF), finish: '광택'),
        PolishColor(name: '클리어', color: Color(0x80FFFFFF), finish: '광택'),
      ],
    ),
    ColorCategory(
      name: '프렌치',
      colors: [
        PolishColor(name: '프렌치 화이트', color: Color(0xFFFFFFFF), finish: '광택'),
        PolishColor(name: '프렌치 핑크', color: Color(0xFFFFC0CB), finish: '광택'),
        PolishColor(name: '프렌치 누드', color: Color(0xFFF5F5DC), finish: '광택'),
        PolishColor(name: '프렌치 클리어', color: Color(0x60FFFFFF), finish: '광택'),
      ],
    ),
    ColorCategory(
      name: '볼드',
      colors: [
        PolishColor(name: '딥 레드', color: Color(0xFF8B0000), finish: '광택'),
        PolishColor(name: '핫 핑크', color: Color(0xFFFF1493), finish: '광택'),
        PolishColor(name: '퍼플', color: Color(0xFF800080), finish: '광택'),
        PolishColor(name: '블랙', color: Color(0xFF000000), finish: '광택'),
        PolishColor(name: '네이비', color: Color(0xFF000080), finish: '광택'),
      ],
    ),
    ColorCategory(
      name: '메탈릭',
      colors: [
        PolishColor(name: '골드', color: Color(0xFFFFD700), finish: '메탈릭'),
        PolishColor(name: '실버', color: Color(0xFFC0C0C0), finish: '메탈릭'),
        PolishColor(name: '로즈골드', color: Color(0xFFE8B4CB), finish: '메탈릭'),
        PolishColor(name: '브론즈', color: Color(0xFFCD7F32), finish: '메탈릭'),
      ],
    ),
  ];

  int _selectedCategoryIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    if (widget.isVisible) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(ColorPalette oldWidget) {
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
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -60 * -_slideAnimation.value),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Category tabs
                _buildCategoryTabs(),

                // Color palette
                Expanded(child: _buildColorGrid()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: colorCategories.length,
        itemBuilder: (context, index) {
          final category = colorCategories[index];
          final isSelected = index == _selectedCategoryIndex;

          return GestureDetector(
            onTap: () => _selectCategory(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey.withOpacity(0.3),
                ),
              ),
              child: Center(
                child: Text(
                  category.name,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.grey[600],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildColorGrid() {
    return PageView.builder(
      controller: _pageController,
      itemCount: colorCategories.length,
      onPageChanged: (index) {
        setState(() {
          _selectedCategoryIndex = index;
        });
      },
      itemBuilder: (context, categoryIndex) {
        final category = colorCategories[categoryIndex];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.0,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemCount: category.colors.length,
            itemBuilder: (context, colorIndex) {
              final polishColor = category.colors[colorIndex];
              return _buildColorItem(polishColor);
            },
          ),
        );
      },
    );
  }

  Widget _buildColorItem(PolishColor polishColor) {
    final isSelected = widget.selectedColor == polishColor.color;

    return GestureDetector(
      onTap: () => _selectColor(polishColor),
      onLongPress: () => _showColorDetails(polishColor),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: polishColor.color,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.withOpacity(0.4),
            width: isSelected ? 3 : 1.5,
          ),
          boxShadow: [
            if (polishColor.finish == 'Metallic')
              BoxShadow(
                color: polishColor.color.withOpacity(0.6),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            else
              BoxShadow(
                color: polishColor.color.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Stack(
          children: [
            // Metallic shine effect
            if (polishColor.finish == 'Metallic')
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.4),
                      Colors.transparent,
                      Colors.black.withOpacity(0.1),
                    ],
                  ),
                ),
              ),

            // Selection indicator
            if (isSelected)
              const Center(
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                  shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                ),
              ),

            // Transparent indicator for clear colors
            if (polishColor.color.opacity < 1.0)
              Container(
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: CustomPaint(
                  painter: CheckerboardPainter(),
                  size: Size.infinite,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _selectCategory(int index) {
    if (index != _selectedCategoryIndex) {
      setState(() {
        _selectedCategoryIndex = index;
      });

      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _selectColor(PolishColor polishColor) {
    widget.onColorSelected(polishColor.color);
    HapticFeedback.selectionClick();

    // Visual feedback
    _animateColorSelection();
  }

  void _animateColorSelection() {
    _animationController.reverse().then((_) {
      _animationController.forward();
    });
  }

  void _showColorDetails(PolishColor polishColor) {
    HapticFeedback.lightImpact();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(polishColor.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: polishColor.color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey),
                boxShadow: [
                  BoxShadow(
                    color: polishColor.color.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('마감: ${polishColor.finish}'),
            Text(
              'Hex: #${polishColor.color.value.toRadixString(16).toUpperCase()}',
            ),
            Text('투명도: ${(polishColor.color.opacity * 100).toInt()}%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _selectColor(polishColor);
            },
            child: const Text('선택'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}

// Data classes
class ColorCategory {
  final String name;
  final List<PolishColor> colors;

  const ColorCategory({required this.name, required this.colors});
}

class PolishColor {
  final String name;
  final Color color;
  final String finish;

  const PolishColor({
    required this.name,
    required this.color,
    required this.finish,
  });
}

// Custom painter for checkerboard pattern (for transparent colors)
class CheckerboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    const squareSize = 4.0;
    final cols = (size.width / squareSize).ceil();
    final rows = (size.height / squareSize).ceil();

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        paint.color = (row + col) % 2 == 0 ? Colors.white : Colors.grey[300]!;

        final rect = Rect.fromLTWH(
          col * squareSize,
          row * squareSize,
          squareSize,
          squareSize,
        );

        // Only paint within circle bounds
        if (_isRectInCircle(rect, size)) {
          canvas.drawRect(rect, paint);
        }
      }
    }
  }

  bool _isRectInCircle(Rect rect, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rectCenter = rect.center;

    return (rectCenter - center).distance <= radius;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
