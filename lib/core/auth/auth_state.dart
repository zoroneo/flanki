import 'anki_web_auth_service.dart';

enum AuthStatus {
  unauthenticated,
  authenticating,
  authenticated,
  error,
}

class AuthState {
  final AuthStatus status;
  final String? email;
  final String? hostKey;
  final String? errorMessage;
  final AuthErrorCode? errorCode;
  final DateTime? lastSyncedAt;

  const AuthState({
    this.status = AuthStatus.unauthenticated,
    this.email,
    this.hostKey,
    this.errorMessage,
    this.errorCode,
    this.lastSyncedAt,
  });

  const AuthState.unauthenticated()
      : this(status: AuthStatus.unauthenticated);

  const AuthState.authenticating({String? email})
      : this(status: AuthStatus.authenticating, email: email);

  const AuthState.authenticated({
    required String email,
    required String hostKey,
    DateTime? lastSyncedAt,
  }) : this(
          status: AuthStatus.authenticated,
          email: email,
          hostKey: hostKey,
          lastSyncedAt: lastSyncedAt,
        );

  const AuthState.error(String message, {String? email, AuthErrorCode? errorCode})
      : this(
          status: AuthStatus.error,
          errorMessage: message,
          errorCode: errorCode,
          email: email,
        );

  bool get isAuthenticated => status == AuthStatus.authenticated && hostKey != null;
  bool get isLoading => status == AuthStatus.authenticating;

  AuthState copyWith({
    AuthStatus? status,
    String? email,
    String? hostKey,
    String? errorMessage,
    AuthErrorCode? errorCode,
    DateTime? lastSyncedAt,
  }) {
    return AuthState(
      status: status ?? this.status,
      email: email ?? this.email,
      hostKey: hostKey ?? this.hostKey,
      errorMessage: errorMessage ?? this.errorMessage,
      errorCode: errorCode ?? this.errorCode,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}
