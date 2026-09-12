import 'package:flutter/foundation.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
// ignore: implementation_imports
import 'package:shadcn_flutter/src/components/locale/shadcn_localizations_en.dart';

/// Vietnamese localization delegate for shadcn_flutter.
/// Extends [ShadcnLocalizationsEn] so any untranslated key cleanly falls back to English.
class ShadcnLocalizationsViDelegate
    extends LocalizationsDelegate<ShadcnLocalizations> {
  const ShadcnLocalizationsViDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'vi';

  @override
  Future<ShadcnLocalizations> load(Locale locale) {
    return SynchronousFuture<ShadcnLocalizations>(ShadcnLocalizationsVi());
  }

  @override
  bool shouldReload(ShadcnLocalizationsViDelegate old) => false;
}

class ShadcnLocalizationsVi extends ShadcnLocalizationsEn {
  ShadcnLocalizationsVi() : super('vi');

  @override
  String get formNotEmpty => 'Trường này không được để trống';

  @override
  String get invalidValue => 'Giá trị không hợp lệ';

  @override
  String get invalidEmail => 'Email không hợp lệ';

  @override
  String get invalidURL => 'URL không hợp lệ';

  @override
  String get formPhoneNumberInvalid => 'Số điện thoại không hợp lệ';

  @override
  String get formPhoneNumberEmpty => 'Vui lòng nhập số điện thoại';

  @override
  String get commandSearch => 'Nhập lệnh hoặc tìm kiếm...';

  @override
  String get commandEmpty => 'Không tìm thấy kết quả.';

  @override
  String get buttonCancel => 'Hủy';

  @override
  String get buttonSave => 'Lưu';

  @override
  String get timeHour => 'Giờ';

  @override
  String get timeMinute => 'Phút';

  @override
  String get timeSecond => 'Giây';
}
