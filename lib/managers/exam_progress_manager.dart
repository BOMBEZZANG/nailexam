import 'dart:convert';
import '../data/models/exam_progress.dart';
import '../managers/local_storage_manager.dart';
import '../core/utils/logger.dart';

class ExamProgressManager {
  static ExamProgressManager? _instance;
  static ExamProgressManager get instance {
    _instance ??= ExamProgressManager._internal();
    return _instance!;
  }

  ExamProgressManager._internal();

  final LocalStorageManager _storage = LocalStorageManager.instance;

  static const String _examProgressKey = 'exam_progress';
  static const String _practiceProgressKey = 'practice_progress';

  Future<void> saveProgress(ExamProgress progress) async {
    try {
      final key = progress.isPracticeMode
          ? _practiceProgressKey
          : _examProgressKey;
      final progressJson = jsonEncode(progress.toJson());
      await _storage.saveSetting(key, progressJson);
      Logger.i(
        'Progress saved successfully for ${progress.isPracticeMode ? "practice" : "exam"} mode',
      );
    } catch (e) {
      Logger.e('Failed to save progress', error: e);
    }
  }

  Future<ExamProgress?> loadProgress({required bool isPracticeMode}) async {
    try {
      final key = isPracticeMode ? _practiceProgressKey : _examProgressKey;
      final progressJson = _storage.getStringSetting(key);

      if (progressJson.isNotEmpty) {
        final progressMap = jsonDecode(progressJson) as Map<String, dynamic>;
        final progress = ExamProgress.fromJson(progressMap);
        Logger.i(
          'Progress loaded successfully for ${isPracticeMode ? "practice" : "exam"} mode',
        );
        return progress;
      }
    } catch (e) {
      Logger.e('Failed to load progress', error: e);
    }
    return null;
  }

  Future<void> clearProgress({required bool isPracticeMode}) async {
    try {
      final key = isPracticeMode ? _practiceProgressKey : _examProgressKey;
      await _storage.saveSetting(key, '');
      Logger.i(
        'Progress cleared for ${isPracticeMode ? "practice" : "exam"} mode',
      );
    } catch (e) {
      Logger.e('Failed to clear progress', error: e);
    }
  }

  Future<bool> hasProgress({required bool isPracticeMode}) async {
    try {
      final key = isPracticeMode ? _practiceProgressKey : _examProgressKey;
      final progressJson = _storage.getStringSetting(key);
      return progressJson.isNotEmpty;
    } catch (e) {
      Logger.e('Failed to check for progress', error: e);
      return false;
    }
  }

  Future<void> clearAllProgress() async {
    try {
      await _storage.saveSetting(_examProgressKey, '');
      await _storage.saveSetting(_practiceProgressKey, '');
      Logger.i('All progress cleared');
    } catch (e) {
      Logger.e('Failed to clear all progress', error: e);
    }
  }
}
