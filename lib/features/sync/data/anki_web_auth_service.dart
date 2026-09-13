import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/dio_client.dart';
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

  factory AnkiWebAuthResult.ok(String hostKey) =>
      AnkiWebAuthResult(success: true, hostKey: hostKey);

  factory AnkiWebAuthResult.fail(String error, {AuthErrorCode? errorCode}) =>
      AnkiWebAuthResult(
        success: false,
        error: error,
        errorCode: errorCode ?? AuthErrorCode.unknown,
      );
}

class AnkiWebAuthService {
  final Dio _dio;
  final AnkiWebConfig _config;
  final AppLocalizations? _customL10n;

  AnkiWebAuthService({Dio? dio, AnkiWebConfig? config, AppLocalizations? l10n})
    : _dio = dio ?? DioClient.defaultInstance,
      _config = config ?? const AnkiWebConfig(),
      _customL10n = l10n;

  AppLocalizations get l10n => _customL10n ?? AppConfig.getL10n();

  /// Authenticate with AnkiWeb using username (email) and password.
  /// Returns [AnkiWebAuthResult] containing the session `hostKey`.
  Future<AnkiWebAuthResult> login({
    required String username,
    required String password,
  }) async {
    final cleanUsername = username.trim();
    if (cleanUsername.isEmpty || password.isEmpty) {
      return AnkiWebAuthResult.fail(
        l10n.authEmailPasswordEmpty,
        errorCode: AuthErrorCode.emptyCredentials,
      );
    }

    try {
      final formData = FormData.fromMap({
        'c': '0',
        'data': jsonEncode({'u': cleanUsername, 'p': password}),
      });

      final response = await _dio.post<String>(
        '${_config.syncHost}/sync/hostKey',
        data: formData,
        options: Options(
          headers: {'User-Agent': _config.effectiveUserAgent},
          responseType: ResponseType.plain,
          receiveTimeout: _config.effectiveAuthTimeout,
        ),
      );

      if (response.statusCode == 200) {
        final body = (response.data ?? '').trim();
        // AnkiWeb returns raw hostKey or JSON containing key
        if (body.isNotEmpty && !body.contains('error')) {
          String key = body;
          if (body.startsWith('{')) {
            try {
              final jsonMap = jsonDecode(body) as Map<String, dynamic>;
              key = (jsonMap['key'] ?? jsonMap['hostKey'] ?? body) as String;
            } catch (_) {}
          }
          return AnkiWebAuthResult.ok(key);
        } else {
          return AnkiWebAuthResult.fail(
            l10n.authServerResponseInvalid,
            errorCode: AuthErrorCode.invalidResponse,
          );
        }
      } else {
        return AnkiWebAuthResult.fail(
          l10n.syncServerError(
            response.statusCode ?? 500,
            response.statusMessage ?? 'Unknown',
          ),
          errorCode: AuthErrorCode.serverError,
        );
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 403 || statusCode == 401) {
        return AnkiWebAuthResult.fail(
          l10n.authInvalidCredentials,
          errorCode: AuthErrorCode.invalidCredentials,
        );
      } else if (statusCode == 429) {
        return AnkiWebAuthResult.fail(
          l10n.authTooManyAttempts,
          errorCode: AuthErrorCode.rateLimited,
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        return AnkiWebAuthResult.fail(
          e.message ?? 'Network error',
          errorCode: AuthErrorCode.networkError,
        );
      } else {
        return AnkiWebAuthResult.fail(
          l10n.syncServerError(
            statusCode ?? 500,
            e.response?.statusMessage ?? e.message ?? 'Unknown',
          ),
          errorCode: AuthErrorCode.serverError,
        );
      }
    } catch (e) {
      return AnkiWebAuthResult.fail(
        l10n.authUnknownError(e.toString()),
        errorCode: AuthErrorCode.unknown,
      );
    }
  }
}
