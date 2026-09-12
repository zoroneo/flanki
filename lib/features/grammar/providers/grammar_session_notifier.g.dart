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
    r'7b61a83fbbc7ea4196f22cc030b2af367302c0ad';

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
