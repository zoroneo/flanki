// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StudySettingsNotifier)
final studySettingsProvider = StudySettingsNotifierProvider._();

final class StudySettingsNotifierProvider
    extends $NotifierProvider<StudySettingsNotifier, StudySettings> {
  StudySettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'studySettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$studySettingsNotifierHash();

  @$internal
  @override
  StudySettingsNotifier create() => StudySettingsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StudySettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StudySettings>(value),
    );
  }
}

String _$studySettingsNotifierHash() =>
    r'b258b86841ea07ceeff9d0aa86b3efe5baf2093f';

abstract class _$StudySettingsNotifier extends $Notifier<StudySettings> {
  StudySettings build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<StudySettings, StudySettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<StudySettings, StudySettings>,
              StudySettings,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(FsrsEnabledNotifier)
final fsrsEnabledProvider = FsrsEnabledNotifierProvider._();

final class FsrsEnabledNotifierProvider
    extends $NotifierProvider<FsrsEnabledNotifier, bool> {
  FsrsEnabledNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fsrsEnabledProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fsrsEnabledNotifierHash();

  @$internal
  @override
  FsrsEnabledNotifier create() => FsrsEnabledNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$fsrsEnabledNotifierHash() =>
    r'b229ee0b005ec3ec57b601956bb81474b9574099';

abstract class _$FsrsEnabledNotifier extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
