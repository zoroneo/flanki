import 'dart:async';
import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../features/decks/providers/deck_notifier.dart';
import '../../features/settings/data/update_poller.dart';
import '../../features/settings/models/update_info.dart';
import '../../features/settings/providers/settings_notifier.dart';
import '../../features/settings/providers/update_notifier.dart';
import '../../features/settings/ui/widgets/update_dialog.dart';
import '../../features/stats/providers/stats_notifier.dart';
import '../../l10n/generated/app_localizations.dart';
import '../config/app_config.dart';
import '../localization/locale_notifier.dart';
import '../services/desktop_window_service.dart';
import '../services/notification_service.dart';
import 'update_toasts.dart';

/// Top-level coordinator managing app lifecycle events, desktop tray menu sync,
/// background notification reminders, and auto-update toast notifications.
class AppLifecycleManager extends ConsumerStatefulWidget {
  final Widget child;

  const AppLifecycleManager({super.key, required this.child});

  @override
  ConsumerState<AppLifecycleManager> createState() =>
      _AppLifecycleManagerState();
}

class _AppLifecycleManagerState extends ConsumerState<AppLifecycleManager>
    with WidgetsBindingObserver {
  ToastOverlay? _activeUpdateToast;
  Timer? _permissionTimer;

  void _dismissToast() {
    _activeUpdateToast?.close();
    _activeUpdateToast = null;
  }

  void _onUpdateDialogDismissed() {
    if (!mounted) return;
    final state = ref.read(updateProvider);
    if (state.status == UpdateStatus.downloading && state.updateInfo != null) {
      _showBackgroundDownloadToast(state.updateInfo!);
    }
  }

  void _showBackgroundDownloadToast(UpdateInfo info) {
    if (_activeUpdateToast != null) return;
    _activeUpdateToast = showToast(
      context: context,
      showDuration: const Duration(hours: 1),
      builder: (context, overlay) {
        return BackgroundDownloadToast(info: info, onDismiss: _dismissToast);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    UpdateDialog.onDismissActiveToast = _dismissToast;
    UpdateDialog.onDialogDismissed = _onUpdateDialogDismissed;
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      UpdatePoller.start(ref);
      if (Platform.environment.containsKey('FLUTTER_TEST')) {
        await NotificationService.instance.requestPermissions();
        _syncNotifications();
      } else {
        _permissionTimer = Timer(const Duration(milliseconds: 500), () async {
          if (!mounted) return;
          await NotificationService.instance.requestPermissions();
          _syncNotifications();
        });
      }
      if (DesktopWindowService.isDesktop && mounted) {
        final l10n = AppLocalizations.of(context);
        final currentLocale = ref.read(localeNotifierProvider);
        DesktopWindowService.instance.updateTrayMenu(
          openLabel: l10n?.trayOpenFlanki,
          studyLabel: l10n?.trayStudyNow,
          exitLabel: l10n?.trayExit,
          localeCode: currentLocale?.languageCode,
        );
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncNotifications();
    }
  }

  void _syncNotifications() {
    final currentLocale = ref.read(localeNotifierProvider);
    NotificationService.instance.updateLocale(currentLocale?.languageCode);

    final settings = ref.read(studySettingsProvider);
    final stats = ref.read(statsNotifierProvider);
    final decks = ref.read(deckListProvider);
    final totalDue = decks.fold<int>(0, (sum, deck) => sum + deck.dueCount);
    final studiedToday = stats.reviewedToday > 0;

    if (!settings.reminderEnabled) {
      NotificationService.instance.cancelAll();
      NotificationService.instance.stopDesktopScheduler();
      return;
    }

    NotificationService.instance.scheduleDailyReminder(
      hour: settings.reminderHour,
      minute: settings.reminderMinute,
      dueCardsCount: totalDue,
    );

    if (settings.streakSaverEnabled) {
      if (studiedToday) {
        NotificationService.instance.onStudyCompletedToday();
      } else {
        NotificationService.instance.scheduleStreakSaver(
          streakDays: stats.streakDays,
        );
      }
    }

    if (DesktopWindowService.isDesktop) {
      NotificationService.instance.startDesktopScheduler(
        isReminderEnabled: () =>
            ref.read(studySettingsProvider).reminderEnabled,
        getReminderHour: () => ref.read(studySettingsProvider).reminderHour,
        getReminderMinute: () => ref.read(studySettingsProvider).reminderMinute,
        isStreakSaverEnabled: () =>
            ref.read(studySettingsProvider).streakSaverEnabled,
        getStreakDays: () => ref.read(statsNotifierProvider).streakDays,
        getDueCardsCount: () {
          final decks = ref.read(deckListProvider);
          return decks.fold<int>(0, (sum, deck) => sum + deck.dueCount);
        },
        hasStudiedToday: () =>
            ref.read(statsNotifierProvider).reviewedToday > 0,
      );
    }
  }

  @override
  void dispose() {
    _permissionTimer?.cancel();
    if (UpdateDialog.onDismissActiveToast == _dismissToast) {
      UpdateDialog.onDismissActiveToast = null;
    }
    if (UpdateDialog.onDialogDismissed == _onUpdateDialogDismissed) {
      UpdateDialog.onDialogDismissed = null;
    }
    _dismissToast();
    NotificationService.instance.stopDesktopScheduler();
    WidgetsBinding.instance.removeObserver(this);
    UpdatePoller.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<StudySettings>(studySettingsProvider, (previous, current) {
      _syncNotifications();
    });
    ref.listen<Locale?>(localeNotifierProvider, (_, nextLocale) {
      NotificationService.instance.updateLocale(nextLocale?.languageCode);
      _syncNotifications();
      if (DesktopWindowService.isDesktop) {
        final l10n = AppLocalizations.of(context);
        DesktopWindowService.instance.updateTrayMenu(
          openLabel: l10n?.trayOpenFlanki,
          studyLabel: l10n?.trayStudyNow,
          exitLabel: l10n?.trayExit,
          localeCode: nextLocale?.languageCode,
        );
      }
    });
    ref.listen<UpdateState>(updateProvider, (previous, current) {
      // 1. New update available
      if (current.status == UpdateStatus.available &&
          previous?.status != UpdateStatus.available &&
          current.updateInfo != null) {
        if (UpdateDialog.isShowing || !current.isBackgroundCheck) {
          _dismissToast();
          return;
        }
        final info = current.updateInfo!;
        _dismissToast();
        _activeUpdateToast = showToast(
          context: context,
          showDuration: AppConfig.toastLongDuration,
          builder: (context, overlay) {
            return UpdateAvailableToast(
              info: info,
              onDismiss: _dismissToast,
              onDownloadInBackground: () {
                _dismissToast();
                ref.read(updateProvider.notifier).downloadUpdate();
              },
              onOpenUpdateDialog: () {
                _dismissToast();
                UpdateDialog.show(context, info);
              },
            );
          },
        );
      }

      // 2. Actively downloading in background
      if (current.status == UpdateStatus.downloading &&
          current.updateInfo != null &&
          !UpdateDialog.isShowing) {
        if (_activeUpdateToast == null ||
            previous?.status != UpdateStatus.downloading) {
          _dismissToast();
          _showBackgroundDownloadToast(current.updateInfo!);
        }
      }

      // 3. Download finished: ready to install
      if (current.status == UpdateStatus.readyToInstall &&
          previous?.status != UpdateStatus.readyToInstall &&
          current.updateInfo != null) {
        _dismissToast();
        if (!UpdateDialog.isShowing) {
          final info = current.updateInfo!;
          _activeUpdateToast = showToast(
            context: context,
            showDuration: const Duration(minutes: 5),
            builder: (context, overlay) {
              return UpdateReadyToast(
                info: info,
                onDismiss: _dismissToast,
                onInstallAndRestart: () {
                  _dismissToast();
                  ref.read(updateProvider.notifier).installAndRestart();
                },
                onOpenUpdateDialog: () {
                  _dismissToast();
                  UpdateDialog.show(context, info);
                },
              );
            },
          );
        }
      }

      // 4. Download failed
      if (current.status == UpdateStatus.error &&
          current.errorType == UpdateErrorType.downloadFailed &&
          previous?.status != UpdateStatus.error) {
        _dismissToast();
        if (!UpdateDialog.isShowing) {
          _activeUpdateToast = showToast(
            context: context,
            showDuration: AppConfig.toastLongDuration,
            builder: (context, overlay) {
              return UpdateFailedToast(
                onDismiss: _dismissToast,
                onRetry: () {
                  _dismissToast();
                  ref.read(updateProvider.notifier).downloadUpdate();
                },
              );
            },
          );
        }
      }

      // 5. Canceled / Idle
      if (current.status == UpdateStatus.idle &&
          previous?.status == UpdateStatus.downloading) {
        _dismissToast();
      }
    });

    return widget.child;
  }
}
