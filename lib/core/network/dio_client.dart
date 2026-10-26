import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logging/breadcrumb_tracker.dart';
import '../logging/error_logger.dart';
import '../logging/error_sanitizer.dart';
import '../logging/error_severity.dart';

/// Lightweight retry interceptor supporting exponential backoff for transient network errors.
class RetryInterceptor extends Interceptor {
  static const int defaultMaxRetries = 3;
  static const Duration defaultInitialDelay = Duration(seconds: 1);
  static const double defaultBackoffMultiplier = 2.0;
  static const List<int> defaultRetryStatusCodes = [502, 503, 504];

  final Dio dio;
  final int maxRetries;
  final Duration initialDelay;
  final double backoffMultiplier;
  final List<int> retryStatusCodes;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = defaultMaxRetries,
    this.initialDelay = defaultInitialDelay,
    this.backoffMultiplier = defaultBackoffMultiplier,
    this.retryStatusCodes = defaultRetryStatusCodes,
  });

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Never retry if request was intentionally cancelled by user
    if (err.type == DioExceptionType.cancel) {
      return handler.next(err);
    }

    // Do not retry if request options explicitly disabled retry
    if (err.requestOptions.extra['no_retry'] == true) {
      return handler.next(err);
    }

    final extra = err.requestOptions.extra;
    final int retryCount = (extra['retry_count'] as int?) ?? 0;

    if (_shouldRetry(err) && retryCount < maxRetries) {
      extra['retry_count'] = retryCount + 1;
      final multiplier = retryCount == 0
          ? 1.0
          : (backoffMultiplier * retryCount);
      final delay = initialDelay * multiplier;
      await Future<void>.delayed(delay);

      try {
        final response = await dio.fetch(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        if (e is DioException) {
          return handler.next(e);
        }
        return handler.reject(err);
      }
    }

    return handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      return true;
    }
    final status = err.response?.statusCode;
    if (status != null && retryStatusCodes.contains(status)) {
      return true;
    }
    return false;
  }
}

/// Factory and singleton helper for Dio instances across the application.
class DioClient {
  const DioClient._();

  static const Duration defaultConnectTimeout = Duration(seconds: 15);
  static const Duration defaultReceiveTimeout = Duration(seconds: 60);
  static const Duration defaultSendTimeout = Duration(seconds: 60);

  static Dio createDefaultDio({
    Duration connectTimeout = defaultConnectTimeout,
    Duration receiveTimeout = defaultReceiveTimeout,
    Duration sendTimeout = defaultSendTimeout,
    bool enableRetry = true,
  }) {
    final dio = Dio(
      BaseOptions(
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
      ),
    );

    if (enableRetry) {
      dio.interceptors.add(RetryInterceptor(dio: dio));
    }
    dio.interceptors.add(DioLoggingInterceptor());

    return dio;
  }

  static Dio? _defaultInstance;
  static Dio get defaultInstance => _defaultInstance ??= createDefaultDio();
}

/// Interceptor tracking HTTP requests as breadcrumbs and capturing server errors.
class DioLoggingInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final method = response.requestOptions.method;
    final path = ErrorSanitizer.sanitize(response.requestOptions.path);
    BreadcrumbTracker.instance.addNetwork(
      method,
      path,
      statusCode: response.statusCode,
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final method = err.requestOptions.method;
    final path = ErrorSanitizer.sanitize(err.requestOptions.path);
    final statusCode = err.response?.statusCode;

    BreadcrumbTracker.instance.addNetwork(
      method,
      path,
      statusCode: statusCode,
      error: err.message,
    );

    // If server 5xx error or connection error, capture diagnostic warning
    if (statusCode != null && statusCode >= 500) {
      ErrorLogger.instance.captureException(
        err,
        context: 'DioHTTP $statusCode: $method $path',
        severity: ErrorSeverity.warning,
        extra: {
          'method': method,
          'path': path,
          'status_code': statusCode,
        },
      );
    }

    handler.next(err);
  }
}

/// Global Riverpod provider for the shared Dio HTTP client.
final dioProvider = Provider<Dio>((ref) {
  return DioClient.defaultInstance;
});
