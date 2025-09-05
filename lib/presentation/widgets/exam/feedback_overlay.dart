import 'dart:async';
import 'package:flutter/material.dart';

class FeedbackOverlay extends StatefulWidget {
  final Stream<String> feedbackStream;

  const FeedbackOverlay({
    super.key,
    required this.feedbackStream,
  });

  @override
  State<FeedbackOverlay> createState() => _FeedbackOverlayState();
}

class _FeedbackOverlayState extends State<FeedbackOverlay>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  StreamSubscription<String>? _subscription;
  String _currentMessage = '';
  bool _isVisible = false;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
    ));

    _subscription = widget.feedbackStream.listen((message) {
      _showFeedback(message);
    });
  }

  void _showFeedback(String message) {
    _hideTimer?.cancel();
    
    setState(() {
      _currentMessage = message;
      _isVisible = true;
    });

    _animationController.forward().then((_) {
      // Auto-hide after 2.5 seconds (longer for guide messages)
      final duration = message.contains('문질러') || message.contains('꾹눌러') || message.contains('꾹 눌러') || message.contains('탭하세요') || message.contains('칠해주세요') || message.contains('탭해서')
          ? const Duration(milliseconds: 4000) 
          : const Duration(milliseconds: 2500);
      _hideTimer = Timer(duration, () {
        if (mounted && _isVisible) {
          _hideFeedback();
        }
      });
    });
  }

  void _hideFeedback() {
    _hideTimer?.cancel();
    _animationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isVisible = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _hideTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) {
      return const SizedBox.shrink();
    }

    final isCentered = _currentMessage.contains('문질러') || _currentMessage.contains('꾹눌러') || _currentMessage.contains('꾹 눌러') || _currentMessage.contains('탭하세요') || _currentMessage.contains('칠해주세요') || _currentMessage.contains('탭해서');
    
    return Positioned(
      top: isCentered ? null : MediaQuery.of(context).padding.top + 10,
      bottom: isCentered ? MediaQuery.of(context).size.height * 0.4 : null,
      left: 16,
      right: 16,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: GestureDetector(
                  onTap: _hideFeedback,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isCentered ? 32 : 20, 
                      vertical: isCentered ? 20 : 14,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isCentered ? [
                          Colors.orange.shade600,
                          Colors.orange.shade400,
                        ] : [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(isCentered ? 30 : 25),
                      boxShadow: [
                        BoxShadow(
                          color: (isCentered ? Colors.orange : Theme.of(context).primaryColor).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isCentered ? Icons.touch_app : Icons.check_circle,
                            color: Colors.white,
                            size: isCentered ? 24 : 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _currentMessage,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isCentered ? 18 : 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _hideFeedback,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white70,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}