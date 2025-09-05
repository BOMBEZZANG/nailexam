class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, {this.code});

  @override
  String toString() =>
      'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

class SessionException extends AppException {
  SessionException(super.message, {super.code});
}

class StorageException extends AppException {
  StorageException(super.message, {super.code});
}

class ValidationException extends AppException {
  ValidationException(super.message, {super.code});
}

class TimerException extends AppException {
  TimerException(super.message, {super.code});
}
