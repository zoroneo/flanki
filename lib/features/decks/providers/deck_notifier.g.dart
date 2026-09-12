// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DeckNotifier)
final deckListProvider = DeckNotifierProvider._();

final class DeckNotifierProvider
    extends $NotifierProvider<DeckNotifier, List<DeckModel>> {
  DeckNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deckListProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deckNotifierHash();

  @$internal
  @override
  DeckNotifier create() => DeckNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<DeckModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<DeckModel>>(value),
    );
  }
}

String _$deckNotifierHash() => r'6ff56fd35cee3ca8f6598a537b64e5ab1148c2da';

abstract class _$DeckNotifier extends $Notifier<List<DeckModel>> {
  List<DeckModel> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<DeckModel>, List<DeckModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<DeckModel>, List<DeckModel>>,
              List<DeckModel>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
