import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import '../config/app_config.dart';

enum DesktopTrayAction {
  showWindow('show_window'),
  openStudy('open_study'),
  exitApp('exit_app');

  final String key;
  const DesktopTrayAction(this.key);

  static DesktopTrayAction? fromKey(String? key) {
    for (final action in DesktopTrayAction.values) {
      if (action.key == key) return action;
    }
    return null;
  }
}

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
      final l10n = AppConfig.getL10n(localeCode);

      final open = openLabel ?? l10n.trayOpenFlanki;
      final study = studyLabel ?? l10n.trayStudyNow;
      final exit = exitLabel ?? l10n.trayExit;

      final menu = Menu(
        items: [
          MenuItem(key: DesktopTrayAction.showWindow.key, label: open),
          MenuItem(key: DesktopTrayAction.openStudy.key, label: study),
          MenuItem.separator(),
          MenuItem(key: DesktopTrayAction.exitApp.key, label: exit),
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
    final action = DesktopTrayAction.fromKey(menuItem.key);
    switch (action) {
      case DesktopTrayAction.showWindow:
        await showAndFocus();
        break;
      case DesktopTrayAction.openStudy:
        await showAndFocus();
        _onOpenStudy?.call();
        break;
      case DesktopTrayAction.exitApp:
        await destroy();
        exit(0);
      case null:
        break;
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
