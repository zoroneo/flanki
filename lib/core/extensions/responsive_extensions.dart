import 'package:flutter/widgets.dart';
import 'package:responsive_builder/responsive_builder.dart';

/// Extension methods on [BuildContext] to simplify responsive design
/// and eliminate manual screen size / device type boilerplate.
extension ResponsiveContext on BuildContext {
  /// Current [DeviceScreenType] determined by configured breakpoints.
  DeviceScreenType get deviceScreenType =>
      getDeviceType(MediaQuery.sizeOf(this));

  /// Returns `true` if current device screen type is mobile.
  bool get isMobile => deviceScreenType == DeviceScreenType.mobile;

  /// Returns `true` if current device screen type is tablet.
  bool get isTablet => deviceScreenType == DeviceScreenType.tablet;

  /// Returns `true` if current device screen type is desktop.
  bool get isDesktop => deviceScreenType == DeviceScreenType.desktop;

  /// Returns value based on screen type via [getValueForScreenType].
  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
    T? watch,
  }) {
    return getValueForScreenType<T>(
      context: this,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      watch: watch,
    );
  }
}
