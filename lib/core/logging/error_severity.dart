/// Severity levels for application runtime errors and diagnostics.
enum ErrorSeverity {
  debug,
  info,
  warning,
  error,
  fatal;

  /// Returns canonical string representation stored in database.
  String toDbValue() {
    switch (this) {
      case ErrorSeverity.debug:
        return 'debug';
      case ErrorSeverity.info:
        return 'info';
      case ErrorSeverity.warning:
        return 'warning';
      case ErrorSeverity.error:
        return 'error';
      case ErrorSeverity.fatal:
        return 'fatal';
    }
  }

  /// Parses severity level from string with fallback to [error].
  static ErrorSeverity fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'debug':
        return ErrorSeverity.debug;
      case 'info':
        return ErrorSeverity.info;
      case 'warning':
        return ErrorSeverity.warning;
      case 'fatal':
        return ErrorSeverity.fatal;
      case 'error':
      default:
        return ErrorSeverity.error;
    }
  }
}

