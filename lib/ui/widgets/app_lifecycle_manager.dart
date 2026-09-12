import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../core/config/app_config.dart';
import '../../features/decks/providers/deck_notifier.dart';
import '../../core/notifiers/locale_notifier.dart';
import '../../core/notifiers/settings_notifier.dart';
import '../../features/stats/providers/stats_notifier.dart';
import '../../core/notifiers/update_notifier.dart';
import '../../core/services/desktop_window_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/update_poller.dart';
import '../../l10n/generated/app_localizations.dart';
import 'update_dialog.dart';

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

  void _dismissToast() {
    _activeUpdateToast?.close();
    _activeUpdateToast = null;
  }

  @override
  void initState() {
    super.initState();
    UpdateDialog.onDismissActiveToast = _dismissToast;
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      UpdatePoller.start(ref);
      await NotificationService.instance.requestPermissions();
      _syncNotifications();
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
    if (UpdateDialog.onDismissActiveToast == _dismissToast) {
      UpdateDialog.onDismissActiveToast = null;
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
            final theme = Theme.of(context);
            final l10n = AppLocalizations.of(context)!;
            return SurfaceCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.circleArrowUp,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.updateBannerTitle(info.latestVersion),
                          style: theme.typography.small.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.updateBannerSubtitle,
                          style: theme.typography.xSmall.copyWith(
                            color: theme.colorScheme.mutedForeground,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  PrimaryButton(
                    alignment: Alignment.center,
                    size: ButtonSize.small,
                    onPressed: () {
                      _dismissToast();
                      UpdateDialog.show(context, info);
                    },
                    child: Text(l10n.updateAction),
                  ),
                  const SizedBox(width: 4),
                  IconButton.ghost(
                    size: ButtonSize.small,
                    icon: const Icon(LucideIcons.x, size: 14),
                    onPressed: _dismissToast,
                  ),
                ],
              ),
            );
          },
        );
      }
    });

    return widget.child;
  }
}
