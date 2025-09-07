import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart';
import 'navigation/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Firebase Analytics 초기화 및 디버그 모드에서도 활성화
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  
  // 첫 번째 이벤트 로그 (앱 시작)
  await FirebaseAnalytics.instance.logEvent(
    name: 'app_start',
    parameters: {
      'platform': 'flutter',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    },
  );
  
  print('Firebase Analytics initialized successfully');
  
  // Enable both portrait and landscape orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  // 네이티브 스플래시 스크린 숨기기 (깜빡거림 방지)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  
  runApp(const NailExamApp());
}

class NailExamApp extends StatelessWidget {
  const NailExamApp({super.key});

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = 
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nail Exam Simulator',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // 애니메이션 지속시간 단축 (빠른 전환)
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          },
        ),
      ),
      // Firebase Analytics Observer 추가
      navigatorObservers: [observer],
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: AppRouter.splash,
      debugShowCheckedModeBanner: false,
      // iOS의 경우 back swipe gesture 비활성화 (깜빡거림 방지)
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            // 키보드 숨기기
            FocusScope.of(context).unfocus();
          },
          child: child,
        );
      },
    );
  }
}