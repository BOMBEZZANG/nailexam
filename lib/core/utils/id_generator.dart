import 'dart:math';

class IdGenerator {
  static final Random _random = Random.secure();
  
  static String generateSessionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomValue = _random.nextInt(999999);
    return 'SESSION_${timestamp}_${randomValue.toString().padLeft(6, '0')}';
  }
  
  static String generateActionId() {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final randomValue = _random.nextInt(9999);
    return 'ACTION_${timestamp}_${randomValue.toString().padLeft(4, '0')}';
  }
  
  static String generateUniqueId() {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final randomBytes = List<int>.generate(8, (_) => _random.nextInt(256));
    final randomString = randomBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${timestamp}_$randomString';
  }
}