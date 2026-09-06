import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'core/localization/locale_notifier.dart';
import 'core/localization/shadcn_localizations_vi.dart';
import 'core/router/app_router.dart';
import 'l10n/generated/app_localizations.dart';

import 'core/storage/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.instance.init();
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
    );
  }
}
