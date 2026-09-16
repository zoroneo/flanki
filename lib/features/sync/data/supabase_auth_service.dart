import 'package:supabase_flutter/supabase_flutter.dart';

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

  /// Signs up with email and password.
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final client = _client;
    if (client == null) throw StateError('Supabase is not initialized');
    return client.auth.signUp(email: email.trim(), password: password);
  }

  /// Signs in with email and password.
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final client = _client;
    if (client == null) throw StateError('Supabase is not initialized');
    return client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Signs out and clears local session tokens.
  Future<void> signOut() async {
    await _client?.auth.signOut();
  }
}
