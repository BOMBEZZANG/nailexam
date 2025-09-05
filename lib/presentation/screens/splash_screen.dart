import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../managers/ad_manager.dart';
import '../../navigation/app_router.dart';
import '../widgets/common/loading_indicator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _loadingAnimationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _loadingOpacityAnimation;

  bool _isInitializing = true;
  bool _adShown = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    // Logo animation
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));

    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    ));

    // Loading animation
    _loadingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _loadingOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingAnimationController,
      curve: Curves.easeIn,
    ));

    // Start animations
    _logoAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        _loadingAnimationController.forward();
      }
    });
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize AdMob
      await AdManager.instance.initialize();
      
      // Wait for minimum splash time and ad loading (extended for retry attempts)
      await Future.delayed(const Duration(seconds: 15));

      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
        
        // Wait a bit more for UI to update
        await Future.delayed(const Duration(milliseconds: 500));
        _showAdAndNavigate();
      }
    } catch (e) {
      print('Error during app initialization: $e');
      if (mounted) {
        _navigateToHome();
      }
    }
  }

  void _showAdAndNavigate() {
    if (_adShown) return;
    
    print('Checking ad availability...');
    if (AdManager.instance.isAdAvailable) {
      print('Ad is available, attempting to show...');
      AdManager.instance.showAppOpenAd(
        onAdShown: () {
          print('App open ad shown');
        },
        onAdDismissed: () {
          print('App open ad dismissed');
          _navigateToHome();
        },
        onAdFailedToShow: () {
          print('App open ad failed to show');
          _navigateToHome();
        },
      );
      _adShown = true;
    } else {
      print('No ad available, navigating directly to home');
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    if (mounted) {
      AppRouter.navigateAndRemoveUntil(
        context,
        AppRouter.home,
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _loadingAnimationController.dispose();
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF6B9D), // Pink
              Color(0xFFFECA57), // Yellow
              Color(0xFFF85F73), // Coral
              Color(0xFFB83B5E), // Deep pink
            ],
            stops: [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              
              // Logo section
              AnimatedBuilder(
                animation: _logoAnimationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoScaleAnimation.value,
                    child: Opacity(
                      opacity: _logoOpacityAnimation.value,
                      child: Column(
                        children: [
                          // App icon placeholder
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.colorize,
                              size: 60,
                              color: Color(0xFFFF6B9D),
                            ),
                          ),
                          
                          const SizedBox(height: 30),
                          
                          // App title
                          const Text(
                            'NAIL MASTER',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 3,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 2),
                                  blurRadius: 10,
                                  color: Colors.black26,
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 10),
                          
                          // App subtitle
                          const Text(
                            '미용사(네일) 실기 시험 시뮬레이터',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              const Spacer(flex: 1),
              
              // Loading section
              AnimatedBuilder(
                animation: _loadingAnimationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _loadingOpacityAnimation.value,
                    child: Column(
                      children: [
                        if (_isInitializing) ...[
                          const LoadingIndicator(
                            color: Colors.white,
                            size: 30,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            '초기화 중...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ] else ...[
                          const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 30,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            '준비 완료!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
              
              const Spacer(flex: 2),
              
              // Footer
              const Padding(
                padding: EdgeInsets.only(bottom: 30),
                child: Text(
                  'Powered by Flutter',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}