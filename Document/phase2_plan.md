# Phase 2: UI Foundation & Asset Integration - Detailed Development Specification

## Phase Overview
Build upon Phase 1's core framework to implement the visual and interactive foundation of the nail exam simulation. This phase focuses on establishing the 2.5D isometric work area, integrating visual assets, implementing gesture detection, and creating the tool interaction system.

## Prerequisites
- Phase 1 completed and tested
- Flutter environment configured
- Asset creation tools ready (or placeholder assets available)
- Gesture testing on target devices

## Deliverables Checklist
- [ ] 2.5D Isometric view implementation
- [ ] Asset management system
- [ ] Gesture detection framework
- [ ] Tool tray with interactive tools
- [ ] Visual feedback system
- [ ] Hand/nail rendering system
- [ ] Polish color palette
- [ ] Basic animation framework
- [ ] Updated ExamScreen with working area

## Technical Requirements

### 1. Asset Management System

**Directory Structure**
```
assets/
├── images/
│   ├── hands/
│   │   ├── hand_base.png
│   │   ├── hand_isometric.png
│   │   └── hand_shadow.png
│   ├── nails/
│   │   ├── nail_clean_01-10.png
│   │   ├── nail_cuticle_01-10.png
│   │   └── nail_polished_01-10.png
│   ├── tools/
│   │   ├── nail_file.png
│   │   ├── buffer.png
│   │   ├── cuticle_pusher.png
│   │   ├── polish_brush.png
│   │   ├── nail_tips.png
│   │   └── cotton_pad.png
│   └── ui/
│       ├── work_surface.png
│       ├── tool_tray_bg.png
│       └── grid_overlay.png
└── animations/
    └── polish_flow.json
```

**Create AssetManager Class**
```dart
// lib/managers/asset_manager.dart
class AssetManager {
  static final AssetManager _instance = AssetManager._internal();
  static AssetManager get instance => _instance;
  
  final Map<String, Image> _imageCache = {};
  final Map<String, ui.Image> _uiImageCache = {};
  
  Future<void> preloadAssets(BuildContext context) async {
    // Preload all critical assets
    final assetPaths = [
      'assets/images/hands/hand_isometric.png',
      'assets/images/tools/nail_file.png',
      // ... all assets
    ];
    
    for (final path in assetPaths) {
      await precacheImage(AssetImage(path), context);
    }
  }
  
  Image getImage(String path) {
    if (!_imageCache.containsKey(path)) {
      _imageCache[path] = Image.asset(path);
    }
    return _imageCache[path]!;
  }
  
  Future<ui.Image> getUiImage(String path) async {
    if (!_uiImageCache.containsKey(path)) {
      final data = await rootBundle.load(path);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      _uiImageCache[path] = frame.image;
    }
    return _uiImageCache[path]!;
  }
}
```

### 2. Isometric View Implementation

**Create IsometricWorkArea Widget**
```dart
// lib/presentation/widgets/exam/isometric_work_area.dart
class IsometricWorkArea extends StatefulWidget {
  final Function(Offset) onDragUpdate;
  final Function(Tool) onToolApplied;
  final Function(GestureType, Offset) onGesture;
  final Tool? currentTool;
  final Color? currentPolishColor;
  
  const IsometricWorkArea({
    Key? key,
    required this.onDragUpdate,
    required this.onToolApplied,
    required this.onGesture,
    this.currentTool,
    this.currentPolishColor,
  }) : super(key: key);
  
  @override
  State<IsometricWorkArea> createState() => _IsometricWorkAreaState();
}

class _IsometricWorkAreaState extends State<IsometricWorkArea> 
    with TickerProviderStateMixin {
  
  // Isometric transformation matrix
  final Matrix4 isometricTransform = Matrix4.identity()
    ..rotateX(-0.5) // 30 degree rotation
    ..rotateZ(0.785398); // 45 degree rotation
  
  // Nail states for each finger
  final List<NailState> nailStates = List.generate(
    10, 
    (index) => NailState(fingerIndex: index),
  );
  
  // Gesture tracking
  Offset? _lastDragPosition;
  double _currentScale = 1.0;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      onTapDown: _handleTapDown,
      onLongPressStart: _handleLongPress,
      onScaleUpdate: _handleScale,
      child: CustomPaint(
        painter: IsometricPainter(
          nailStates: nailStates,
          isometricTransform: isometricTransform,
          scale: _currentScale,
        ),
        size: Size.infinite,
      ),
    );
  }
  
  void _handlePanStart(DragStartDetails details) {
    _lastDragPosition = details.localPosition;
    widget.onGesture(GestureType.dragStart, details.localPosition);
  }
  
  void _handlePanUpdate(DragUpdateDetails details) {
    if (_lastDragPosition != null) {
      final delta = details.localPosition - _lastDragPosition!;
      
      // Check if dragging over a nail
      final nailIndex = _getNailAtPosition(details.localPosition);
      if (nailIndex != null && widget.currentTool != null) {
        _applyToolToNail(nailIndex, widget.currentTool!);
      }
      
      widget.onDragUpdate(details.localPosition);
      _lastDragPosition = details.localPosition;
    }
  }
  
  int? _getNailAtPosition(Offset position) {
    // Convert screen position to isometric coordinates
    // Check collision with nail bounds
    // Return nail index or null
  }
  
  void _applyToolToNail(int nailIndex, Tool tool) {
    setState(() {
      nailStates[nailIndex].applyTool(tool);
    });
    widget.onToolApplied(tool);
  }
}
```

