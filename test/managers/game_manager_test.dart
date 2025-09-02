import 'package:flutter_test/flutter_test.dart';
import 'package:nailexam/core/constants/exam_constants.dart';
import 'package:nailexam/core/errors/app_exceptions.dart';
import 'package:nailexam/data/models/exam_session.dart';
import 'package:nailexam/managers/game_manager.dart';

void main() {
  group('GameManager', () {
    late GameManager gameManager;

    setUp(() {
      gameManager = GameManager.instance;
      gameManager.reset();
    });

    tearDown(() {
      gameManager.reset();
    });

    test('should be a singleton', () {
      final instance1 = GameManager.instance;
      final instance2 = GameManager.instance;
      expect(instance1, same(instance2));
    });

    test('should not have active session initially', () {
      expect(gameManager.hasActiveSession, isFalse);
      expect(gameManager.currentSession, isNull);
    });

    test('should create new session', () {
      final session = gameManager.startNewSession();
      
      expect(session, isNotNull);
      expect(session.sessionId, isNotEmpty);
      expect(session.status, ExamStatus.inProgress);
      expect(session.isPracticeMode, isFalse);
      expect(gameManager.hasActiveSession, isTrue);
    });

    test('should create practice session', () {
      final session = gameManager.startNewSession(isPractice: true);
      
      expect(session.isPracticeMode, isTrue);
    });

    test('should throw error when starting new session while one is active', () {
      gameManager.startNewSession();
      
      expect(
        () => gameManager.startNewSession(),
        throwsA(isA<SessionException>()),
      );
    });

    test('should select random technique for valid period', () {
      final technique = gameManager.getRandomTechnique(1);
      
      expect(
        ExamConstants.periodTechniques[1]!.contains(technique),
        isTrue,
      );
    });

    test('should throw error for invalid period', () {
      expect(
        () => gameManager.getRandomTechnique(99),
        throwsA(isA<ValidationException>()),
      );
    });

    test('should start period', () {
      final session = gameManager.startNewSession();
      gameManager.startPeriod(1);
      
      final period = session.periodResults[1];
      expect(period, isNotNull);
      expect(period!.periodNumber, 1);
      expect(period.assignedTechnique, isNotEmpty);
      expect(session.currentPeriod, 1);
    });

    test('should throw error when starting period without session', () {
      expect(
        () => gameManager.startPeriod(1),
        throwsA(isA<SessionException>()),
      );
    });

    test('should end period with scores', () {
      final session = gameManager.startNewSession();
      gameManager.startPeriod(1);
      
      final scores = {
        'sequence': 85.0,
        'timing': 90.0,
        'hygiene': 95.0,
        'technique': 88.0,
      };
      
      gameManager.endPeriod(1, scores);
      
      final period = session.periodResults[1]!;
      expect(period.isComplete, isTrue);
      expect(period.scoreBreakdown, equals(scores));
    });

    test('should pause and resume session', () {
      final session = gameManager.startNewSession();
      
      gameManager.pauseSession();
      expect(session.status, ExamStatus.paused);
      
      gameManager.resumeSession();
      expect(session.status, ExamStatus.inProgress);
    });

    test('should abandon session', () {
      gameManager.startNewSession();
      
      gameManager.abandonSession();
      expect(gameManager.hasActiveSession, isFalse);
      expect(gameManager.currentSession, isNull);
    });

    test('should log actions', () {
      final session = gameManager.startNewSession();
      gameManager.startPeriod(1);
      
      gameManager.logAction('test_action', data: {'value': 123});
      
      final period = session.periodResults[1]!;
      expect(period.actions, hasLength(1));
      expect(period.actions.first.actionType, 'test_action');
      expect(period.actions.first.data['value'], 123);
    });
  });
}