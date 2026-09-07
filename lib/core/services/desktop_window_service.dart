import 'dart:io';
import 'dart:ui' show Locale;
import 'package:flutter/foundation.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import '../../l10n/generated/app_localizations.dart';

class DesktopWindowService with WindowListener, TrayListener {
  DesktopWindowService._();
  static final DesktopWindowService instance = DesktopWindowService._();

  static bool get isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

  bool minimizeToTrayOnClose = true;
  VoidCallback? _onOpenStudy;
  bool _isInitialized = false;

  Future<void> init({VoidCallback? onOpenStudy, String? localeCode}) async {
    if (!isDesktop || _isInitialized) return;
    _onOpenStudy = onOpenStudy;

    // 1. Window Manager
    try {
      await windowManager.ensureInitialized();
      windowManager.addListener(this);
      await windowManager.setPreventClose(true);
    } catch (e) {
      debugPrint('[DesktopWindowService] windowManager init error: $e');
    }

    // 2. Launch at Startup
    try {
      launchAtStartup.setup(
        appName: 'Flanki',
        appPath: Platform.resolvedExecutable,
      );
    } catch (e) {
      debugPrint('[DesktopWindowService] launchAtStartup setup error: $e');
    }

    // 3. Tray Manager
    try {
      trayManager.addListener(this);
      final iconPath = Platform.isWindows
          ? 'assets/icons/app_icon.ico'
          : 'assets/icons/app_icon.png';
      await trayManager.setIcon(iconPath);
      await updateTrayMenu(localeCode: localeCode);
    } catch (e) {
      debugPrint('[DesktopWindowService] trayManager init error: $e');
    }

    _isInitialized = true;
  }

  /// Updates system tray menu localized labels dynamically.
  Future<void> updateTrayMenu({
    String? openLabel,
    String? studyLabel,
    String? exitLabel,
    String? localeCode,
  }) async {
    if (!isDesktop) return;
    try {
      final code = localeCode ??
          (Platform.localeName.toLowerCase().startsWith('vi') ? 'vi' : 'en');
      AppLocalizations l10n;
      try {
        l10n = lookupAppLocalizations(Locale(code));
      } catch (_) {
        l10n = lookupAppLocalizations(const Locale('vi'));
      }

      final open = openLabel ?? l10n.trayOpenFlanki;
      final study = studyLabel ?? l10n.trayStudyNow;
      final exit = exitLabel ?? l10n.trayExit;

      final menu = Menu(
        items: [
          MenuItem(
            key: 'show_window',
            label: open,
          ),
          MenuItem(
            key: 'open_study',
            label: study,
          ),
          MenuItem.separator(),
          MenuItem(
            key: 'exit_app',
            label: exit,
          ),
        ],
      );
      await trayManager.setContextMenu(menu);
    } catch (e) {
      debugPrint('[DesktopWindowService] trayManager update error: $e');
    }
  }

  Future<void> showAndFocus() async {
    if (!isDesktop) return;
    try {
      final isMinimized = await windowManager.isMinimized();
      if (isMinimized) {
        await windowManager.restore();
      }
      await windowManager.show();
      await windowManager.focus();
    } catch (e) {
      debugPrint('[DesktopWindowService] showAndFocus error: $e');
    }
  }

  @override
  void onWindowClose() async {
    if (minimizeToTrayOnClose) {
      await windowManager.hide();
    } else {
      await destroy();
      exit(0);
    }
  }

  @override
  void onTrayIconMouseDown() async {
    await showAndFocus();
  }

  @override
  void onTrayIconRightMouseDown() async {
    await trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    if (menuItem.key == 'show_window') {
      await showAndFocus();
    } else if (menuItem.key == 'open_study') {
      await showAndFocus();
      _onOpenStudy?.call();
    } else if (menuItem.key == 'exit_app') {
      await destroy();
      exit(0);
    }
  }

  Future<bool> isAutoStartEnabled() async {
    if (!isDesktop) return false;
    try {
      return await launchAtStartup.isEnabled();
    } catch (_) {
      return false;
    }
  }

  Future<void> setAutoStart(bool enabled) async {
    if (!isDesktop) return;
    try {
      if (enabled) {
        await launchAtStartup.enable();
      } else {
        await launchAtStartup.disable();
      }
    } catch (_) {}
  }

  Future<void> destroy() async {
    try {
      trayManager.removeListener(this);
      windowManager.removeListener(this);
      await trayManager.destroy();
      await windowManager.destroy();
    } catch (_) {}
  }
}