**Create IsometricPainter**
```dart
// lib/presentation/widgets/exam/isometric_painter.dart
class IsometricPainter extends CustomPainter {
  final List<NailState> nailStates;
  final Matrix4 isometricTransform;
  final double scale;
  
  IsometricPainter({
    required this.nailStates,
    required this.isometricTransform,
    required this.scale,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // Draw work surface
    _drawWorkSurface(canvas, size);
    
    // Draw hand base
    _drawHandBase(canvas, size);
    
    // Draw each nail
    for (int i = 0; i < nailStates.length; i++) {
      _drawNail(canvas, size, i, nailStates[i]);
    }
    
    // Draw overlays (guides, hints)
    _drawOverlays(canvas, size);
  }
  
  void _drawWorkSurface(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF5F5F5)
      ..style = PaintingStyle.fill;
    
    // Draw isometric grid
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    
    // Calculate isometric grid lines
    for (int i = 0; i <= 10; i++) {
      final x = size.width * (i / 10);
      final y = size.height * (i / 10);
      
      // Diagonal lines for isometric effect
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height * 0.5, size.height),
        gridPaint,
      );
      
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y - size.width * 0.3),
        gridPaint,
      );
    }
  }
  
  void _drawHandBase(Canvas canvas, Size size) {
    // Position hand in isometric view
    final handRect = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.6),
      width: size.width * 0.7,
      height: size.height * 0.5,
    );
    
    // Draw shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    
    canvas.save();
    canvas.transform(isometricTransform.storage);
    canvas.drawOval(handRect, shadowPaint);
    canvas.restore();
    
    // Draw hand outline
    final handPaint = Paint()
      ..color = const Color(0xFFFFE0BD) // Skin tone
      ..style = PaintingStyle.fill;
    
    canvas.save();
    canvas.transform(isometricTransform.storage);
    
    // Simplified hand shape
    final handPath = Path()
      ..moveTo(handRect.left, handRect.center.dy)
      ..quadraticBezierTo(
        handRect.left, handRect.top,
        handRect.center.dx, handRect.top,
      )
      ..quadraticBezierTo(
        handRect.right, handRect.top,
        handRect.right, handRect.center.dy,
      )
      ..lineTo(handRect.right, handRect.bottom)
      ..lineTo(handRect.left, handRect.bottom)
      ..close();
    
    canvas.drawPath(handPath, handPaint);
    canvas.restore();
  }
  
  void _drawNail(Canvas canvas, Size size, int index, NailState state) {
    // Calculate nail position based on finger index
    final nailPosition = _calculateNailPosition(size, index);
    
    // Draw nail base
    final nailPaint = Paint()
      ..color = state.hasPolish ? state.polishColor : const Color(0xFFFFF0E8)
      ..style = PaintingStyle.fill;
    
    final nailRect = Rect.fromCenter(
      center: nailPosition,
      width: 30 * scale,
      height: 40 * scale,
    );
    
    canvas.save();
    canvas.transform(isometricTransform.storage);
    
    // Draw nail shape
    final nailPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        nailRect,
        Radius.circular(8 * scale),
      ));
    
    canvas.drawPath(nailPath, nailPaint);
    
    // Draw cuticle if present
    if (state.hasCuticle) {
      final cuticlePaint = Paint()
        ..color = const Color(0xFFFFD0A0)
        ..style = PaintingStyle.fill;
      
      final cuticlePath = Path()
        ..addArc(
          Rect.fromCenter(
            center: nailRect.topCenter,
            width: nailRect.width * 0.8,
            height: 10 * scale,
          ),
          0,
          3.14159,
        );
      
      canvas.drawPath(cuticlePath, cuticlePaint);
    }
    
    // Draw shine effect
    if (state.hasPolish) {
      final shinePaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.4),
            Colors.transparent,
          ],
        ).createShader(nailRect)
        ..style = PaintingStyle.fill;
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            nailRect.left,
            nailRect.top,
            nailRect.width * 0.6,
            nailRect.height * 0.3,
          ),
          Radius.circular(4 * scale),
        ),
        shinePaint,
      );
    }
    
    canvas.restore();
  }
  
  Offset _calculateNailPosition(Size size, int index) {
    // Map finger index to position
    final fingerPositions = [
      // Left hand (if index < 5)
      Offset(size.width * 0.3, size.height * 0.4), // Thumb
      Offset(size.width * 0.35, size.height * 0.3), // Index
      Offset(size.width * 0.4, size.height * 0.25), // Middle
      Offset(size.width * 0.45, size.height * 0.3), // Ring
      Offset(size.width * 0.5, size.height * 0.35), // Pinky
      // Right hand (if index >= 5)
      Offset(size.width * 0.7, size.height * 0.4), // Thumb
      Offset(size.width * 0.65, size.height * 0.3), // Index
      Offset(size.width * 0.6, size.height * 0.25), // Middle
      Offset(size.width * 0.55, size.height * 0.3), // Ring
      Offset(size.width * 0.5, size.height * 0.35), // Pinky
    ];
    
    return index < fingerPositions.length 
        ? fingerPositions[index] 
        : Offset.zero;
  }
  
  @override
  bool shouldRepaint(IsometricPainter oldDelegate) {
    return oldDelegate.nailStates != nailStates ||
           oldDelegate.scale != scale;
  }
}
```

