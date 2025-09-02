import 'package:flutter/material.dart';
import '../data/models/exam_session.dart';
import '../presentation/screens/home_screen.dart';
import '../presentation/screens/exam_setup_screen.dart';
import '../presentation/screens/exam_screen.dart';
import '../presentation/screens/results_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String examSetup = '/exam-setup';
  static const String exam = '/exam';
  static const String results = '/results';
  static const String history = '/history';
  static const String settings = '/settings';
  
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );
        
      case examSetup:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ExamSetupScreen(
            isPracticeMode: args?['isPracticeMode'] ?? false,
          ),
        );
        
      case exam:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ExamScreen(
            isPracticeMode: args?['isPracticeMode'] ?? false,
            sessionId: args?['sessionId'],
          ),
        );
        
      case results:
        final session = settings.arguments as ExamSession;
        return MaterialPageRoute(
          builder: (_) => ResultsScreen(session: session),
        );
        
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(
              title: const Text('Error'),
            ),
            body: Center(
              child: Text('Route ${settings.name} not found'),
            ),
          ),
        );
    }
  }
  
  static Future<T?> navigateTo<T>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.pushNamed<T>(context, routeName, arguments: arguments);
  }
  
  static Future<T?> navigateAndReplace<T>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.pushReplacementNamed<T, T>(context, routeName, arguments: arguments);
  }
  
  static Future<T?> navigateAndRemoveUntil<T>(
    BuildContext context, 
    String routeName, 
    bool Function(Route<dynamic>) predicate, 
    {Object? arguments}
  ) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context, 
      routeName, 
      predicate, 
      arguments: arguments
    );
  }
  
  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.pop(context, result);
  }
  
  static bool canPop(BuildContext context) {
    return Navigator.canPop(context);
  }
}