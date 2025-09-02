import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/storage_keys.dart';
import '../core/errors/app_exceptions.dart';
import '../core/utils/logger.dart';
import '../data/models/exam_session.dart';

class LocalStorageManager {
  static final LocalStorageManager _instance = LocalStorageManager._internal();
  static LocalStorageManager get instance => _instance;
  
  LocalStorageManager._internal();
  
  SharedPreferences? _prefs;
  
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      Logger.i('LocalStorageManager initialized');
    } catch (e) {
      Logger.e('Failed to initialize LocalStorageManager', error: e);
      throw StorageException('Failed to initialize storage');
    }
  }
  
  void _ensureInitialized() {
    if (_prefs == null) {
      throw StorageException('LocalStorageManager not initialized. Call initialize() first.');
    }
  }
  
  Future<void> saveSession(ExamSession session) async {
    _ensureInitialized();
    
    try {
      final json = jsonEncode(session.toJson());
      await _prefs!.setString(StorageKeys.currentSession, json);
      
      final history = await getSessionHistory();
      history[session.sessionId] = session;
      await _saveSessionHistory(history);
      
      Logger.d('Session saved: ${session.sessionId}');
    } catch (e) {
      Logger.e('Failed to save session', error: e);
      throw StorageException('Failed to save session: ${e.toString()}');
    }
  }
  
  Future<ExamSession?> loadSession() async {
    _ensureInitialized();
    
    final json = _prefs!.getString(StorageKeys.currentSession);
    if (json == null) return null;
    
    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      final session = ExamSession.fromJson(data);
      Logger.d('Session loaded: ${session.sessionId}');
      return session;
    } catch (e) {
      Logger.e('Failed to load session', error: e);
      return null;
    }
  }
  
  Future<Map<String, ExamSession>> getSessionHistory() async {
    _ensureInitialized();
    
    final json = _prefs!.getString(StorageKeys.sessionHistory);
    if (json == null) return {};
    
    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      final history = <String, ExamSession>{};
      
      data.forEach((key, value) {
        try {
          history[key] = ExamSession.fromJson(value as Map<String, dynamic>);
        } catch (e) {
          Logger.w('Failed to parse session $key from history');
        }
      });
      
      return history;
    } catch (e) {
      Logger.e('Failed to load session history', error: e);
      return {};
    }
  }
  
  Future<void> _saveSessionHistory(Map<String, ExamSession> history) async {
    _ensureInitialized();
    
    try {
      final data = <String, dynamic>{};
      history.forEach((key, value) {
        data[key] = value.toJson();
      });
      
      final json = jsonEncode(data);
      await _prefs!.setString(StorageKeys.sessionHistory, json);
      Logger.d('Session history saved with ${history.length} sessions');
    } catch (e) {
      Logger.e('Failed to save session history', error: e);
      throw StorageException('Failed to save session history');
    }
  }
  
  Future<void> clearCurrentSession() async {
    _ensureInitialized();
    
    try {
      await _prefs!.remove(StorageKeys.currentSession);
      Logger.i('Current session cleared');
    } catch (e) {
      Logger.e('Failed to clear current session', error: e);
    }
  }
  
  Future<void> clearAll() async {
    _ensureInitialized();
    
    try {
      await _prefs!.clear();
      Logger.i('All storage cleared');
    } catch (e) {
      Logger.e('Failed to clear storage', error: e);
      throw StorageException('Failed to clear storage');
    }
  }
  
  Future<void> saveSetting(String key, dynamic value) async {
    _ensureInitialized();
    
    try {
      if (value is bool) {
        await _prefs!.setBool(key, value);
      } else if (value is int) {
        await _prefs!.setInt(key, value);
      } else if (value is double) {
        await _prefs!.setDouble(key, value);
      } else if (value is String) {
        await _prefs!.setString(key, value);
      } else if (value is List<String>) {
        await _prefs!.setStringList(key, value);
      } else {
        throw StorageException('Unsupported value type: ${value.runtimeType}');
      }
      Logger.d('Setting saved: $key = $value');
    } catch (e) {
      Logger.e('Failed to save setting: $key', error: e);
      throw StorageException('Failed to save setting');
    }
  }
  
  dynamic getSetting(String key, {dynamic defaultValue}) {
    _ensureInitialized();
    
    try {
      final value = _prefs!.get(key);
      return value ?? defaultValue;
    } catch (e) {
      Logger.e('Failed to get setting: $key', error: e);
      return defaultValue;
    }
  }
  
  bool getBoolSetting(String key, {bool defaultValue = false}) {
    return getSetting(key, defaultValue: defaultValue) as bool;
  }
  
  int getIntSetting(String key, {int defaultValue = 0}) {
    return getSetting(key, defaultValue: defaultValue) as int;
  }
  
  double getDoubleSetting(String key, {double defaultValue = 0.0}) {
    return getSetting(key, defaultValue: defaultValue) as double;
  }
  
  String getStringSetting(String key, {String defaultValue = ''}) {
    return getSetting(key, defaultValue: defaultValue) as String;
  }
  
  List<String> getStringListSetting(String key, {List<String>? defaultValue}) {
    return getSetting(key, defaultValue: defaultValue ?? []) as List<String>;
  }
  
  Future<void> updateHighScore(double score, bool isPracticeMode) async {
    if (!isPracticeMode) return;
    
    final currentHighScore = getDoubleSetting(
      StorageKeys.practiceHighScore,
      defaultValue: 0.0,
    );
    
    if (score > currentHighScore) {
      await saveSetting(StorageKeys.practiceHighScore, score);
      Logger.i('New high score: $score');
    }
  }
  
  Future<void> incrementSessionCount() async {
    final current = getIntSetting(
      StorageKeys.totalSessionsCompleted,
      defaultValue: 0,
    );
    await saveSetting(StorageKeys.totalSessionsCompleted, current + 1);
  }
}