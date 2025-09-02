import 'package:flutter_test/flutter_test.dart';
import 'package:nailexam/core/utils/id_generator.dart';

void main() {
  group('IdGenerator', () {
    test('should generate unique session IDs', () {
      final id1 = IdGenerator.generateSessionId();
      final id2 = IdGenerator.generateSessionId();

      expect(id1, isNotEmpty);
      expect(id2, isNotEmpty);
      expect(id1, isNot(equals(id2)));
      expect(id1, startsWith('SESSION_'));
      expect(id2, startsWith('SESSION_'));
    });

    test('should generate unique action IDs', () {
      final id1 = IdGenerator.generateActionId();
      final id2 = IdGenerator.generateActionId();

      expect(id1, isNotEmpty);
      expect(id2, isNotEmpty);
      expect(id1, isNot(equals(id2)));
      expect(id1, startsWith('ACTION_'));
      expect(id2, startsWith('ACTION_'));
    });

    test('should generate unique generic IDs', () {
      final id1 = IdGenerator.generateUniqueId();
      final id2 = IdGenerator.generateUniqueId();

      expect(id1, isNotEmpty);
      expect(id2, isNotEmpty);
      expect(id1, isNot(equals(id2)));
      expect(id1, contains('_'));
      expect(id2, contains('_'));
    });

    test('should generate session IDs with correct format', () {
      final id = IdGenerator.generateSessionId();
      final parts = id.split('_');

      expect(parts, hasLength(3));
      expect(parts[0], 'SESSION');
      expect(int.tryParse(parts[1]), isNotNull); // timestamp
      expect(parts[2], hasLength(6)); // 6-digit random number
    });

    test('should generate action IDs with correct format', () {
      final id = IdGenerator.generateActionId();
      final parts = id.split('_');

      expect(parts, hasLength(3));
      expect(parts[0], 'ACTION');
      expect(int.tryParse(parts[1]), isNotNull); // timestamp
      expect(parts[2], hasLength(4)); // 4-digit random number
    });

    test('should generate multiple unique IDs in sequence', () {
      final ids = <String>[];
      for (int i = 0; i < 100; i++) {
        ids.add(IdGenerator.generateUniqueId());
      }

      // Check that all IDs are unique
      final uniqueIds = ids.toSet();
      expect(uniqueIds.length, ids.length);
    });
  });
}