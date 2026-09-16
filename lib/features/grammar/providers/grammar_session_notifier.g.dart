// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grammar_session_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GrammarSessionNotifier)
final grammarSessionNotifierProvider = GrammarSessionNotifierProvider._();

final class GrammarSessionNotifierProvider
    extends $NotifierProvider<GrammarSessionNotifier, GrammarSessionState> {
  GrammarSessionNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'grammarSessionNotifierProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$grammarSessionNotifierHash();

  @$internal
  @override
  GrammarSessionNotifier create() => GrammarSessionNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GrammarSessionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GrammarSessionState>(value),
    );
  }
}

String _$grammarSessionNotifierHash() =>
    r'cf04368d6033377f5c71d25235899e1ecc865dcb';

abstract class _$GrammarSessionNotifier extends $Notifier<GrammarSessionState> {
  GrammarSessionState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<GrammarSessionState, GrammarSessionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<GrammarSessionState, GrammarSessionState>,
              GrammarSessionState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
