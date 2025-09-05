import 'dart:async';
import 'package:flutter/material.dart';

enum FeedbackType { success, warning, error, info, technique, sequence, timer }

class FeedbackEvent {
  final FeedbackType type;
  final String message;
  final String? details;
  final Duration? duration;
  final Map<String, dynamic>? data;

  FeedbackEvent({
    required this.type,
    required this.message,
    this.details,
    this.duration,
    this.data,
  });
}

class FeedbackOverlay extends StatefulWidget {
  final Stream<FeedbackEvent> feedbackStream;

  const FeedbackOverlay({super.key, required this.feedbackStream});

  @override
  State<FeedbackOverlay> createState() => _FeedbackOverlayState();
}

class _FeedbackOverlayState extends State<FeedbackOverlay>
    with TickerProviderStateMixin {
  final List<FeedbackItem> _activeItems = [];
  late StreamSubscription<FeedbackEvent> _streamSubscription;

  @override
  void initState() {
    super.initState();
    _streamSubscription = widget.feedbackStream.listen(_handleFeedback);
  }

  void _handleFeedback(FeedbackEvent event) {
    final controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    final slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.elasticOut));

    final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    final scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.bounceOut));

    final item = FeedbackItem(
      event: event,
      controller: controller,
      slideAnimation: slideAnimation,
      fadeAnimation: fadeAnimation,
      scaleAnimation: scaleAnimation,
    );

    setState(() {
      _activeItems.add(item);
    });

    controller.forward().then((_) {
      final displayDuration = event.duration ?? _getDefaultDuration(event.type);

      Future.delayed(displayDuration, () {
        if (mounted) {
          controller.reverse().then((_) {
            setState(() {
              _activeItems.remove(item);
            });
            controller.dispose();
          });
        }
      });
    });
  }

  Duration _getDefaultDuration(FeedbackType type) {
    switch (type) {
      case FeedbackType.success:
        return const Duration(seconds: 2);
      case FeedbackType.error:
        return const Duration(seconds: 4);
      case FeedbackType.warning:
        return const Duration(seconds: 3);
      case FeedbackType.info:
        return const Duration(seconds: 2);
      case FeedbackType.technique:
        return const Duration(seconds: 3);
      case FeedbackType.sequence:
        return const Duration(seconds: 4);
      case FeedbackType.timer:
        return const Duration(seconds: 2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main feedback items (right side)
        ..._activeItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return AnimatedBuilder(
            animation: item.controller,
            builder: (context, child) {
              return Positioned(
                top: 100 + (index * 80.0),
                right: 16,
                child: SlideTransition(
                  position: item.slideAnimation,
                  child: FadeTransition(
                    opacity: item.fadeAnimation,
                    child: ScaleTransition(
                      scale: item.scaleAnimation,
                      child: _buildFeedbackWidget(item.event),
                    ),
                  ),
                ),
              );
            },
          );
        }),

        // Special overlay for technique feedback
        ..._activeItems
            .where(
              (item) =>
                  item.event.type == FeedbackType.technique ||
                  item.event.type == FeedbackType.sequence,
            )
            .map((item) => _buildTechniqueOverlay(item)),
      ],
    );
  }

  Widget _buildFeedbackWidget(FeedbackEvent event) {
    final config = _getFeedbackConfig(event.type);

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: config.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: config.borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: config.shadowColor,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: config.iconBackgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(config.icon, color: config.iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.message,
                    style: TextStyle(
                      color: config.textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  if (event.details != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      event.details!,
                      style: TextStyle(
                        color: config.textColor.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechniqueOverlay(FeedbackItem item) {
    return AnimatedBuilder(
      animation: item.controller,
      builder: (context, child) {
        return Positioned.fill(
          child: FadeTransition(
            opacity: item.fadeAnimation,
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Material(
                  elevation: 16,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    constraints: const BoxConstraints(
                      maxWidth: 320,
                      maxHeight: 200,
                    ),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.event.type == FeedbackType.technique
                              ? Icons.lightbulb
                              : Icons.list_alt,
                          size: 48,
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          item.event.message,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (item.event.details != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            item.event.details!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  FeedbackConfig _getFeedbackConfig(FeedbackType type) {
    switch (type) {
      case FeedbackType.success:
        return FeedbackConfig(
          icon: Icons.check_circle,
          backgroundColor: Colors.green.shade50,
          borderColor: Colors.green.shade200,
          iconColor: Colors.white,
          iconBackgroundColor: Colors.green,
          textColor: Colors.green.shade800,
          shadowColor: Colors.green.withOpacity(0.2),
        );

      case FeedbackType.error:
        return FeedbackConfig(
          icon: Icons.error,
          backgroundColor: Colors.red.shade50,
          borderColor: Colors.red.shade200,
          iconColor: Colors.white,
          iconBackgroundColor: Colors.red,
          textColor: Colors.red.shade800,
          shadowColor: Colors.red.withOpacity(0.2),
        );

      case FeedbackType.warning:
        return FeedbackConfig(
          icon: Icons.warning,
          backgroundColor: Colors.orange.shade50,
          borderColor: Colors.orange.shade200,
          iconColor: Colors.white,
          iconBackgroundColor: Colors.orange,
          textColor: Colors.orange.shade800,
          shadowColor: Colors.orange.withOpacity(0.2),
        );

      case FeedbackType.info:
        return FeedbackConfig(
          icon: Icons.info,
          backgroundColor: Colors.blue.shade50,
          borderColor: Colors.blue.shade200,
          iconColor: Colors.white,
          iconBackgroundColor: Colors.blue,
          textColor: Colors.blue.shade800,
          shadowColor: Colors.blue.withOpacity(0.2),
        );

      case FeedbackType.technique:
        return FeedbackConfig(
          icon: Icons.lightbulb,
          backgroundColor: Colors.amber.shade50,
          borderColor: Colors.amber.shade200,
          iconColor: Colors.white,
          iconBackgroundColor: Colors.amber,
          textColor: Colors.amber.shade800,
          shadowColor: Colors.amber.withOpacity(0.2),
        );

      case FeedbackType.sequence:
        return FeedbackConfig(
          icon: Icons.list_alt,
          backgroundColor: Colors.purple.shade50,
          borderColor: Colors.purple.shade200,
          iconColor: Colors.white,
          iconBackgroundColor: Colors.purple,
          textColor: Colors.purple.shade800,
          shadowColor: Colors.purple.withOpacity(0.2),
        );

      case FeedbackType.timer:
        return FeedbackConfig(
          icon: Icons.timer,
          backgroundColor: Colors.indigo.shade50,
          borderColor: Colors.indigo.shade200,
          iconColor: Colors.white,
          iconBackgroundColor: Colors.indigo,
          textColor: Colors.indigo.shade800,
          shadowColor: Colors.indigo.withOpacity(0.2),
        );
    }
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    for (final item in _activeItems) {
      item.controller.dispose();
    }
    super.dispose();
  }
}

class FeedbackItem {
  final FeedbackEvent event;
  final AnimationController controller;
  final Animation<Offset> slideAnimation;
  final Animation<double> fadeAnimation;
  final Animation<double> scaleAnimation;

  FeedbackItem({
    required this.event,
    required this.controller,
    required this.slideAnimation,
    required this.fadeAnimation,
    required this.scaleAnimation,
  });
}

class FeedbackConfig {
  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color textColor;
  final Color shadowColor;

  const FeedbackConfig({
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.textColor,
    required this.shadowColor,
  });
}

// Feedback stream controller for easy usage
class FeedbackController {
  final StreamController<FeedbackEvent> _controller =
      StreamController.broadcast();

  Stream<FeedbackEvent> get stream => _controller.stream;

  void showSuccess(String message, {String? details}) {
    _controller.add(
      FeedbackEvent(
        type: FeedbackType.success,
        message: message,
        details: details,
      ),
    );
  }

  void showError(String message, {String? details}) {
    _controller.add(
      FeedbackEvent(
        type: FeedbackType.error,
        message: message,
        details: details,
      ),
    );
  }

  void showWarning(String message, {String? details}) {
    _controller.add(
      FeedbackEvent(
        type: FeedbackType.warning,
        message: message,
        details: details,
      ),
    );
  }

  void showInfo(String message, {String? details}) {
    _controller.add(
      FeedbackEvent(
        type: FeedbackType.info,
        message: message,
        details: details,
      ),
    );
  }

  void showTechnique(String message, {String? details}) {
    _controller.add(
      FeedbackEvent(
        type: FeedbackType.technique,
        message: message,
        details: details,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void showSequence(String message, {String? details}) {
    _controller.add(
      FeedbackEvent(
        type: FeedbackType.sequence,
        message: message,
        details: details,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void showTimer(String message, {String? details}) {
    _controller.add(
      FeedbackEvent(
        type: FeedbackType.timer,
        message: message,
        details: details,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void dispose() {
    _controller.close();
  }
}
