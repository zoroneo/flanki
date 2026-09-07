import 'package:flutter/material.dart' as m;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/anki_bridge.dart';
import '../../../core/auth/auth_notifier.dart';
import '../../../core/config/app_config.dart';
import '../../../core/localization/locale_notifier.dart';
import '../../../core/notifiers/card_browser_notifier.dart';
import '../../../core/notifiers/deck_notifier.dart';
import '../../../core/notifiers/settings_notifier.dart';
import '../../../core/notifiers/update_notifier.dart';
import '../../../core/services/desktop_update_service.dart';
import '../../../core/services/desktop_window_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/storage/database_service.dart';
import '../../../core/sync/anki_web_sync_service.dart';
import '../../widgets/sync_conflict_dialog.dart';
import '../../widgets/sync_progress_toast.dart';
import '../../widgets/update_dialog.dart';
import '../auth/anki_web_auth_sheet.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authNotifierProvider);
    final authNotifier = ref.read(authNotifierProvider.notifier);
    final l10n = context.l10n;
    final currentLocale = ref.watch(localeNotifierProvider);
    final localeNotifier = ref.read(localeNotifierProvider.notifier);
    final studySettings = ref.watch(studySettingsProvider);
    final studySettingsNotifier = ref.read(studySettingsProvider.notifier);
    final isFsrsEnabled = studySettings.fsrsEnabled;
    final updateState = ref.watch(updateProvider);
    final updateNotifier = ref.read(updateProvider.notifier);

    final isVi = currentLocale?.languageCode == 'vi';
    final isEn = currentLocale?.languageCode == 'en';
    final isSystem = currentLocale == null;

    final isSyncing = useState(false);

    Future<void> handleSync() async {
      if (!authState.isAuthenticated || authState.hostKey == null) {
        final loggedIn = await AnkiWebAuthSheet.show(context);
        if (loggedIn != true) return;
      }

      isSyncing.value = true;
      final syncService = AnkiWebSyncService(
        messages: SyncProgressMessages.fromL10n(l10n),
      );

      // 1. Check local changes against last sync timestamp
      final lastSyncTime = authState.lastSyncedAt;
      final hasLocalChanges =
          DatabaseService.instance.hasLocalChangesSince(lastSyncTime);

      final check = await syncService.checkSyncStatus(
        hostKey: authState.hostKey!,
        lastSyncTime: lastSyncTime,
        hasLocalChanges: hasLocalChanges,
      );

      SyncConflictChoice? choice;
      if (check.action == SyncActionRequired.conflict) {
        if (!context.mounted) {
          isSyncing.value = false;
          return;
        }
        choice = await SyncConflictDialog.show(
          context,
          localLastSync: check.localLastSync,
          serverMod: check.serverMod,
        );
        if (choice == null) {
          isSyncing.value = false;
          return;
        }
      }

      final shouldUpload = choice == SyncConflictChoice.upload ||
          (choice == null && check.action == SyncActionRequired.upload);

      final statusNotifier = ValueNotifier<SyncProgressStatus>(
        SyncProgressStatus(
          title: l10n.syncAnkiWeb,
          message:
              shouldUpload ? l10n.preparingUpload : l10n.connectingToAnkiWeb,
          progress: 0.05,
        ),
      );

      ToastOverlay? toastOverlay;
      if (context.mounted) {
        toastOverlay = SyncProgressToast.show(
          context: context,
          statusNotifier: statusNotifier,
        );
      }

      try {
        final AnkiWebSyncResult syncResult;
        if (shouldUpload) {
          final dbBytes = await DatabaseService.instance.exportToAnki2Db();
          syncResult = await syncService.uploadCollection(
            hostKey: authState.hostKey!,
            dbBytes: dbBytes,
            onProgress: (stage, progress) {
              statusNotifier.value = SyncProgressStatus(
                title: l10n.syncAnkiWeb,
                message: stage,
                progress: progress,
              );
            },
          );
        } else {
          syncResult = await syncService.syncCollection(
            hostKey: authState.hostKey!,
            onProgress: (stage, progress) {
              statusNotifier.value = SyncProgressStatus(
                title: l10n.syncAnkiWeb,
                message: stage,
                progress: progress,
              );
            },
          );
        }

        if (!context.mounted) return;

        if (syncResult.success) {
          ref.read(authNotifierProvider.notifier).recordSyncSuccess();
          if (syncResult.decks.isNotEmpty) {
            await ref
                .read(deckListProvider.notifier)
                .addDecks(syncResult.decks);
          }
          if (syncResult.cards.isNotEmpty) {
            await ref
                .read(cardBrowserProvider.notifier)
                .addCards(syncResult.cards);
          }
          await ref.read(deckListProvider.notifier).refresh();

          statusNotifier.value = SyncProgressStatus(
            title: l10n.syncCompleted,
            message: syncResult.message,
            progress: 1.0,
            isCompleted: true,
          );
          Future.delayed(const Duration(seconds: 4), () {
            toastOverlay?.close();
          });
        } else {
          statusNotifier.value = SyncProgressStatus(
            title: l10n.syncFailed,
            message: syncResult.message,
            progress: 1.0,
            isError: true,
          );
          Future.delayed(const Duration(seconds: 5), () {
            toastOverlay?.close();
          });
        }
      } catch (e) {
        statusNotifier.value = SyncProgressStatus(
          title: l10n.syncError,
          message: e.toString(),
          progress: 1.0,
          isError: true,
        );
        Future.delayed(const Duration(seconds: 5), () {
          toastOverlay?.close();
        });
      } finally {
        isSyncing.value = false;
      }
    }

    return Scaffold(
      headers: [AppBar(title: Text(l10n.settingsTitle))],
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // AnkiWeb Account Card
              Text(
                l10n.accountAndSync,
                style: theme.typography.xSmall.copyWith(
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: authState.isAuthenticated
                                ? m.Colors.green.withValues(alpha: 0.15)
                                : theme.colorScheme.muted,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            authState.isAuthenticated
                                ? LucideIcons.cloud
                                : LucideIcons.cloudOff,
                            color: authState.isAuthenticated
                                ? m.Colors.green
                                : theme.colorScheme.mutedForeground,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authState.isAuthenticated
                                    ? authState.email!
                                    : l10n.notLinkedAnkiWeb,
                                style: theme.typography.semiBold,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                authState.isAuthenticated
                                    ? (authState.lastSyncedAt != null
                                        ? l10n.syncedAt(
                                            '${authState.lastSyncedAt!.hour.toString().padLeft(2, '0')}:${authState.lastSyncedAt!.minute.toString().padLeft(2, '0')}',
                                          )
                                        : l10n.readyToSync)
                                    : l10n.loginToSyncHint,
                                style: theme.typography.xSmall.copyWith(
                                  color: theme.colorScheme.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    if (authState.isAuthenticated) ...[
                      SizedBox(
                        height: 38,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: OutlineButton(
                                alignment: Alignment.center,
                                onPressed: () async {
                                  await authNotifier.logout();
                                  if (context.mounted) {
                                    showToast(
                                      context: context,
                                      builder: (context, overlay) {
                                        return SurfaceCard(
                                          child: Basic(
                                            title: Text(l10n.loggedOut),
                                            subtitle: Text(l10n.logoutSubtitle),
                                            trailing: IconButton.ghost(
                                              icon: const Icon(LucideIcons.x),
                                              onPressed: () => overlay.close(),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      LucideIcons.logOut,
                                      size: 16,
                                      color: theme.colorScheme.destructive,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      l10n.logout,
                                      style: TextStyle(
                                        color: theme.colorScheme.destructive,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: PrimaryButton(
                                alignment: Alignment.center,
                                onPressed: isSyncing.value ? null : handleSync,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    isSyncing.value
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(
                                            LucideIcons.refreshCw,
                                            size: 16,
                                          ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isSyncing.value
                                          ? l10n.syncing
                                          : l10n.syncAnkiWeb,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else
                      SizedBox(
                        width: double.infinity,
                        height: 38,
                        child: PrimaryButton(
                          alignment: Alignment.center,
                          onPressed: () => AnkiWebAuthSheet.show(context),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(LucideIcons.logIn, size: 16),
                              const SizedBox(width: 8),
                              Text(l10n.connectAnkiWeb),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // App Preferences (Language & Theme)
              Text(
                l10n.appPreferences,
                style: theme.typography.xSmall.copyWith(
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.languages, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.language,
                                style: theme.typography.semiBold,
                              ),
                              Text(
                                l10n.languageSubtitle,
                                style: theme.typography.xSmall.copyWith(
                                  color: theme.colorScheme.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _LanguageOptionButton(
                            label: l10n.languageVietnamese,
                            isSelected: isVi,
                            onTap: () =>
                                localeNotifier.setLocale(const Locale('vi')),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _LanguageOptionButton(
                            label: l10n.languageEnglish,
                            isSelected: isEn,
                            onTap: () =>
                                localeNotifier.setLocale(const Locale('en')),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _LanguageOptionButton(
                            label: l10n.languageSystem,
                            isSelected: isSystem,
                            onTap: () => localeNotifier.setLocale(null),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Spaced Repetition Engine
              Text(
                l10n.spacedRepetitionAlgorithm,
                style: theme.typography.xSmall.copyWith(
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.enableFsrs,
                                style: theme.typography.semiBold,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isFsrsEnabled
                                    ? l10n.fsrsSubtitle
                                    : l10n.sm2Subtitle,
                                style: theme.typography.xSmall.copyWith(
                                  color: theme.colorScheme.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Switch(
                          value: isFsrsEnabled,
                          onChanged: (val) {
                            studySettingsNotifier.updateSettings(
                              studySettings.copyWith(fsrsEnabled: val),
                            );
                          },
                        ),
                      ],
                    ),
                    if (isFsrsEnabled) ...[
                      const SizedBox(height: 16),
                      Text(
                        '${l10n.targetRetentionRate('${(studySettings.desiredRetention * 100).toInt()}%')} (FSRS)',
                        style: theme.typography.small.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [0.80, 0.85, 0.90, 0.95].map((rate) {
                          final isSelected =
                              (studySettings.desiredRetention - rate).abs() <
                                  0.001;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 3,
                              ),
                              child: _LanguageOptionButton(
                                label: '${(rate * 100).toInt()}%',
                                isSelected: isSelected,
                                onTap: () {
                                  studySettingsNotifier.updateSettings(
                                    studySettings.copyWith(
                                      desiredRetention: rate,
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    Text(
                      l10n.newCardsPerDay,
                      style: theme.typography.small.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [10, 20, 30, 50].map((count) {
                        final isSelected =
                            studySettings.newCardsPerDay == count;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: _LanguageOptionButton(
                              label: '$count',
                              isSelected: isSelected,
                              onTap: () {
                                studySettingsNotifier.updateSettings(
                                  studySettings.copyWith(newCardsPerDay: count),
                                );
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.maxReviewsPerDay,
                      style: theme.typography.small.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [50, 100, 200, 500].map((count) {
                        final isSelected =
                            studySettings.maxReviewsPerDay == count;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: _LanguageOptionButton(
                              label: '$count',
                              isSelected: isSelected,
                              onTap: () {
                                studySettingsNotifier.updateSettings(
                                  studySettings.copyWith(
                                    maxReviewsPerDay: count,
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Study Reminders (Duolingo Style)
              Text(
                l10n.settingsStudyReminders,
                style: theme.typography.xSmall.copyWith(
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.settingsDailyReminder,
                                style: theme.typography.semiBold,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l10n.settingsDailyReminderSubtitle,
                                style: theme.typography.xSmall.copyWith(
                                  color: theme.colorScheme.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Switch(
                          value: studySettings.reminderEnabled,
                          onChanged: (val) {
                            studySettingsNotifier.toggleReminder(val);
                          },
                        ),
                      ],
                    ),
                    if (studySettings.reminderEnabled) ...[
                      const SizedBox(height: 16),
                      Text(
                        l10n.settingsReminderTime,
                        style: theme.typography.small.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          [19, 0],
                          [20, 0],
                          [21, 0],
                          [22, 0],
                        ].map((time) {
                          final hour = time[0];
                          final min = time[1];
                          final label =
                              '${hour.toString().padLeft(2, '0')}:${min.toString().padLeft(2, '0')}';
                          final isSelected =
                              studySettings.reminderHour == hour &&
                                  studySettings.reminderMinute == min;
                          return Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 3),
                              child: _LanguageOptionButton(
                                label: label,
                                isSelected: isSelected,
                                onTap: () => studySettingsNotifier
                                    .setReminderTime(hour, min),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(l10n.settingsStreakSaver),
                                    const SizedBox(width: 6),
                                    const Text(
                                      '(22:30)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  l10n.settingsStreakSaverSubtitle,
                                  style: theme.typography.xSmall.copyWith(
                                    color: theme.colorScheme.mutedForeground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Switch(
                            value: studySettings.streakSaverEnabled,
                            onChanged: (val) {
                              studySettingsNotifier.toggleStreakSaver(val);
                            },
                          ),
                        ],
                      ),
                      if (DesktopWindowService.isDesktop) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.settingsMinimizeToTray,
                                    style: theme.typography.semiBold,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    l10n.settingsMinimizeToTraySubtitle,
                                    style: theme.typography.xSmall.copyWith(
                                      color: theme.colorScheme.mutedForeground,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Switch(
                              value: studySettings.minimizeToTrayOnClose,
                              onChanged: (val) {
                                studySettingsNotifier.toggleMinimizeToTray(val);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.settingsLaunchAtStartup,
                                    style: theme.typography.semiBold,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    l10n.settingsLaunchAtStartupSubtitle,
                                    style: theme.typography.xSmall.copyWith(
                                      color: theme.colorScheme.mutedForeground,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Switch(
                              value: studySettings.launchAtStartup,
                              onChanged: (val) {
                                studySettingsNotifier
                                    .toggleLaunchAtStartup(val);
                              },
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: OutlineButton(
                          onPressed: () async {
                            await NotificationService.instance
                                .showInstantTestNotification();
                            if (context.mounted) {
                              showToast(
                                context: context,
                                builder: (context, overlay) {
                                  return SurfaceCard(
                                    child: Basic(
                                      title: Text(
                                          l10n.settingsTestNotificationSent),
                                      subtitle: Text(
                                          l10n.settingsTestNotificationCheck),
                                      trailing: IconButton.ghost(
                                        icon: const Icon(LucideIcons.x),
                                        onPressed: () => overlay.close(),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(LucideIcons.bell, size: 15),
                              const SizedBox(width: 8),
                              Text(l10n.settingsTestNotificationButton),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // System / Core Info
              Text(
                l10n.aboutSection,
                style: theme.typography.xSmall.copyWith(
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _InfoRow(
                      label: l10n.ankiRustCore,
                      value: AnkiBridge.isAvailable
                          ? 'rslib (Linked)'
                          : l10n.dartCoreEngine,
                    ),
                    const Divider(),
                    _InfoRow(label: l10n.appearance, value: l10n.themeZinc),
                    const Divider(),
                    _InfoRow(
                      label: l10n.algorithmLabel,
                      value: isFsrsEnabled ? 'FSRS v5' : 'SM-2',
                    ),
                    const Divider(),
                    _VersionInfoRow(
                      label: l10n.appVersion,
                      version: AppConfig.version,
                      updateState: updateState,
                      onCheckUpdate: () async {
                        final info = await updateNotifier.checkForUpdates();
                        if (info != null && info.hasUpdate && context.mounted) {
                          UpdateDialog.show(context, info);
                        }
                      },
                      onShowDialog: () {
                        if (updateState.updateInfo != null && context.mounted) {
                          UpdateDialog.show(context, updateState.updateInfo!);
                        }
                      },
                    ),
                    const Divider(),
                    _ClickableInfoRow(
                      label: l10n.openSourceLicenses,
                      onTap: () => context.push('/licenses'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 110),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageOptionButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOptionButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.muted.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.border,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.typography.small.copyWith(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? theme.colorScheme.primaryForeground
                  : theme.colorScheme.foreground,
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: theme.typography.small.copyWith(
                color: theme.colorScheme.mutedForeground,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: theme.typography.small.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VersionInfoRow extends StatelessWidget {
  final String label;
  final String version;
  final UpdateState updateState;
  final VoidCallback onCheckUpdate;
  final VoidCallback onShowDialog;

  const _VersionInfoRow({
    required this.label,
    required this.version,
    required this.updateState,
    required this.onCheckUpdate,
    required this.onShowDialog,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final isSupported = DesktopUpdateService.isSupported;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: theme.typography.small.copyWith(
                color: theme.colorScheme.mutedForeground,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 6,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  version,
                  style: theme.typography.small.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isSupported) ...[
                  const SizedBox(width: 8),
                  if (updateState.status == UpdateStatus.checking) ...[
                    Text(
                      l10n.checkingForUpdates,
                      style: theme.typography.xSmall.copyWith(
                        color: theme.colorScheme.mutedForeground,
                      ),
                    ),
                  ] else if (updateState.status == UpdateStatus.available) ...[
                    GestureDetector(
                      onTap: onShowDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.circleArrowUp, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              l10n.newVersionBadge(
                                  updateState.updateInfo?.latestVersion ?? ''),
                              style: theme.typography.xSmall.copyWith(
                                color: theme.colorScheme.primaryForeground,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else if (updateState.status == UpdateStatus.upToDate) ...[
                    GestureDetector(
                      onTap: onCheckUpdate,
                      child: Text(
                        l10n.latestVersionStatus,
                        style: theme.typography.xSmall.copyWith(
                          color: theme.colorScheme.mutedForeground,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ] else ...[
                    GestureDetector(
                      onTap: onCheckUpdate,
                      child: Text(
                        l10n.checkForUpdates,
                        style: theme.typography.xSmall.copyWith(
                          color: theme.colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClickableInfoRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ClickableInfoRow({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.typography.small.copyWith(
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              size: 16,
              color: theme.colorScheme.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }
}

