import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import 'desktop_update_service.dart';
import '../providers/update_notifier.dart';

class UpdatePoller {
  static Timer? _timer;

  /// Start background update checking on supported platforms.
  static void start(
    WidgetRef ref, {
    Duration initialDelay = AppConfig.desktopUpdateInitialDelay,
    Duration interval = AppConfig.desktopUpdatePollInterval,
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
