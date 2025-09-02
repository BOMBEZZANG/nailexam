import 'package:flutter_test/flutter_test.dart';
import 'package:nailexam/core/constants/exam_constants.dart';
import 'package:nailexam/data/models/exam_session.dart';
import 'package:nailexam/data/models/period_data.dart';

void main() {
  group('ExamSession', () {
    test('should create with required fields', () {
      final session = ExamSession(
        sessionId: 'test_session',
        startTime: DateTime.now(),
      );

      expect(session.sessionId, 'test_session');
      expect(session.currentPeriod, 1);
      expect(session.periodResults, isEmpty);
      expect(session.isPracticeMode, isFalse);
      expect(session.status, ExamStatus.notStarted);
    });

    test('should calculate total score correctly', () {
      final session = ExamSession(
        sessionId: 'test_session',
        startTime: DateTime.now(),
      );

      // Add some period results
      session.periodResults[1] = PeriodData(
        periodNumber: 1,
        assignedTechnique: 'test',
        startTime: DateTime.now(),
        scoreBreakdown: {'sequence': 90, 'timing': 80, 'hygiene': 85, 'technique': 95},
      );
      
      session.periodResults[2] = PeriodData(
        periodNumber: 2,
        assignedTechnique: 'test',
        startTime: DateTime.now(),
        scoreBreakdown: {'sequence': 80, 'timing': 90, 'hygiene': 75, 'technique': 85},
      );

      final expectedScore = (
        (90 * 0.4 + 80 * 0.2 + 85 * 0.2 + 95 * 0.2) +
        (80 * 0.4 + 90 * 0.2 + 75 * 0.2 + 85 * 0.2)
      ) / 2;

      expect(session.totalScore, closeTo(expectedScore, 0.01));
    });

    test('should return 0 for total score when no periods', () {
      final session = ExamSession(
        sessionId: 'test_session',
        startTime: DateTime.now(),
      );

      expect(session.totalScore, 0.0);
    });

    test('should calculate completed periods correctly', () {
      final session = ExamSession(
        sessionId: 'test_session',
        startTime: DateTime.now(),
      );

      expect(session.completedPeriods, 0);

      // Add incomplete period
      session.periodResults[1] = PeriodData(
        periodNumber: 1,
        assignedTechnique: 'test',
        startTime: DateTime.now(),
      );

      expect(session.completedPeriods, 0);

      // Complete the period
      session.periodResults[1]!.endTime = DateTime.now();
      expect(session.completedPeriods, 1);
    });

    test('should calculate progress percentage correctly', () {
      final session = ExamSession(
        sessionId: 'test_session',
        startTime: DateTime.now(),
      );

      expect(session.progressPercentage, 0.0);

      // Complete 2 periods out of 5
      for (int i = 1; i <= 2; i++) {
        session.periodResults[i] = PeriodData(
          periodNumber: i,
          assignedTechnique: 'test',
          startTime: DateTime.now(),
          endTime: DateTime.now(),
        );
      }

      expect(session.progressPercentage, 2 / ExamConstants.totalPeriods);
    });

    test('should determine completion status correctly', () {
      final session = ExamSession(
        sessionId: 'test_session',
        startTime: DateTime.now(),
      );

      expect(session.isComplete, isFalse);

      // Add all periods
      for (int i = 1; i <= ExamConstants.totalPeriods; i++) {
        session.periodResults[i] = PeriodData(
          periodNumber: i,
          assignedTechnique: 'test',
          startTime: DateTime.now(),
        );
      }

      expect(session.isComplete, isTrue);
    });

    test('should start and complete periods correctly', () {
      final session = ExamSession(
        sessionId: 'test_session',
        startTime: DateTime.now(),
      );

      session.startPeriod(1, 'full_color');

      expect(session.currentPeriod, 1);
      expect(session.periodResults[1], isNotNull);
      expect(session.periodResults[1]!.assignedTechnique, 'full_color');

      final scores = {'sequence': 90.0, 'timing': 85.0, 'hygiene': 95.0, 'technique': 88.0};
      session.completePeriod(1, scores);

      expect(session.periodResults[1]!.isComplete, isTrue);
      expect(session.periodResults[1]!.scoreBreakdown, equals(scores));
    });

    test('should serialize to and from JSON', () {
      final originalSession = ExamSession(
        sessionId: 'test_session',
        startTime: DateTime(2023, 1, 1, 12, 0, 0),
        currentPeriod: 2,
        isPracticeMode: true,
        status: ExamStatus.inProgress,
      );

      originalSession.startPeriod(1, 'french');
      originalSession.completePeriod(1, {'sequence': 90.0, 'timing': 85.0, 'hygiene': 95.0, 'technique': 88.0});

      final json = originalSession.toJson();
      final deserializedSession = ExamSession.fromJson(json);

      expect(deserializedSession.sessionId, originalSession.sessionId);
      expect(deserializedSession.startTime, originalSession.startTime);
      expect(deserializedSession.currentPeriod, originalSession.currentPeriod);
      expect(deserializedSession.isPracticeMode, originalSession.isPracticeMode);
      expect(deserializedSession.status, originalSession.status);
      expect(deserializedSession.periodResults.length, originalSession.periodResults.length);
    });
  });
}