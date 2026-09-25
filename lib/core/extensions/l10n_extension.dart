import 'package:flutter/widgets.dart';

import '../../l10n/generated/app_localizations.dart';

export '../../l10n/generated/app_localizations.dart';

/// Extension cung cấp truy cập an toàn và tiện lợi tới [AppLocalizations].
extension AppLocalizationsX on BuildContext {
  /// Truy xuất [AppLocalizations] từ context hiện hành.
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  /// Truy xuất [AppLocalizations] nullable (an toàn cho headless tests hoặc overlays).
  AppLocalizations? get maybeL10n => AppLocalizations.of(this);
}
