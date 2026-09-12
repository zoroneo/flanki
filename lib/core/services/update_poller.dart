import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'desktop_update_service.dart';
import '../notifiers/update_notifier.dart';

class UpdatePoller {
  static Timer? _timer;

  /// Start background update checking on supported platforms.
  static void start(
    WidgetRef ref, {
    Duration initialDelay = const Duration(seconds: 4),
    Duration interval = const Duration(hours: 4),
  }) {
    if (!DesktopUpdateService.isSupported) return;

    _timer?.cancel();
    _timer = Timer(initialDelay, () async {
      await ref.read(updateProvider.notifier).checkForUpdates(silent: true);

      _timer = Timer.periodic(interval, (_) async {
        await ref.read(updateProvider.notifier).checkForUpdates(silent: true);
      });
    });
  }

  /// Stop background polling.
  static void stop() {
    _timer?.cancel();
    _timer = null;
  }
}
