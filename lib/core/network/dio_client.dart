import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lightweight retry interceptor supporting exponential backoff for transient network errors.
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration initialDelay;
  final double backoffMultiplier;
  final List<int> retryStatusCodes;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.backoffMultiplier = 2.0,
    this.retryStatusCodes = const [502, 503, 504],
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

  static Dio createDefaultDio({
    Duration connectTimeout = const Duration(seconds: 15),
    Duration receiveTimeout = const Duration(seconds: 60),
    Duration sendTimeout = const Duration(seconds: 60),
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

    return dio;
  }

  static Dio? _defaultInstance;
  static Dio get defaultInstance => _defaultInstance ??= createDefaultDio();
}

/// Global Riverpod provider for the shared Dio HTTP client.
final dioProvider = Provider<Dio>((ref) {
  return DioClient.defaultInstance;
});