### 3. Nail State Management

**Create NailState Model**
```dart
// lib/data/models/nail_state.dart
class NailState {
  final int fingerIndex;
  bool hasCuticle;
  bool hasPolish;
  Color polishColor;
  double polishCoverage;
  bool needsFiling;
  bool hasExtension;
  ExtensionType? extensionType;
  
  NailState({
    required this.fingerIndex,
    this.hasCuticle = true,
    this.hasPolish = false,
    this.polishColor = Colors.transparent,
    this.polishCoverage = 0.0,
    this.needsFiling = true,
    this.hasExtension = false,
    this.extensionType,
  });
  
  void applyTool(Tool tool) {
    switch (tool.type) {
      case ToolType.cuticlePusher:
        hasCuticle = false;
        break;
      case ToolType.nailFile:
        needsFiling = false;
        break;
      case ToolType.polishBrush:
        hasPolish = true;
        polishCoverage = min(1.0, polishCoverage + 0.2);
        break;
      case ToolType.buffer:
        // Add shine effect
        break;
      default:
        break;
    }
  }
  
  void applyPolish(Color color, double amount) {
    polishColor = color;
    hasPolish = true;
    polishCoverage = min(1.0, polishCoverage + amount);
  }
  
  void reset() {
    hasCuticle = true;
    hasPolish = false;
    polishColor = Colors.transparent;
    polishCoverage = 0.0;
    needsFiling = true;
    hasExtension = false;
    extensionType = null;
  }
  
  Map<String, dynamic> toJson() => {
    'fingerIndex': fingerIndex,
    'hasCuticle': hasCuticle,
    'hasPolish': hasPolish,
    'polishColor': polishColor.value,
    'polishCoverage': polishCoverage,
    'needsFiling': needsFiling,
    'hasExtension': hasExtension,
    'extensionType': extensionType?.toString(),
  };
}

enum ExtensionType {
  silk,
  tipWithSilk,
  acrylic,
  gel,
}
```

### 4. Tool Tray Implementation

