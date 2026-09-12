// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_session_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StudySessionNotifier)
final studySessionProvider = StudySessionNotifierProvider._();

final class StudySessionNotifierProvider
    extends $NotifierProvider<StudySessionNotifier, StudySessionState> {
  StudySessionNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'studySessionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$studySessionNotifierHash();

  @$internal
  @override
  StudySessionNotifier create() => StudySessionNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StudySessionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StudySessionState>(value),
    );
  }
}

String _$studySessionNotifierHash() =>
    r'4fc9909e1cc35fde93aba843a26b86bef745897b';

abstract class _$StudySessionNotifier extends $Notifier<StudySessionState> {
  StudySessionState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<StudySessionState, StudySessionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<StudySessionState, StudySessionState>,
              StudySessionState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
