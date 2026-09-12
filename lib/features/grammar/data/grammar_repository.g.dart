// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grammar_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(grammarRepository)
final grammarRepositoryProvider = GrammarRepositoryProvider._();

final class GrammarRepositoryProvider
    extends
        $FunctionalProvider<
          GrammarRepository,
          GrammarRepository,
          GrammarRepository
        >
    with $Provider<GrammarRepository> {
  GrammarRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'grammarRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$grammarRepositoryHash();

  @$internal
  @override
  $ProviderElement<GrammarRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GrammarRepository create(Ref ref) {
    return grammarRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GrammarRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GrammarRepository>(value),
    );
  }
}

String _$grammarRepositoryHash() => r'f66a780ac8eeb22fe6032e65974a8cbe0e1e810f';