**Create ToolTray Widget**
```dart
// lib/presentation/widgets/exam/tool_tray.dart
class ToolTray extends StatefulWidget {
  final Function(Tool) onToolSelected;
  final Tool? selectedTool;
  
  const ToolTray({
    Key? key,
    required this.onToolSelected,
    this.selectedTool,
  }) : super(key: key);
  
  @override
  State<ToolTray> createState() => _ToolTrayState();
}

class _ToolTrayState extends State<ToolTray> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  
  final List<Tool> availableTools = Tool.getDefaultTools();
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 100 * _slideAnimation.value),
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: availableTools.length,
              itemBuilder: (context, index) {
                return _buildToolItem(availableTools[index]);
              },
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildToolItem(Tool tool) {
    final isSelected = widget.selectedTool?.id == tool.id;
    
    return GestureDetector(
      onTap: () {
        widget.onToolSelected(tool);
        HapticFeedback.lightImpact();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.transparent,
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).primaryColor 
                : Colors.grey.withOpacity(0.3),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              tool.iconPath,
              width: 32,
              height: 32,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  _getToolIcon(tool.type),
                  size: 32,
                  color: isSelected 
                      ? Theme.of(context).primaryColor 
                      : Colors.grey,
                );
              },
            ),
            const SizedBox(height: 4),
            Text(
              tool.name,
              style: TextStyle(
                fontSize: 10,
                color: isSelected 
                    ? Theme.of(context).primaryColor 
                    : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getToolIcon(ToolType type) {
    switch (type) {
      case ToolType.nailFile:
        return Icons.straighten;
      case ToolType.buffer:
        return Icons.square;
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
      default:
        return Icons.pan_tool;
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
```

### 5. Polish Color Palette

**Create ColorPalette Widget**
```dart
// lib/presentation/widgets/exam/color_palette.dart
class ColorPalette extends StatelessWidget {
  final Function(Color) onColorSelected;
  final Color? selectedColor;
  
  static const List<Color> polishColors = [
    Color(0xFFFF0000), // Classic Red
    Color(0xFFFF69B4), // Hot Pink
    Color(0xFFFFC0CB), // Pink
    Color(0xFFFFFFFF), // White (French)
    Color(0xFFF5DEB3), // Nude
    Color(0xFF800020), // Burgundy
    Color(0xFF000000), // Black
    Color(0xFFFF1493), // Deep Pink
    Color(0xFFDDA0DD), // Plum
    Color(0xFF87CEEB), // Sky Blue
  ];
  
  const ColorPalette({
    Key? key,
    required this.onColorSelected,
    this.selectedColor,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: polishColors.length,
        itemBuilder: (context, index) {
          final color = polishColors[index];
          final isSelected = selectedColor == color;
          
          return GestureDetector(
            onTap: () => onColorSelected(color),
            child: Container(
              width: 44,
              height: 44,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                border: Border.all(
                  color: isSelected ? Colors.black : Colors.grey,
                  width: isSelected ? 3 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
```

### 6. Gesture Detection System

**Create GestureController**
```dart
// lib/controllers/gesture_controller.dart
enum GestureType {
  tap,
  drag,
  dragStart,
  dragEnd,
  longPress,
  pinch,
  swipe,
}

class GestureController {
  final Function(GestureType, Offset, {dynamic data}) onGesture;
  
  // Gesture recognition parameters
  static const double minSwipeDistance = 50.0;
  static const double minDragDistance = 10.0;
  static const Duration longPressDuration = Duration(milliseconds: 500);
  
  Offset? _startPosition;
  DateTime? _startTime;
  
  GestureController({required this.onGesture});
  
  void processTap(Offset position) {
    onGesture(GestureType.tap, position);
    GameManager.instance.logAction('tap', data: {
      'position': {'x': position.dx, 'y': position.dy},
    });
  }
  
  void processDragStart(Offset position) {
    _startPosition = position;
    _startTime = DateTime.now();
    onGesture(GestureType.dragStart, position);
  }
  
  void processDragUpdate(Offset position, Offset delta) {
    if (_startPosition != null) {
      final distance = (position - _startPosition!).distance;
      
      if (distance > minDragDistance) {
        onGesture(GestureType.drag, position, data: delta);
        
        GameManager.instance.logAction('drag', data: {
          'position': {'x': position.dx, 'y': position.dy},
          'delta': {'dx': delta.dx, 'dy': delta.dy},
        });
      }
    }
  }
  
  void processDragEnd(Offset position) {
    if (_startPosition != null && _startTime != null) {
      final distance = (position - _startPosition!).distance;
      final duration = DateTime.now().difference(_startTime!);
      
      if (distance > minSwipeDistance && 
          duration < const Duration(milliseconds: 300)) {
        // Detected as swipe
        final direction = _calculateSwipeDirection(
          _startPosition!, 
          position,
        );
        onGesture(GestureType.swipe, position, data: direction);
      } else {
        onGesture(GestureType.dragEnd, position);
      }
    }
    
    _startPosition = null;
    _startTime = null;
  }
  
  SwipeDirection _calculateSwipeDirection(Offset start, Offset end) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    
    if (dx.abs() > dy.abs()) {
      return dx > 0 ? SwipeDirection.right : SwipeDirection.left;
    } else {
      return dy > 0 ? SwipeDirection.down : SwipeDirection.up;
    }
  }
}

enum SwipeDirection { up, down, left, right }
```

