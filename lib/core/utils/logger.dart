import 'package:flutter/foundation.dart';

class Logger {
  static const String _tag = 'NailExam';
  
  static void d(String message, {String? tag}) {
    if (kDebugMode) {
      print('${tag ?? _tag} [DEBUG]: $message');
    }
  }
  
  static void i(String message, {String? tag}) {
    if (kDebugMode) {
      print('${tag ?? _tag} [INFO]: $message');
    }
  }
  
  static void w(String message, {String? tag}) {
    if (kDebugMode) {
      print('${tag ?? _tag} [WARNING]: $message');
    }
  }
  
  static void e(String message, {Object? error, StackTrace? stackTrace, String? tag}) {
    if (kDebugMode) {
      print('${tag ?? _tag} [ERROR]: $message');
      if (error != null) {
        print('Error: $error');
      }
      if (stackTrace != null) {
        print('Stack trace: $stackTrace');
      }
    }
  }
}