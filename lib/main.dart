import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:go_router/go_router.dart';
import 'core/localization/locale_notifier.dart';
import 'core/localization/shadcn_localizations_vi.dart';
import 'core/notifiers/deck_notifier.dart';
import 'core/notifiers/settings_notifier.dart';
import 'core/notifiers/stats_notifier.dart';
import 'core/notifiers/update_notifier.dart';
import 'core/router/app_router.dart';
import 'core/services/desktop_window_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/update_poller.dart';
import 'l10n/generated/app_localizations.dart';
import 'ui/widgets/update_dialog.dart';

import 'core/storage/database_service.dart';
import 'core/storage/media_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.instance.init();
  await MediaStorageService.instance.init();
  if (DesktopWindowService.isDesktop) {
    await DesktopWindowService.instance.init(
      onOpenStudy: () {
        rootNavigatorKey.currentContext?.go('/decks');
      },
    );
  }
  await NotificationService.instance.init(
    onNotificationClick: (payload) async {
      if (DesktopWindowService.isDesktop) {
        await DesktopWindowService.instance.showAndFocus();
      }
      if (payload != null && payload.isNotEmpty) {
        rootNavigatorKey.currentContext?.go(payload);
      }
    },
  );
  runApp(
    const ProviderScope(
      child: FlankiApp(),
    ),
  );
}

class FlankiApp extends ConsumerWidget {
  const FlankiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final currentLocale = ref.watch(localeNotifierProvider);

    final typography = const Typography.geist().copyWith(
      sans: () => GoogleFonts.beVietnamPro(),
      mono: () => GoogleFonts.jetBrainsMono(),
    );

    return ShadcnApp.router(
      title: 'Flanki',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      locale: currentLocale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ShadcnLocalizationsViDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorSchemes.lightZinc,
        radius: 0.5,
        typography: typography,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorSchemes.darkZinc,
        radius: 0.5,
        typography: typography,
      ),
      builder: (context, child) => _AppUpdateWrapper(child: child ?? const SizedBox.shrink()),
    );
  }
}

class _AppUpdateWrapper extends ConsumerStatefulWidget {
  final Widget child;
  const _AppUpdateWrapper({required this.child});

  @override
  ConsumerState<_AppUpdateWrapper> createState() => _AppUpdateWrapperState();
}

class _AppUpdateWrapperState extends ConsumerState<_AppUpdateWrapper>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
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
        isReminderEnabled: () => ref.read(studySettingsProvider).reminderEnabled,
        getReminderHour: () => ref.read(studySettingsProvider).reminderHour,
        getReminderMinute: () => ref.read(studySettingsProvider).reminderMinute,
        isStreakSaverEnabled: () => ref.read(studySettingsProvider).streakSaverEnabled,
        getStreakDays: () => ref.read(statsNotifierProvider).streakDays,
        getDueCardsCount: () {
          final decks = ref.read(deckListProvider);
          return decks.fold<int>(0, (sum, deck) => sum + deck.dueCount);
        },
        hasStudiedToday: () => ref.read(statsNotifierProvider).reviewedToday > 0,
      );
    }
  }

  @override
  void dispose() {
    NotificationService.instance.stopDesktopScheduler();
    WidgetsBinding.instance.removeObserver(this);
    UpdatePoller.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<StudySettings>(studySettingsProvider, (_, _) {
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
        final info = current.updateInfo!;
        showToast(
          context: context,
          builder: (context, overlay) {
            final theme = Theme.of(context);
            final l10n = AppLocalizations.of(context)!;
            return SurfaceCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.circleArrowUp,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.updateBannerTitle(info.latestVersion),
                          style: theme.typography.small.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          l10n.updateBannerSubtitle,
                          style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    PrimaryButton(
                      onPressed: () {
                        overlay.close();
                        UpdateDialog.show(context, info);
                      },
                      child: Text(l10n.updateAction),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    });

    return widget.child;
  }
}
