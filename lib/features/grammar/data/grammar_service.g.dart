// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grammar_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(grammarService)
final grammarServiceProvider = GrammarServiceProvider._();

final class GrammarServiceProvider
    extends $FunctionalProvider<GrammarService, GrammarService, GrammarService>
    with $Provider<GrammarService> {
  GrammarServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'grammarServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$grammarServiceHash();

  @$internal
  @override
  $ProviderElement<GrammarService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GrammarService create(Ref ref) {
    return grammarService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GrammarService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GrammarService>(value),
    );
  }
}

String _$grammarServiceHash() => r'2b96aad6870726c3f4bb2fa809090fb5c212d16c';

@ProviderFor(grammarUnits)
final grammarUnitsProvider = GrammarUnitsProvider._();

final class GrammarUnitsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GrammarUnit>>,
          List<GrammarUnit>,
          FutureOr<List<GrammarUnit>>
        >
    with
        $FutureModifier<List<GrammarUnit>>,
        $FutureProvider<List<GrammarUnit>> {
  GrammarUnitsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'grammarUnitsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$grammarUnitsHash();

  @$internal
  @override
  $FutureProviderElement<List<GrammarUnit>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<GrammarUnit>> create(Ref ref) {
    return grammarUnits(ref);
  }
}

String _$grammarUnitsHash() => r'b56e45e1033b642d605553b12d2cbdf1f7da526c';
