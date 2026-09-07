import 'package:flutter/foundation.dart';
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
import 'core/theme/theme_notifier.dart';
import 'l10n/generated/app_localizations.dart';
import 'ui/widgets/update_dialog.dart';

import 'core/storage/database_service.dart';
import 'core/storage/media_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    yield const LicenseEntryWithLineBreaks(
      <String>['Flanki'],
      '''
MIT License

Copyright (c) 2026 ZoroNeo

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.''',
    );
  });
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
    final themeMode = ref.watch(themeNotifierProvider);

    final baseTextStyle = GoogleFonts.beVietnamPro(
      textStyle: const TextStyle(
        height: 1.35,
        leadingDistribution: TextLeadingDistribution.even,
      ),
    );

    final typography = const Typography.geist().copyWith(
      sans: () => baseTextStyle,
      mono: () => GoogleFonts.jetBrainsMono(
        textStyle: const TextStyle(
          height: 1.35,
          leadingDistribution: TextLeadingDistribution.even,
        ),
      ),
      xSmall: () => baseTextStyle.copyWith(fontSize: 12),
      small: () => baseTextStyle.copyWith(fontSize: 14),
      base: () => baseTextStyle.copyWith(fontSize: 16),
      large: () => baseTextStyle.copyWith(fontSize: 18),
      xLarge: () => baseTextStyle.copyWith(fontSize: 20),
      p: () => baseTextStyle.copyWith(fontSize: 16),
      textSmall: () => baseTextStyle.copyWith(fontSize: 14),
    );

    return ShadcnApp.router(
      title: 'Flanki',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      locale: currentLocale,
      themeMode: themeMode,
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
      builder: (context, child) => ComponentTheme<TextFieldTheme>(
        data: const TextFieldTheme(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        ),
        child: ComponentTheme<PrimaryButtonTheme>(
          data: PrimaryButtonTheme(
            textStyle: (context, states, value) => value.copyWith(
              height: 1.35,
              leadingDistribution: TextLeadingDistribution.even,
            ),
          ),
          child: ComponentTheme<OutlineButtonTheme>(
            data: OutlineButtonTheme(
              textStyle: (context, states, value) => value.copyWith(
                height: 1.35,
                leadingDistribution: TextLeadingDistribution.even,
              ),
            ),
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (event) {
                final currentFocus = FocusManager.instance.primaryFocus;
                if (currentFocus != null && currentFocus.hasFocus) {
                  final renderBox =
                      currentFocus.context?.findRenderObject() as RenderBox?;
                  if (renderBox != null && renderBox.hasSize) {
                    final position = renderBox.localToGlobal(Offset.zero);
                    final bounds = position & renderBox.size;
                    if (!bounds.contains(event.position)) {
                      currentFocus.unfocus();
                    }
                  } else {
                    currentFocus.unfocus();
                  }
                }
              },
              child: _AppUpdateWrapper(child: child ?? const SizedBox.shrink()),
            ),
          ),
        ),
      ),
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
        final info = current.updateInfo!;
        _dismissToast();
        _activeUpdateToast = showToast(
          context: context,
          showDuration: const Duration(seconds: 20),
          builder: (context, overlay) {
            final theme = Theme.of(context);
            final l10n = AppLocalizations.of(context)!;
            return SurfaceCard(
              child: Container(
                width: 380,
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
                            style: theme.typography.small.copyWith(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.updateBannerSubtitle,
                            style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    PrimaryButton(
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
              ),
            );
          },
        );
      }
    });

    return widget.child;
  }
}
