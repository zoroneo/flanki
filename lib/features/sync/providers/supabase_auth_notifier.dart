import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/supabase_auth_service.dart';

import '../models/supabase_auth_state.dart';

export '../models/supabase_auth_state.dart';

final supabaseAuthServiceProvider = Provider<SupabaseAuthService>((ref) {
  return SupabaseAuthService();
});

final supabaseAuthNotifierProvider =
    NotifierProvider<SupabaseAuthNotifier, SupabaseAuthState>(
      SupabaseAuthNotifier.new,
    );

class SupabaseAuthNotifier extends Notifier<SupabaseAuthState> {
  late final SupabaseAuthService _authService;
  StreamSubscription<AuthState>? _sub;

  @override
  SupabaseAuthState build() {
    _authService = ref.read(supabaseAuthServiceProvider);

    final currentUser = _authService.currentUser;
    final initialStatus = currentUser != null
        ? SupabaseAuthStatus.authenticated
        : SupabaseAuthStatus.unauthenticated;

    _sub = _authService.authStateChanges.listen((data) {
      final sessionUser = data.session?.user;
      if (sessionUser != null) {
        state = SupabaseAuthState(
          status: SupabaseAuthStatus.authenticated,
          user: sessionUser,
        );
      } else {
        state = const SupabaseAuthState(
          status: SupabaseAuthStatus.unauthenticated,
        );
      }
    });

    ref.onDispose(() {
      _sub?.cancel();
    });

    return SupabaseAuthState(status: initialStatus, user: currentUser);
  }

  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(status: SupabaseAuthStatus.loading);
    try {
      final res = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      state = SupabaseAuthState(
        status: SupabaseAuthStatus.authenticated,
        user: res.user,
      );
      return true;
    } on AuthException catch (e) {
      state = SupabaseAuthState(
        status: SupabaseAuthStatus.error,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = SupabaseAuthState(
        status: SupabaseAuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> signUp(String email, String password) async {
    state = state.copyWith(status: SupabaseAuthStatus.loading);
    try {
      final res = await _authService.signUpWithEmail(
        email: email,
        password: password,
      );
      state = SupabaseAuthState(
        status: SupabaseAuthStatus.authenticated,
        user: res.user,
      );
      return true;
    } on AuthException catch (e) {
      state = SupabaseAuthState(
        status: SupabaseAuthStatus.error,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = SupabaseAuthState(
        status: SupabaseAuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = const SupabaseAuthState(status: SupabaseAuthStatus.unauthenticated);
  }
}
