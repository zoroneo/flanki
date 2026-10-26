import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'error_logger.dart';
import 'error_severity.dart';

/// Global Riverpod observer capturing state and async provider failures across all features.
final class RiverpodErrorObserver extends ProviderObserver {
  const RiverpodErrorObserver();

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    final provider = context.provider;
    final providerName = provider.name ?? provider.runtimeType.toString();
    ErrorLogger.instance.captureException(
      error,
      stackTrace: stackTrace,
      context: 'Riverpod: $providerName',
      severity: ErrorSeverity.error,
      extra: {'provider': providerName},
    );
  }
}
