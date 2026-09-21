import 'dart:convert';

import 'package:dio/dio.dart';

import '../../config/app_config.dart';
import '../../network/dio_client.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'anki_web_config.dart';

enum AuthErrorCode {
  emptyCredentials,
  invalidCredentials,
  rateLimited,
  invalidResponse,
  networkError,
  serverError,
  unknown,
}

class AnkiWebAuthResult {
  final bool success;
  final String? hostKey;
  final String? error;
  final AuthErrorCode? errorCode;

  const AnkiWebAuthResult({
    required this.success,
    this.hostKey,
    this.error,
    this.errorCode,
  });

  factory AnkiWebAuthResult.ok(String hostKey) {
    return AnkiWebAuthResult(success: true, hostKey: hostKey);
  }

  factory AnkiWebAuthResult.fail(String error, [AuthErrorCode? code]) {
    return AnkiWebAuthResult(success: false, error: error, errorCode: code);
  }
}

/// Service handling authentication against AnkiWeb to obtain a persistent session [hostKey].
class AnkiWebAuthService {
  final Dio _dio;
  final AnkiWebConfig _config;

  AnkiWebAuthService({Dio? dio, AnkiWebConfig? config})
    : _dio = dio ?? DioClient.defaultInstance,
      _config = config ?? const AnkiWebConfig();

  AppLocalizations get l10n => AppConfig.getL10n();

  Future<AnkiWebAuthResult> login({
    required String username,
    required String password,
  }) async {
    final trimmedUser = username.trim();
    final trimmedPass = password.trim();

    if (trimmedUser.isEmpty || trimmedPass.isEmpty) {
      return AnkiWebAuthResult.fail(
        'Username and password are required',
        AuthErrorCode.emptyCredentials,
      );
    }

    try {
      final response = await _dio.post(
        '${_config.syncHost}${AnkiWebConfig.endpointHostKey}',
        data: {'u': trimmedUser, 'p': trimmedPass},
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          responseType: ResponseType.plain,
          headers: {'User-Agent': _config.effectiveUserAgent},
          sendTimeout: _config.customAuthTimeout,
          receiveTimeout: _config.customAuthTimeout,
        ),
      );

      final body = response.data?.toString().trim() ?? '';
      if (response.statusCode == 200) {
        if (body.startsWith('{')) {
          try {
            final json = jsonDecode(body) as Map<String, dynamic>;
            final key = json['key'] as String?;
            if (key != null && key.isNotEmpty) {
              return AnkiWebAuthResult.ok(key);
            }
            final err = json['err'] as String? ?? 'Invalid server response';
            return AnkiWebAuthResult.fail(err, _mapErrorStringToCode(err));
          } catch (_) {
            return AnkiWebAuthResult.fail(
              'Failed to parse auth response',
              AuthErrorCode.invalidResponse,
            );
          }
        }

        if (body.isNotEmpty && !body.contains('error')) {
          return AnkiWebAuthResult.ok(body);
        }
      }

      if (response.statusCode == 403 ||
          body.toLowerCase().contains('invalid') ||
          body.toLowerCase().contains('bad auth')) {
        return AnkiWebAuthResult.fail(
          'Invalid credentials',
          AuthErrorCode.invalidCredentials,
        );
      }

      if (response.statusCode == 429) {
        return AnkiWebAuthResult.fail(
          'Too many attempts. Please try again later.',
          AuthErrorCode.rateLimited,
        );
      }

      return AnkiWebAuthResult.fail(
        'Authentication failed: HTTP ${response.statusCode}',
        AuthErrorCode.serverError,
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final status = e.response!.statusCode;
        if (status == 403 || status == 401) {
          return AnkiWebAuthResult.fail(
            'Invalid credentials',
            AuthErrorCode.invalidCredentials,
          );
        }
        if (status == 429) {
          return AnkiWebAuthResult.fail(
            'Too many attempts. Please try again later.',
            AuthErrorCode.rateLimited,
          );
        }
        return AnkiWebAuthResult.fail(
          'Server error ($status)',
          AuthErrorCode.serverError,
        );
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        return AnkiWebAuthResult.fail(
          'Network connection timeout. Check your internet connection.',
          AuthErrorCode.networkError,
        );
      }

      return AnkiWebAuthResult.fail(
        'Network error: ${e.message ?? 'Unknown error'}',
        AuthErrorCode.networkError,
      );
    } catch (e) {
      return AnkiWebAuthResult.fail(e.toString(), AuthErrorCode.unknown);
    }
  }

  AuthErrorCode _mapErrorStringToCode(String err) {
    final lower = err.toLowerCase();
    if (lower.contains('invalid') || lower.contains('auth')) {
      return AuthErrorCode.invalidCredentials;
    }
    if (lower.contains('rate') || lower.contains('limit')) {
      return AuthErrorCode.rateLimited;
    }
    return AuthErrorCode.serverError;
  }
}
