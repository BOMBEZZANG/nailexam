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
  bool _navigationCompleted = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    // Logo animation
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500), // 빠르게 조정
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
      duration: const Duration(milliseconds: 1000), // 빠르게 조정
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
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _loadingAnimationController.forward();
      }
    });
  }

  Future<void> _initializeApp() async {
    try {
      print('Starting app initialization...');
      
      // 최소 스플래시 시간 보장 (UI 완성도를 위해)
      final minimumSplashTime = Future.delayed(const Duration(seconds: 2));
      
      // AdMob 초기화를 백그라운드에서 시작 (블로킹하지 않음)
      final adInitialization = _initializeAdsInBackground();
      
      // 필수 초기화 작업들 (빠르게 완료되어야 함)
      await _performEssentialInitialization();
      
      // 최소 스플래시 시간 대기
      await minimumSplashTime;
      
      print('Essential initialization completed');
      
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
        
        // UI 업데이트 후 잠시 대기
        await Future.delayed(const Duration(milliseconds: 300));
        
        // 광고 초기화가 완료되었는지 확인하고 진행
        await _waitForAdInitializationAndNavigate(adInitialization);
      }
    } catch (e) {
      print('Error during app initialization: $e');
      if (mounted) {
        _navigateToHome();
      }
    }
  }

  Future<void> _performEssentialInitialization() async {
    // 여기에 필수적인 초기화 작업들을 추가
    // 예: 데이터베이스 초기화, 설정 로드 등
    
    // 시뮬레이션용 짧은 대기 (실제로는 필요한 초기화 작업으로 대체)
    await Future.delayed(const Duration(milliseconds: 500));
    print('Essential services initialized');
  }

  Future<void> _initializeAdsInBackground() async {
    try {
      print('Initializing AdMob in background...');
      await AdManager.instance.initialize();
      print('AdMob initialization completed');
    } catch (e) {
      print('AdMob initialization failed: $e');
    }
  }

  Future<void> _waitForAdInitializationAndNavigate(Future<void> adInitialization) async {
    // 광고 초기화를 최대 3초까지만 기다림
    try {
      await adInitialization.timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          print('AdMob initialization timed out, proceeding anyway');
        },
      );
    } catch (e) {
      print('AdMob initialization error: $e');
    }
    
    _showAdAndNavigate();
  }

  void _showAdAndNavigate() {
    if (_adShown || _navigationCompleted) return;
    
    print('Checking ad availability...');
    if (AdManager.instance.isAdAvailable) {
      print('Ad is available, attempting to show...');
      _adShown = true;
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
    } else {
      print('No ad available, navigating directly to home');
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    if (_navigationCompleted) return;
    _navigationCompleted = true;
    
    if (mounted) {
      print('Navigating to home screen...');
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
            children: [
              const Spacer(flex: 2),
              
              // Logo section
              AnimatedBuilder(
                animation: _logoAnimationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _logoOpacityAnimation.value,
                    child: Transform.scale(
                      scale: _logoScaleAnimation.value,
                      child: Column(
                        children: [
                          // Main logo/icon
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.brush,
                              size: 60,
                              color: Color(0xFFFF6B9D),
                            ),
                          ),
                          
                          const SizedBox(height: 30),
                          
                          // App title
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Text(
                              'NAIL EXAM',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFB83B5E),
                                letterSpacing: 2,
                                shadows: [
                                  Shadow(
                                    blurRadius: 3,
                                    color: Colors.black26,
                                  ),
                                ],
                              ),
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