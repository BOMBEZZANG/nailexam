import '../models/exam_session.dart';
import '../../managers/local_storage_manager.dart';

class LocalStorageRepository {
  final LocalStorageManager _storageManager = LocalStorageManager.instance;
  
  Future<void> saveSession(ExamSession session) async {
    await _storageManager.saveSession(session);
  }
  
  Future<ExamSession?> loadSession() async {
    return await _storageManager.loadSession();
  }
  
  Future<Map<String, ExamSession>> getSessionHistory() async {
    return await _storageManager.getSessionHistory();
  }
  
  Future<void> clearCurrentSession() async {
    await _storageManager.clearCurrentSession();
  }
  
  Future<void> clearAll() async {
    await _storageManager.clearAll();
  }
}