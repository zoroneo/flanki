import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:go_router/go_router.dart';

import 'core/localization/locale_notifier.dart';
import 'core/localization/shadcn_localizations_vi.dart';
import 'core/services/desktop_window_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/theme_notifier.dart';
import 'l10n/generated/app_localizations.dart';
import 'router/app_router.dart';
import 'core/widgets/app_lifecycle_manager.dart';

import 'core/database/database_service.dart';
import 'core/database/media_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ResponsiveSizingConfig.instance.setCustomBreakpoints(
    const ScreenBreakpoints(desktop: 1024, tablet: 600, watch: 200),
  );
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
  runApp(const ProviderScope(child: FlankiApp()));
}

class FlankiApp extends ConsumerWidget {
  const FlankiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final currentLocale = ref.watch(localeNotifierProvider);
    final themeMode = ref.watch(themeNotifierProvider);

    const baseTextStyle = TextStyle(
      fontFamily: 'BeVietnamPro',
      height: 1.35,
      leadingDistribution: TextLeadingDistribution.even,
    );

    const monoTextStyle = TextStyle(
      fontFamily: 'JetBrainsMono',
      height: 1.35,
      leadingDistribution: TextLeadingDistribution.even,
    );

    final typography = const Typography.geist().copyWith(
      sans: () => baseTextStyle,
      mono: () => monoTextStyle,
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
              height: 1.2,
              leadingDistribution: TextLeadingDistribution.even,
            ),
          ),
          child: ComponentTheme<OutlineButtonTheme>(
            data: OutlineButtonTheme(
              textStyle: (context, states, value) => value.copyWith(
                height: 1.2,
                leadingDistribution: TextLeadingDistribution.even,
              ),
            ),
            child: ComponentTheme<GhostButtonTheme>(
              data: GhostButtonTheme(
                textStyle: (context, states, value) => value.copyWith(
                  height: 1.2,
                  leadingDistribution: TextLeadingDistribution.even,
                ),
              ),
              child: ComponentTheme<ToastTheme>(
                data: const ToastTheme(
                  toastConstraints: BoxConstraints.tightFor(width: 380),
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
                  child: AppLifecycleManager(
                    child: child ?? const SizedBox.shrink(),
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
