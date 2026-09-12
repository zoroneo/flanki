// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StatsNotifier)
final statsNotifierProvider = StatsNotifierProvider._();

final class StatsNotifierProvider
    extends $NotifierProvider<StatsNotifier, StatsData> {
  StatsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'statsNotifierProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$statsNotifierHash();

  @$internal
  @override
  StatsNotifier create() => StatsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StatsData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StatsData>(value),
    );
  }
}

String _$statsNotifierHash() => r'20f2fcb5d603f77630972580d6d740fd78e88493';

abstract class _$StatsNotifier extends $Notifier<StatsData> {
  StatsData build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<StatsData, StatsData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<StatsData, StatsData>,
              StatsData,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
