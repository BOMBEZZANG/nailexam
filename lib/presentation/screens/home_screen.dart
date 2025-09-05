import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../navigation/app_router.dart';
import '../../managers/ad_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _titleAnimationController;
  late AnimationController _buttonAnimationController;
  late AnimationController _sparkleAnimationController;

  late Animation<double> _titleScaleAnimation;
  late Animation<double> _titleOpacityAnimation;
  late Animation<double> _practiceButtonAnimation;
  late Animation<double> _examButtonAnimation;
  late Animation<double> _sparkleAnimation;

  @override
  void initState() {
    super.initState();

    // Title animation
    _titleAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _titleScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _titleAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _titleOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _titleAnimationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Button animations
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _practiceButtonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: const Interval(0.3, 0.7, curve: Curves.bounceOut),
      ),
    );

    _examButtonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: const Interval(0.5, 0.9, curve: Curves.bounceOut),
      ),
    );

    // Sparkle animation
    _sparkleAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _sparkleAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_sparkleAnimationController);

    // Start animations
    _titleAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _buttonAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _titleAnimationController.dispose();
    _buttonAnimationController.dispose();
    _sparkleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Force fullscreen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFF6B9D), // Pink
              const Color(0xFFFECA57), // Yellow
              const Color(0xFFF85F73), // Coral
              const Color(0xFFB83B5E), // Deep pink
            ],
            stops: const [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated background patterns
            _buildBackgroundPattern(),

            // Main content
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Game title
                      _buildTitle(),

                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.08,
                      ),

                      // Game buttons (responsive layout)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final screenHeight = MediaQuery.of(
                            context,
                          ).size.height;
                          final screenWidth = MediaQuery.of(context).size.width;

                          // Adjust button size based on available space
                          final buttonHeight = math.min(
                            screenHeight * 0.35, // 35% of screen height max
                            180.0, // Maximum height
                          );
                          final buttonWidth = math.min(
                            screenWidth *
                                0.18, // 18% of screen width each button
                            200.0, // Maximum width
                          );

                          // Always use horizontal layout for landscape
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Practice button
                              _buildGameButton(
                                label: '연습하기',
                                icon: Icons.school,
                                color1: const Color(0xFF667EEA),
                                color2: const Color(0xFF764BA2),
                                animation: _practiceButtonAnimation,
                                onTap: () => _startPractice(),
                                width: buttonWidth,
                                height: buttonHeight,
                              ),

                              SizedBox(
                                width: screenWidth * 0.05,
                              ), // Dynamic spacing
                              // Exam button
                              _buildGameButton(
                                label: '시험보기',
                                icon: Icons.assignment,
                                color1: const Color(0xFFF093FB),
                                color2: const Color(0xFFF5576C),
                                animation: _examButtonAnimation,
                                onTap: () => _startExam(),
                                width: buttonWidth,
                                height: buttonHeight,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Sparkle effects
            ..._buildSparkles(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundPattern() {
    return AnimatedBuilder(
      animation: _sparkleAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: BackgroundPatternPainter(animation: _sparkleAnimation.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildTitle() {
    return AnimatedBuilder(
      animation: _titleAnimationController,
      builder: (context, child) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        // Scale font sizes based on screen dimensions
        final titleFontSize = math.min(
          math.min(
            screenWidth * 0.045,
            screenHeight * 0.12,
          ), // Scale based on dimensions
          56.0, // Maximum size
        );
        final subtitleFontSize = math.min(
          math.min(
            screenWidth * 0.02,
            screenHeight * 0.06,
          ), // Scale based on dimensions
          24.0, // Maximum size
        );

        return Transform.scale(
          scale: _titleScaleAnimation.value,
          child: Opacity(
            opacity: _titleOpacityAnimation.value,
            child: Column(
              children: [
                // Main title
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.03,
                    vertical: screenHeight * 0.025,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Shadow text
                      Text(
                        '',
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w900,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 3
                            ..color = Colors.black.withOpacity(0.3),
                        ),
                      ),
                      // Main text
                      Text(
                        'NAIL MASTER',
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 3,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.02),

                // Subtitle
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.white, Colors.yellow],
                  ).createShader(bounds),
                  child: Text(
                    '미용사(네일) 실기 시험 시뮬레이터',
                    style: TextStyle(
                      fontSize: subtitleFontSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameButton({
    required String label,
    required IconData icon,
    required Color color1,
    required Color color2,
    required Animation<double> animation,
    required VoidCallback onTap,
    double width = 220,
    double height = 260,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value,
          child: GestureDetector(
            onTapDown: (_) => HapticFeedback.lightImpact(),
            onTap: onTap,
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color1, color2],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: color2.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon with glow effect (responsive size)
                      Container(
                        width: math.min(height * 0.3, width * 0.3),
                        height: math.min(height * 0.3, width * 0.3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Icon(
                          icon,
                          size: math.min(height * 0.18, width * 0.18),
                          color: Colors.white,
                        ),
                      ),

                      SizedBox(height: height * 0.06),

                      // Button label
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: math.min(height * 0.09, 20.0),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),

                      SizedBox(height: height * 0.03),

                      // Sub label
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.08,
                          vertical: height * 0.02,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          label == '연습하기' ? 'PRACTICE' : 'EXAM',
                          style: TextStyle(
                            fontSize: math.min(height * 0.05, 12.0),
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 2,
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
    );
  }

  List<Widget> _buildSparkles() {
    return List.generate(6, (index) {
      final random = math.Random(index);
      final left = random.nextDouble() * 0.9;
      final top = random.nextDouble() * 0.9;
      final delay = random.nextDouble() * 2;

      return Positioned(
        left: MediaQuery.of(context).size.width * left,
        top: MediaQuery.of(context).size.height * top,
        child: AnimatedBuilder(
          animation: _sparkleAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _sparkleAnimation.value + (index * math.pi / 3),
              child: Opacity(
                opacity: 0.6 + 0.4 * math.sin(_sparkleAnimation.value + delay),
                child: Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 20 + (index * 5),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  void _startPractice() {
    HapticFeedback.mediumImpact();
    AppRouter.navigateTo(
      context,
      AppRouter.exam,
      arguments: {'isPracticeMode': true},
    );
  }

  void _startExam() {
    HapticFeedback.mediumImpact();
    _showAdConfirmationDialog();
  }

  void _showAdConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 16,
          backgroundColor: Colors.white,
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF093FB).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.video_library,
                    size: 30,
                    color: Color(0xFFF093FB),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Title
                const Text(
                  '시험보기',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Message
                const Text(
                  '시험보기를 위해서 광고를 시청하겠습니까?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF4A5568),
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Buttons
                Row(
                  children: [
                    // No button
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                        ),
                        child: const Text(
                          '아니오',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF718096),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Yes button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _watchAdAndStartExam();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF093FB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          '네, 시청하기',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _watchAdAndStartExam() {
    if (AdManager.instance.isRewardedAdAvailable) {
      AdManager.instance.showRewardedAd(
        onAdShown: () {
          print('Rewarded ad shown');
        },
        onUserEarnedReward: () {
          print('User earned reward');
          _navigateToExam();
        },
        onAdDismissed: () {
          print('Rewarded ad dismissed');
          _navigateToExam();
        },
        onAdFailedToShow: () {
          print('Rewarded ad failed to show, proceeding to exam');
          _navigateToExam();
        },
      );
    } else {
      print('No rewarded ad available, proceeding to exam');
      _navigateToExam();
    }
  }

  void _navigateToExam() {
    AppRouter.navigateTo(
      context,
      AppRouter.exam,
      arguments: {'isPracticeMode': false},
    );
  }
}

// Custom painter for animated background
class BackgroundPatternPainter extends CustomPainter {
  final double animation;

  BackgroundPatternPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withOpacity(0.1);

    // Draw animated circles
    for (int i = 0; i < 5; i++) {
      final radius =
          (size.width * 0.1) + (i * 50) + (math.sin(animation + i) * 20);
      canvas.drawCircle(
        Offset(size.width * 0.2, size.height * 0.8),
        radius,
        paint,
      );
    }

    for (int i = 0; i < 5; i++) {
      final radius =
          (size.width * 0.1) + (i * 50) + (math.cos(animation + i) * 20);
      canvas.drawCircle(
        Offset(size.width * 0.8, size.height * 0.2),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(BackgroundPatternPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
