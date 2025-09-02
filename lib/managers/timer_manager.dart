import 'dart:async';
import '../core/constants/exam_constants.dart';
import '../core/utils/logger.dart';

class TimerManager {
  static final TimerManager _instance = TimerManager._internal();
  static TimerManager get instance => _instance;
  
  TimerManager._internal();
  
  Timer? _examTimer;
  Timer? _periodTimer;
  final StreamController<Duration> _examTimeController = StreamController.broadcast();
  final StreamController<Duration> _periodTimeController = StreamController.broadcast();
  final StreamController<TimeWarning> _warningController = StreamController.broadcast();
  
  Stream<Duration> get examTimeStream => _examTimeController.stream;
  Stream<Duration> get periodTimeStream => _periodTimeController.stream;
  Stream<TimeWarning> get warningStream => _warningController.stream;
  
  Duration _examElapsed = Duration.zero;
  Duration _periodElapsed = Duration.zero;
  bool _isPaused = false;
  
  Duration get examElapsed => _examElapsed;
  Duration get periodElapsed => _periodElapsed;
  bool get isPaused => _isPaused;
  bool get isRunning => _examTimer != null && !_isPaused;
  
  void startExamTimer() {
    _examTimer?.cancel();
    _examElapsed = Duration.zero;
    _isPaused = false;
    
    Logger.i('Starting exam timer');
    
    _examTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        _examElapsed += const Duration(seconds: 1);
        _examTimeController.add(_examElapsed);
        
        _checkExamWarnings();
        
        if (_examElapsed >= ExamConstants.totalExamDuration) {
          Logger.w('Exam time limit reached');
          _warningController.add(TimeWarning(
            type: WarningType.examTimeout,
            remaining: Duration.zero,
          ));
          stopAll();
        }
      }
    });
  }
  
  void startPeriodTimer() {
    _periodTimer?.cancel();
    _periodElapsed = Duration.zero;
    
    Logger.i('Starting period timer');
    
    _periodTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        _periodElapsed += const Duration(seconds: 1);
        _periodTimeController.add(_periodElapsed);
        
        _checkPeriodWarnings();
        
        if (_periodElapsed >= ExamConstants.periodDuration) {
          Logger.w('Period time limit reached');
          _warningController.add(TimeWarning(
            type: WarningType.periodTimeout,
            remaining: Duration.zero,
          ));
          stopPeriodTimer();
        }
      }
    });
  }
  
  void _checkExamWarnings() {
    final remaining = ExamConstants.totalExamDuration - _examElapsed;
    
    if (remaining.inSeconds == 30 * 60) {
      _notifyWarning(WarningType.exam30Min, remaining);
    } else if (remaining.inSeconds == 10 * 60) {
      _notifyWarning(WarningType.exam10Min, remaining);
    } else if (remaining.inSeconds == 5 * 60) {
      _notifyWarning(WarningType.exam5Min, remaining);
    } else if (remaining.inSeconds == 60) {
      _notifyWarning(WarningType.exam1Min, remaining);
    }
  }
  
  void _checkPeriodWarnings() {
    final remaining = ExamConstants.periodDuration - _periodElapsed;
    
    if (remaining.inSeconds == 5 * 60) {
      _notifyWarning(WarningType.period5Min, remaining);
    } else if (remaining.inSeconds == 60) {
      _notifyWarning(WarningType.period1Min, remaining);
    }
  }
  
  void _notifyWarning(WarningType type, Duration remaining) {
    Logger.w('Time warning: $type - ${remaining.inMinutes} minutes remaining');
    _warningController.add(TimeWarning(
      type: type,
      remaining: remaining,
    ));
  }
  
  void pause() {
    if (!_isPaused && (_examTimer != null || _periodTimer != null)) {
      _isPaused = true;
      Logger.i('Timer paused');
    }
  }
  
  void resume() {
    if (_isPaused) {
      _isPaused = false;
      Logger.i('Timer resumed');
    }
  }
  
  void stopPeriodTimer() {
    _periodTimer?.cancel();
    _periodTimer = null;
    _periodElapsed = Duration.zero;
    Logger.i('Period timer stopped');
  }
  
  void stopAll() {
    _examTimer?.cancel();
    _periodTimer?.cancel();
    _examTimer = null;
    _periodTimer = null;
    _examElapsed = Duration.zero;
    _periodElapsed = Duration.zero;
    _isPaused = false;
    Logger.i('All timers stopped');
  }
  
  void reset() {
    stopAll();
    Logger.i('TimerManager reset');
  }
  
  void dispose() {
    stopAll();
    _examTimeController.close();
    _periodTimeController.close();
    _warningController.close();
    Logger.i('TimerManager disposed');
  }
  
  String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
             '${minutes.toString().padLeft(2, '0')}:'
             '${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:'
             '${seconds.toString().padLeft(2, '0')}';
    }
  }
}

enum WarningType {
  exam30Min,
  exam10Min,
  exam5Min,
  exam1Min,
  examTimeout,
  period5Min,
  period1Min,
  periodTimeout,
}

class TimeWarning {
  final WarningType type;
  final Duration remaining;
  
  TimeWarning({
    required this.type,
    required this.remaining,
  });
  
  String get message {
    switch (type) {
      case WarningType.exam30Min:
        return '30 minutes remaining in exam';
      case WarningType.exam10Min:
        return '10 minutes remaining in exam';
      case WarningType.exam5Min:
        return '5 minutes remaining in exam';
      case WarningType.exam1Min:
        return '1 minute remaining in exam';
      case WarningType.examTimeout:
        return 'Exam time has expired';
      case WarningType.period5Min:
        return '5 minutes remaining in this period';
      case WarningType.period1Min:
        return '1 minute remaining in this period';
      case WarningType.periodTimeout:
        return 'Period time has expired';
    }
  }
}