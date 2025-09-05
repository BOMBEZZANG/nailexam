import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/utils/logger.dart';

class AssetManager {
  static final AssetManager _instance = AssetManager._internal();
  static AssetManager get instance => _instance;
  
  AssetManager._internal();
  
  final Map<String, Image> _imageCache = {};
  final Map<String, ui.Image> _uiImageCache = {};
  final Map<String, bool> _preloadStatus = {};
  
  // Asset paths
  static const Map<String, String> assetPaths = {
    // Hand assets
    'hand_base': 'assets/images/hands/hand_base.png',
    'hand_isometric': 'assets/images/hands/hand_isometric.png',
    'hand_shadow': 'assets/images/hands/hand_shadow.png',
    
    // Nail assets (template paths, actual will be indexed)
    'nail_clean': 'assets/images/nails/nail_clean_',
    'nail_cuticle': 'assets/images/nails/nail_cuticle_',
    'nail_polished': 'assets/images/nails/nail_polished_',
    
    // Tool assets
    'tool_nail_file': 'assets/images/tools/nail_file.png',
    'tool_buffer': 'assets/images/tools/buffer.png',
    'tool_cuticle_pusher': 'assets/images/tools/cuticle_pusher.png',
    'tool_polish_brush': 'assets/images/tools/polish_brush.png',
    'tool_nail_tips': 'assets/images/tools/nail_tips.png',
    'tool_cotton_pad': 'assets/images/tools/cotton_pad.png',
    'tool_cuticle_nipper': 'assets/images/tools/cuticle_nipper.png',
    
    // UI assets
    'work_surface': 'assets/images/ui/work_surface.png',
    'tool_tray_bg': 'assets/images/ui/tool_tray_bg.png',
    'grid_overlay': 'assets/images/ui/grid_overlay.png',
  };
  
  Future<void> preloadAssets(BuildContext context) async {
    Logger.i('Starting asset preloading...');
    
    try {
      // Preload main assets
      final mainAssets = [
        assetPaths['hand_isometric']!,
        assetPaths['work_surface']!,
        assetPaths['tool_tray_bg']!,
      ];
      
      for (final path in mainAssets) {
        await _preloadSingleAsset(context, path);
      }
      
      // Preload tool assets
      final toolAssets = assetPaths.entries
          .where((entry) => entry.key.startsWith('tool_'))
          .map((entry) => entry.value)
          .toList();
      
      for (final path in toolAssets) {
        await _preloadSingleAsset(context, path);
      }
      
      // Preload nail assets (10 fingers)
      for (int i = 1; i <= 10; i++) {
        final indexStr = i.toString().padLeft(2, '0');
        await _preloadSingleAsset(context, '${assetPaths['nail_clean']!}$indexStr.png');
        await _preloadSingleAsset(context, '${assetPaths['nail_cuticle']!}$indexStr.png');
        await _preloadSingleAsset(context, '${assetPaths['nail_polished']!}$indexStr.png');
      }
      
      Logger.i('Asset preloading completed');
    } catch (e) {
      Logger.e('Failed to preload assets', error: e);
    }
  }
  
  Future<void> _preloadSingleAsset(BuildContext context, String path) async {
    try {
      await precacheImage(AssetImage(path), context);
      _preloadStatus[path] = true;
    } catch (e) {
      Logger.w('Failed to preload asset: $path');
      _preloadStatus[path] = false;
    }
  }
  
  Image getImage(String path, {double? width, double? height}) {
    final cacheKey = '$path:${width?.toString() ?? ''}:${height?.toString() ?? ''}';
    
    if (!_imageCache.containsKey(cacheKey)) {
      _imageCache[cacheKey] = Image.asset(
        path,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          Logger.w('Failed to load image: $path');
          return _getPlaceholderWidget(width, height);
        },
      );
    }
    return _imageCache[cacheKey]!;
  }
  
  Future<ui.Image> getUiImage(String path) async {
    if (!_uiImageCache.containsKey(path)) {
      try {
        final data = await rootBundle.load(path);
        final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
        final frame = await codec.getNextFrame();
        _uiImageCache[path] = frame.image;
      } catch (e) {
        Logger.e('Failed to load UI image: $path', error: e);
        // Return a simple placeholder image
        _uiImageCache[path] = await _createPlaceholderUiImage();
      }
    }
    return _uiImageCache[path]!;
  }
  
  Widget getToolImage(String toolId, {double size = 32}) {
    // For now, always return placeholder until actual assets are added
    return _getToolPlaceholder(toolId, size);
  }
  
  Widget getNailImage(int fingerIndex, String state, {double? width, double? height}) {
    final indexStr = fingerIndex.toString().padLeft(2, '0');
    final basePath = assetPaths['nail_$state'];
    if (basePath != null) {
      final fullPath = '$basePath$indexStr.png';
      return getImage(fullPath, width: width, height: height);
    }
    return _getPlaceholderWidget(width, height);
  }
  
  Widget _getPlaceholderWidget(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        Icons.image_not_supported,
        size: (width != null && height != null) ? (width + height) / 4 : 24,
        color: Colors.grey[600],
      ),
    );
  }
  
  Widget _getToolPlaceholder(String toolId, double size) {
    // Map tool IDs to appropriate icons
    final iconMap = {
      'nail_file': Icons.straighten,
      'buffer': Icons.square_rounded,
      'cuticle_pusher': Icons.push_pin,
      'polish_brush': Icons.brush,
      'nail_tips': Icons.layers,
      'cotton_pad': Icons.circle,
      'cuticle_nipper': Icons.content_cut,
      'hand_sanitizer': Icons.local_hospital,
      'uv_lamp': Icons.lightbulb,
      'remover': Icons.invert_colors_off,
      'sanding_block': Icons.grid_on,
      'finger_bowl': Icons.local_drink,
      'cuticle_oil': Icons.colorize,
      'disinfectant_spray': Icons.air,
      'sterilized_gauze': Icons.healing,
    };
    
    final icon = iconMap[toolId] ?? Icons.build;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[400]!, width: 1),
      ),
      child: Icon(
        icon,
        color: Colors.grey[700],
        size: size * 0.6,
      ),
    );
  }
  
  Future<ui.Image> _createPlaceholderUiImage() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = Colors.grey;
    
    canvas.drawRect(const Rect.fromLTWH(0, 0, 100, 100), paint);
    
    final picture = recorder.endRecording();
    return await picture.toImage(100, 100);
  }
  
  bool isAssetPreloaded(String path) {
    return _preloadStatus[path] ?? false;
  }
  
  void clearCache() {
    _imageCache.clear();
    _uiImageCache.clear();
    Logger.i('Asset cache cleared');
  }
  
  void dispose() {
    clearCache();
    _preloadStatus.clear();
  }
}