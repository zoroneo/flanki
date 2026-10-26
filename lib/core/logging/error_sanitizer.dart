/// Utility to strip sensitive PII, authentication tokens, passwords, and user paths from logs.
class ErrorSanitizer {
  const ErrorSanitizer._();

  static const String redactedPlaceholder = '[REDACTED]';

  // Regular expressions for sensitive data patterns
  static final RegExp _bearerPattern = RegExp(
    r'(bearer\s+)[A-Za-z0-9\-._~+/]+=*',
    caseSensitive: false,
  );

  static final RegExp _jwtPattern = RegExp(
    r'eyJ[A-Za-z0-9\-_=]+\.eyJ[A-Za-z0-9\-_=]+\.[A-Za-z0-9\-_=]+',
  );

  static final RegExp _authHeaderPattern = RegExp(
    r'(authorization|anonKey|apikey|secret|password|hostkey|access_token|refresh_token)\s*[:=]\s*["\x27]?[^"\x27,\s&]+["\x27]?',
    caseSensitive: false,
  );

  static final RegExp _emailPattern = RegExp(
    r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b',
  );

  static final RegExp _macUserPathPattern = RegExp(
    r'(/Users/)[^/\s]+',
  );

  static final RegExp _winUserPathPattern = RegExp(
    r'([A-Za-z]:\\Users\\)[^\\]+',
  );

  /// Sanitizes a string message or stack trace, stripping credentials and user paths.
  static String sanitize(String input) {
    if (input.isEmpty) return input;

    var result = input;

    // 1. Redact JWT tokens
    result = result.replaceAll(_jwtPattern, '[REDACTED_JWT]');

    // 2. Redact Bearer headers
    result = result.replaceAllMapped(_bearerPattern, (m) => '${m.group(1)}[REDACTED_TOKEN]');

    // 3. Redact key-value secrets (e.g. password=..., apikey: ...)
    result = result.replaceAllMapped(_authHeaderPattern, (m) {
      final key = m.group(1);
      return '$key: [REDACTED]';
    });

    // 4. Mask email addresses
    result = result.replaceAllMapped(_emailPattern, (m) {
      final email = m.group(0)!;
      final parts = email.split('@');
      if (parts.length == 2 && parts[0].isNotEmpty) {
        final name = parts[0];
        final maskedName = name.length > 2
            ? '${name[0]}***${name[name.length - 1]}'
            : '***';
        return '$maskedName@${parts[1]}';
      }
      return '[REDACTED_EMAIL]';
    });

    // 5. Sanitize local user home paths for privacy
    result = result.replaceAllMapped(_macUserPathPattern, (m) => '${m.group(1)}[USER]');
    result = result.replaceAllMapped(_winUserPathPattern, (m) => '${m.group(1)}[USER]');

    return result;
  }

  /// Recursively sanitizes a JSON-like dynamic map or list.
  static dynamic sanitizeData(dynamic data) {
    if (data == null) return null;
    if (data is String) return sanitize(data);
    if (data is Map) {
      final sanitizedMap = <String, dynamic>{};
      for (final entry in data.entries) {
        final key = entry.key.toString();
        final lowerKey = key.toLowerCase();
        if (lowerKey.contains('password') ||
            lowerKey.contains('token') ||
            lowerKey.contains('secret') ||
            lowerKey.contains('key') ||
            lowerKey.contains('auth')) {
          sanitizedMap[key] = redactedPlaceholder;
        } else {
          sanitizedMap[key] = sanitizeData(entry.value);
        }
      }
      return sanitizedMap;
    }
    if (data is Iterable) {
      return data.map((item) => sanitizeData(item)).toList();
    }
    return data;
  }
}

