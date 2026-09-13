import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../config/app_config.dart';
import '../../features/decks/providers/deck_notifier.dart';
import '../localization/locale_notifier.dart';
import '../../features/settings/providers/settings_notifier.dart';
import '../../features/stats/providers/stats_notifier.dart';
import '../../features/settings/providers/update_notifier.dart';
import '../services/desktop_window_service.dart';
import '../services/notification_service.dart';
import '../../features/settings/data/update_poller.dart';
import '../../features/settings/models/update_info.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../features/settings/ui/widgets/update_dialog.dart';
import '../theme/app_tokens.dart';

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
        return _BackgroundDownloadToast(info: info, onDismiss: _dismissToast);
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
            final theme = Theme.of(context);
            final l10n = AppLocalizations.of(context)!;
            return SurfaceCard(
              padding: AppEdgeInsets.h12v8,
              child: Row(
                children: [
                  Icon(
                    LucideIcons.circleArrowUp,
                    size: AppIconSize.md,
                    color: theme.colorScheme.primary,
                  ),
                  AppGaps.h12,
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
                        AppGaps.v2,
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
                  AppGaps.h12,
                  if (info.downloadUrl != null) ...[
                    OutlineButton(
                      alignment: Alignment.center,
                      size: ButtonSize.small,
                      onPressed: () {
                        _dismissToast();
                        ref.read(updateProvider.notifier).downloadUpdate();
                      },
                      child: Text(l10n.downloadInBackground),
                    ),
                    AppGaps.h8,
                  ],
                  PrimaryButton(
                    alignment: Alignment.center,
                    size: ButtonSize.small,
                    onPressed: () {
                      _dismissToast();
                      UpdateDialog.show(context, info);
                    },
                    child: Text(l10n.updateAction),
                  ),
                  AppGaps.h4,
                  IconButton.ghost(
                    size: ButtonSize.small,
                    icon: const Icon(LucideIcons.x, size: AppIconSize.sm),
                    onPressed: _dismissToast,
                  ),
                ],
              ),
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
              final theme = Theme.of(context);
              final l10n = AppLocalizations.of(context)!;
              return SurfaceCard(
                padding: AppEdgeInsets.h12v8,
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.circleCheck,
                      size: AppIconSize.md,
                      color: theme.colorScheme.primary,
                    ),
                    AppGaps.h12,
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.updateReadyTitle,
                            style: theme.typography.small.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          AppGaps.v2,
                          Text(
                            l10n.updateReadySubtitle(info.latestVersion),
                            style: theme.typography.xSmall.copyWith(
                              color: theme.colorScheme.mutedForeground,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    AppGaps.h12,
                    PrimaryButton(
                      alignment: Alignment.center,
                      size: ButtonSize.small,
                      onPressed: () {
                        _dismissToast();
                        ref.read(updateProvider.notifier).installAndRestart();
                      },
                      child: Text(l10n.updateReadyAction),
                    ),
                    AppGaps.h8,
                    GhostButton(
                      size: ButtonSize.small,
                      onPressed: () {
                        _dismissToast();
                        UpdateDialog.show(context, info);
                      },
                      child: Text(l10n.updateAction),
                    ),
                    AppGaps.h4,
                    IconButton.ghost(
                      size: ButtonSize.small,
                      icon: const Icon(LucideIcons.x, size: AppIconSize.sm),
                      onPressed: _dismissToast,
                    ),
                  ],
                ),
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
              final theme = Theme.of(context);
              final l10n = AppLocalizations.of(context)!;
              return SurfaceCard(
                padding: AppEdgeInsets.h12v8,
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.circleAlert,
                      size: AppIconSize.md,
                      color: theme.colorScheme.destructive,
                    ),
                    AppGaps.h12,
                    Expanded(
                      child: Text(
                        l10n.updateDownloadFailed,
                        style: theme.typography.small.copyWith(
                          color: theme.colorScheme.destructive,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AppGaps.h12,
                    PrimaryButton(
                      alignment: Alignment.center,
                      size: ButtonSize.small,
                      onPressed: () {
                        _dismissToast();
                        ref.read(updateProvider.notifier).downloadUpdate();
                      },
                      child: Text(l10n.downloadAndInstall),
                    ),
                    AppGaps.h4,
                    IconButton.ghost(
                      size: ButtonSize.small,
                      icon: const Icon(LucideIcons.x, size: AppIconSize.sm),
                      onPressed: _dismissToast,
                    ),
                  ],
                ),
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

class _BackgroundDownloadToast extends ConsumerWidget {
  final UpdateInfo info;
  final VoidCallback onDismiss;

  const _BackgroundDownloadToast({required this.info, required this.onDismiss});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final progress = ref.watch(
      updateProvider.select((s) => s.downloadProgress),
    );
    final pct = (progress * 100).toInt().clamp(0, 100);

    return SurfaceCard(
      padding: AppEdgeInsets.h12v8,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              AppGaps.h12,
              Expanded(
                child: Text(
                  '${l10n.downloadingUpdate} ($pct%)',
                  style: theme.typography.small.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppGaps.h8,
              GhostButton(
                size: ButtonSize.small,
                onPressed: () {
                  onDismiss();
                  UpdateDialog.show(context, info);
                },
                child: Text(l10n.updateAction),
              ),
              AppGaps.h4,
              IconButton.ghost(
                size: ButtonSize.small,
                icon: const Icon(LucideIcons.x, size: AppIconSize.sm),
                onPressed: () {
                  ref.read(updateProvider.notifier).cancelDownload();
                  onDismiss();
                },
              ),
            ],
          ),
          AppGaps.v8,
          LinearProgressIndicator(value: progress),
        ],
      ),
    );
  }
}
