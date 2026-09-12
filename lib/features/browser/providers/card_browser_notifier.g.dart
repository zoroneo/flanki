// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_browser_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CardBrowserNotifier)
final cardBrowserProvider = CardBrowserNotifierProvider._();

final class CardBrowserNotifierProvider
    extends $NotifierProvider<CardBrowserNotifier, CardBrowserState> {
  CardBrowserNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cardBrowserProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cardBrowserNotifierHash();

  @$internal
  @override
  CardBrowserNotifier create() => CardBrowserNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CardBrowserState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CardBrowserState>(value),
    );
  }
}

String _$cardBrowserNotifierHash() =>
    r'523e8e49a7f1f70ecc98f98f2c4598469850b037';

abstract class _$CardBrowserNotifier extends $Notifier<CardBrowserState> {
  CardBrowserState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CardBrowserState, CardBrowserState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CardBrowserState, CardBrowserState>,
              CardBrowserState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
