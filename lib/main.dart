import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/app_config.dart';
import 'core/config/supabase_config.dart';
import 'core/localization/locale_notifier.dart';
import 'core/localization/shadcn_localizations_vi.dart';
import 'core/services/desktop_window_service.dart';
import 'core/services/notification_service.dart';
import 'core/sync/sync_replicator.dart';
import 'core/theme/app_tokens.dart';
import 'core/theme/theme_notifier.dart';
import 'l10n/generated/app_localizations.dart';
import 'router/app_router.dart';
import 'core/widgets/app_lifecycle_manager.dart';

import 'core/database/database_service.dart';
import 'core/database/media_storage_service.dart';
import 'core/services/card_audio_service.dart';
import 'core/storage/supabase_secure_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ResponsiveSizingConfig.instance.setCustomBreakpoints(
    const ScreenBreakpoints(
      desktop: AppConfig.desktopBreakpoint,
      tablet: AppConfig.tabletBreakpoint,
      watch: AppConfig.watchBreakpoint,
    ),
  );
  LicenseRegistry.addLicense(() async* {
    yield const LicenseEntryWithLineBreaks(
      <String>[AppConfig.appName],
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
  // 1. Critical storage & local DB cache (fast ~10ms startup)
  await Future.wait([
    DatabaseService.instance.init(),
    MediaStorageService.instance.init(),
  ]);

  if (SupabaseConfig.isConfigured) {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        publishableKey: SupabaseConfig.anonKey,
        authOptions: FlutterAuthClientOptions(
          localStorage: SupabaseSecureStorage(),
          authFlowType: AuthFlowType.pkce,
        ),
      );
    } catch (e) {
      debugPrint('${AppConfig.logSupabaseInitFailedPrefix}$e');
    }
  }

  // 2. Render UI immediately to establish window focus and dismiss splash
  runApp(const ProviderScope(child: FlankiApp()));

  // 3. Initialize background / secondary platform services post-frame
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _initSecondaryServices();
  });
}

void _initSecondaryServices() {
  CardAudioService.instance.init();
  if (SupabaseConfig.isConfigured) {
    SyncReplicator().start();
  }
  if (DesktopWindowService.isDesktop) {
    DesktopWindowService.instance.init(
      onOpenStudy: () {
        rootNavigatorKey.currentContext?.go(AppRoutes.decks);
      },
    );
  }
  NotificationService.instance.init(
    onNotificationClick: (payload) async {
      if (DesktopWindowService.isDesktop) {
        await DesktopWindowService.instance.showAndFocus();
      }
      if (payload != null && payload.isNotEmpty) {
        rootNavigatorKey.currentContext?.go(payload);
      }
    },
  );
}

class FlankiApp extends ConsumerWidget {
  const FlankiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final currentLocale = ref.watch(localeNotifierProvider);
    final themeMode = ref.watch(themeNotifierProvider);

    const baseTextStyle = TextStyle(
      fontFamily: AppTypography.fontFamilySans,
      height: AppTypography.lineHeightNormal,
      leadingDistribution: TextLeadingDistribution.even,
    );

    const monoTextStyle = TextStyle(
      fontFamily: AppTypography.fontFamilyMono,
      height: AppTypography.lineHeightNormal,
      leadingDistribution: TextLeadingDistribution.even,
    );

    final typography = const Typography.geist().copyWith(
      sans: () => baseTextStyle,
      mono: () => monoTextStyle,
      xSmall: () => baseTextStyle.copyWith(fontSize: AppTypography.xSmall),
      small: () => baseTextStyle.copyWith(fontSize: AppTypography.small),
      base: () => baseTextStyle.copyWith(fontSize: AppTypography.base),
      large: () => baseTextStyle.copyWith(fontSize: AppTypography.large),
      xLarge: () => baseTextStyle.copyWith(fontSize: AppTypography.xLarge),
      p: () => baseTextStyle.copyWith(fontSize: AppTypography.base),
      textSmall: () => baseTextStyle.copyWith(fontSize: AppTypography.small),
    );

    return ShadcnApp.router(
      title: AppConfig.displayAppName,
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
        radius: AppThemeValues.shadcnRadiusFactor,
        typography: typography,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorSchemes.darkZinc,
        radius: AppThemeValues.shadcnRadiusFactor,
        typography: typography,
      ),
      builder: (context, child) => ComponentTheme<TextFieldTheme>(
        data: const TextFieldTheme(padding: AppThemeValues.textFieldPadding),
        child: ComponentTheme<PrimaryButtonTheme>(
          data: PrimaryButtonTheme(
            textStyle: (context, states, value) => value.copyWith(
              height: AppTypography.lineHeightTight,
              leadingDistribution: TextLeadingDistribution.even,
            ),
          ),
          child: ComponentTheme<OutlineButtonTheme>(
            data: OutlineButtonTheme(
              textStyle: (context, states, value) => value.copyWith(
                height: AppTypography.lineHeightTight,
                leadingDistribution: TextLeadingDistribution.even,
              ),
            ),
            child: ComponentTheme<GhostButtonTheme>(
              data: GhostButtonTheme(
                textStyle: (context, states, value) => value.copyWith(
                  height: AppTypography.lineHeightTight,
                  leadingDistribution: TextLeadingDistribution.even,
                ),
              ),
              child: ComponentTheme<ToastTheme>(
                data: const ToastTheme(
                  toastConstraints: BoxConstraints.tightFor(
                    width: AppDimensions.toastWidth,
                  ),
                ),
                child: Listener(
                  behavior: HitTestBehavior.translucent,
                  onPointerDown: (event) {
                    final currentFocus = FocusManager.instance.primaryFocus;
                    if (currentFocus != null && currentFocus.hasFocus) {
                      final renderBox =
                          currentFocus.context?.findRenderObject()
                              as RenderBox?;
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
                  child: Builder(
                    builder: (context) {
                      final isDark =
                          Theme.of(context).brightness == Brightness.dark;
                      return m.Theme(
                        data: m.ThemeData(
                          extensions: [
                            isDark
                                ? AppColorsExtension.dark
                                : AppColorsExtension.light,
                          ],
                        ),
                        child: AppLifecycleManager(
                          child: child ?? const SizedBox.shrink(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
