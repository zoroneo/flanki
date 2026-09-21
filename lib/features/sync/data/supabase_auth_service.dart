import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_config.dart';

/// Service managing Supabase authentication sessions, sign-in, sign-up, and sign-out.
class SupabaseAuthService {
  final SupabaseClient? _client;

  SupabaseAuthService({SupabaseClient? client})
    : _client = client ?? _getSupabaseClientSafe();

  static SupabaseClient? _getSupabaseClientSafe() {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Returns current authenticated user or null.
  User? get currentUser => _client?.auth.currentUser;

  /// Returns true if a session is currently active.
  bool get isAuthenticated => currentUser != null;

  /// Emits whenever the user authentication state changes (signed in, signed out, token refreshed).
  Stream<AuthState> get authStateChanges =>
      _client?.auth.onAuthStateChange ?? const Stream.empty();

  /// Returns the current active session or null.
  Session? get currentSession => _client?.auth.currentSession;

  /// Returns the current JWT access token or null.
  String? get accessToken => currentSession?.accessToken;

  /// Initiates OAuth PKCE sign-in flow for the given [provider] (e.g. Google, Apple).
  Future<bool> signInWithOAuth(
    OAuthProvider provider, {
    String? redirectTo,
  }) async {
    final client = _client;
    if (client == null)
      throw StateError(SupabaseConfig.errSupabaseNotInitialized);
    return client.auth.signInWithOAuth(
      provider,
      redirectTo: redirectTo ?? SupabaseConfig.authCallbackUrl,
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

  /// Signs up with email and password.
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final client = _client;
    if (client == null)
      throw StateError(SupabaseConfig.errSupabaseNotInitialized);
    return client.auth.signUp(email: email.trim(), password: password);
  }

  /// Signs in with email and password.
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final client = _client;
    if (client == null)
      throw StateError(SupabaseConfig.errSupabaseNotInitialized);
    return client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Refreshes the active session token.
  Future<AuthResponse> refreshSession() async {
    final client = _client;
    if (client == null)
      throw StateError(SupabaseConfig.errSupabaseNotInitialized);
    return client.auth.refreshSession();
  }

  /// Signs out and clears local session tokens.
  Future<void> signOut() async {
    await _client?.auth.signOut();
  }
}