### 7. Updated ExamScreen Integration

**Update exam_screen.dart**
```dart
// Add to _ExamScreenState class

Tool? _selectedTool;
Color _selectedPolishColor = Colors.red;
final GestureController _gestureController = GestureController(
  onGesture: _handleGesture,
);

Widget _buildWorkArea() {
  return Column(
    children: [
      // Color palette (shown for polish periods)
      if (_shouldShowColorPalette())
        ColorPalette(
          selectedColor: _selectedPolishColor,
          onColorSelected: (color) {
            setState(() {
              _selectedPolishColor = color;
            });
          },
        ),
      
      // Main work area
      Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
            child: IsometricWorkArea(
              currentTool: _selectedTool,
              currentPolishColor: _selectedPolishColor,
              onDragUpdate: (position) {
                _gestureController.processDragUpdate(
                  position, 
                  position - _lastPosition,
                );
                _lastPosition = position;
              },
              onToolApplied: (tool) {
                _presenter.logUserAction(
                  'tool_applied',
                  data: {'tool': tool.id},
                );
              },
              onGesture: (type, position) {
                _handleGesture(type, position);
              },
            ),
          ),
        ),
      ),
      
      // Tool tray
      ToolTray(
        selectedTool: _selectedTool,
        onToolSelected: (tool) {
          setState(() {
            _selectedTool = tool;
          });
          HapticFeedback.selectionClick();
        },
      ),
    ],
  );
}

void _handleGesture(GestureType type, Offset position, {dynamic data}) {
  switch (type) {
    case GestureType.tap:
      _handleTap(position);
      break;
    case GestureType.drag:
      _handleDrag(position, data as Offset);
      break;
    case GestureType.swipe:
      _handleSwipe(data as SwipeDirection);
      break;
    case GestureType.longPress:
      _handleLongPress(position);
      break;
    default:
      break;
  }
}

bool _shouldShowColorPalette() {
  // Show for periods 1-3 (polish application)
  return _currentPeriodInfo.contains('Polish') || 
         _currentPeriodInfo.contains('Art');
}
```

### 8. Animation System

**Create AnimationManager**
```dart
// lib/managers/animation_manager.dart
class AnimationManager {
  static final AnimationManager _instance = AnimationManager._internal();
  static AnimationManager get instance => _instance;
  
  final Map<String, AnimationController> _controllers = {};
  
  AnimationController createController({
    required TickerProvider vsync,
    required Duration duration,
    String? id,
  }) {
    final controller = AnimationController(
      vsync: vsync,
      duration: duration,
    );
    
    if (id != null) {
      _controllers[id] = controller;
    }
    
    return controller;
  }
  
  Animation<double> createFadeAnimation(AnimationController controller) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeIn,
    ));
  }
  
  Animation<Offset> createSlideAnimation(
    AnimationController controller,
    Offset begin,
    Offset end,
  ) {
    return Tween<Offset>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCubic,
    ));
  }
  
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
  }
}
```

### 9. Visual Feedback System

