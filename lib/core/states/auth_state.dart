import 'package:freezed_annotation/freezed_annotation.dart';

import '../auth/anki_web_auth_service.dart';

part 'auth_state.freezed.dart';

enum AuthStatus { unauthenticated, authenticating, authenticated, error }

@freezed
abstract class AuthState with _$AuthState {
  const AuthState._();

  const factory AuthState({
    @Default(AuthStatus.unauthenticated) AuthStatus status,
    String? email,
    String? hostKey,
    String? errorMessage,
    AuthErrorCode? errorCode,
    DateTime? lastSyncedAt,
  }) = _AuthState;

  factory AuthState.unauthenticated() => const AuthState();

  factory AuthState.authenticating({String? email}) =>
      AuthState(status: AuthStatus.authenticating, email: email);

  factory AuthState.authenticated({
    required String email,
    required String hostKey,
    DateTime? lastSyncedAt,
  }) => AuthState(
    status: AuthStatus.authenticated,
    email: email,
    hostKey: hostKey,
    lastSyncedAt: lastSyncedAt,
  );

  factory AuthState.error(
    String message, {
    String? email,
    AuthErrorCode? errorCode,
  }) => AuthState(
    status: AuthStatus.error,
    errorMessage: message,
    errorCode: errorCode,
    email: email,
  );

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && hostKey != null;
  bool get isLoading => status == AuthStatus.authenticating;
}