**Create FeedbackOverlay**
```dart
// lib/presentation/widgets/exam/feedback_overlay.dart
class FeedbackOverlay extends StatefulWidget {
  final Stream<FeedbackEvent> feedbackStream;
  
  const FeedbackOverlay({
    Key? key,
    required this.feedbackStream,
  }) : super(key: key);
  
  @override
  State<FeedbackOverlay> createState() => _FeedbackOverlayState();
}

class _FeedbackOverlayState extends State<FeedbackOverlay> 
    with TickerProviderStateMixin {
  
  final List<FeedbackItem> _activeItems = [];
  
  @override
  void initState() {
    super.initState();
    widget.feedbackStream.listen(_handleFeedback);
  }
  
  void _handleFeedback(FeedbackEvent event) {
    final controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    final item = FeedbackItem(
      event: event,
      controller: controller,
      animation: Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutBack,
      )),
    );
    
    setState(() {
      _activeItems.add(item);
    });
    
    controller.forward().then((_) {
      Future.delayed(const Duration(seconds: 1), () {
        controller.reverse().then((_) {
          setState(() {
            _activeItems.remove(item);
          });
          controller.dispose();
        });
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _activeItems.map((item) {
        return AnimatedBuilder(
          animation: item.animation,
          builder: (context, child) {
            return Positioned(
              top: 50 + (_activeItems.indexOf(item) * 60.0),
              right: 20,
              child: Transform.scale(
                scale: item.animation.value,
                child: Opacity(
                  opacity: item.animation.value,
                  child: _buildFeedbackWidget(item.event),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
  
  Widget _buildFeedbackWidget(FeedbackEvent event) {
    IconData icon;
    Color color;
    
    switch (event.type) {
      case FeedbackType.success:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case FeedbackType.warning:
        icon = Icons.warning;
        color = Colors.orange;
        break;
      case FeedbackType.error:
        icon = Icons.error;
        color = Colors.red;
        break;
      case FeedbackType.info:
        icon = Icons.info;
        color = Colors.blue;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            event.message,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class FeedbackEvent {
  final FeedbackType type;
  final String message;
  
  FeedbackEvent({required this.type, required this.message});
}

enum FeedbackType { success, warning, error, info }

class FeedbackItem {
  final FeedbackEvent event;
  final AnimationController controller;
  final Animation<double> animation;
  
  FeedbackItem({
    required this.event,
    required this.controller,
    required this.animation,
  });
}
```

## Testing Requirements

### Integration Tests
```dart
// test/integration/isometric_view_test.dart
testWidgets('Isometric view renders correctly', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: IsometricWorkArea(
          onDragUpdate: (_) {},
          onToolApplied: (_) {},
          onGesture: (_, __) {},
        ),
      ),
    ),
  );
  
  expect(find.byType(IsometricWorkArea), findsOneWidget);
  
  // Test gesture detection
  await tester.dragFrom(
    const Offset(100, 100),
    const Offset(200, 200),
  );
  
  await tester.pump();
});

// test/widgets/tool_tray_test.dart
testWidgets('Tool selection works correctly', (tester) async {
  Tool? selectedTool;
  
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ToolTray(
          onToolSelected: (tool) {
            selectedTool = tool;
          },
        ),
      ),
    ),
  );
  
  // Tap first tool
  await tester.tap(find.byType(GestureDetector).first);
  await tester.pump();
  
  expect(selectedTool, isNotNull);
  expect(selectedTool!.type, equals(ToolType.nailFile));
});
```

## Performance Optimization

### Asset Loading
- Implement lazy loading for non-critical assets
- Use image caching with appropriate cache size limits
- Compress images to optimal sizes (max 2x device resolution)

### Rendering
- Use RepaintBoundary for static elements
- Implement dirty region tracking for CustomPainter
- Limit animation frame rate to 30fps for battery efficiency

### Memory Management
- Dispose controllers and streams properly
- Clear image cache on screen disposal
- Implement asset pooling for frequently used images

## Deliverable Verification

### Phase 2 Completion Criteria
1. **Isometric View** ✓
   - 2.5D perspective rendering
   - Hand and nail visualization
   - Smooth transformations

2. **Asset System** ✓
   - Efficient loading and caching
   - Fallback for missing assets
   - Memory optimization

3. **Gesture Detection** ✓
   - All gesture types recognized
   - Accurate position mapping
   - Responsive feedback

4. **Tool System** ✓
   - Tool selection and application
   - Visual feedback on use
   - State persistence

5. **Polish System** ✓
   - Color selection
   - Application visualization
   - Coverage tracking

6. **Animation Framework** ✓
   - Smooth transitions
   - Visual feedback
   - Performance optimized

## Notes for Development Team

### Asset Requirements
- Create placeholder assets if final designs unavailable
- Use consistent 2x resolution for all tool icons (64x64px)
- Nail sprites should be 60x80px each
- Hand base image at 800x600px

### Code Standards
- All CustomPainters must implement shouldRepaint efficiently
- Dispose all AnimationControllers in widget disposal
- Use const constructors where possible
- Implement error boundaries for asset loading failures

### Next Phase Preview (Phase 3)
Phase 3 will implement Period 1 (Hand Polish Application) with:
- Polish application mechanics
- Technique validation (full color, French, gradient)
- Scoring algorithms
- Period completion flow

---

*Upon completion of Phase 2, the app will have a fully functional visual interface ready for implementing specific exam period mechanics. The isometric view, tool system, and gesture detection provide the foundation for all exam techniques.*