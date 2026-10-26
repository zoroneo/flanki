import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_config.dart';
import '../../../core/logging/breadcrumb_tracker.dart';
import '../../../core/logging/error_logger.dart';
import '../../../core/logging/error_severity.dart';
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
  SupabaseAuthService? _authServiceInstance;
  SupabaseAuthService get _authService =>
      _authServiceInstance ?? ref.read(supabaseAuthServiceProvider);
  StreamSubscription<AuthState>? _sub;

  @override
  SupabaseAuthState build() {
    _authServiceInstance = ref.read(supabaseAuthServiceProvider);
    final auth = _authService;

    final currentUser = auth.currentUser;
    final initialStatus = currentUser != null
        ? SupabaseAuthStatus.authenticated
        : SupabaseAuthStatus.unauthenticated;

    _sub = auth.authStateChanges.listen((data) {
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
    BreadcrumbTracker.instance.add(
      Breadcrumb(category: 'auth', message: 'Attempting email sign-in'),
    );
    try {
      final res = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      state = SupabaseAuthState(
        status: SupabaseAuthStatus.authenticated,
        user: res.user,
      );
      BreadcrumbTracker.instance.add(
        Breadcrumb(
          category: 'auth',
          message: 'Email sign-in successful: ${res.user?.id}',
        ),
      );
      return true;
    } on AuthException catch (e, st) {
      ErrorLogger.instance.captureException(
        e,
        stackTrace: st,
        context: 'SupabaseAuthNotifier.signIn (AuthException)',
        severity: ErrorSeverity.warning,
      );
      state = SupabaseAuthState(
        status: SupabaseAuthStatus.error,
        errorMessage: e.message,
      );
      return false;
    } catch (e, st) {
      ErrorLogger.instance.captureException(
        e,
        stackTrace: st,
        context: 'SupabaseAuthNotifier.signIn (Unexpected)',
        severity: ErrorSeverity.error,
      );
      state = SupabaseAuthState(
        status: SupabaseAuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> signUp(String email, String password) async {
    state = state.copyWith(status: SupabaseAuthStatus.loading);
    BreadcrumbTracker.instance.add(
      Breadcrumb(category: 'auth', message: 'Attempting email sign-up'),
    );
    try {
      final res = await _authService.signUpWithEmail(
        email: email,
        password: password,
      );
      state = SupabaseAuthState(
        status: SupabaseAuthStatus.authenticated,
        user: res.user,
      );
      BreadcrumbTracker.instance.add(
        Breadcrumb(
          category: 'auth',
          message: 'Email sign-up successful: ${res.user?.id}',
        ),
      );
      return true;
    } on AuthException catch (e, st) {
      ErrorLogger.instance.captureException(
        e,
        stackTrace: st,
        context: 'SupabaseAuthNotifier.signUp (AuthException)',
        severity: ErrorSeverity.warning,
      );
      state = SupabaseAuthState(
        status: SupabaseAuthStatus.error,
        errorMessage: e.message,
      );
      return false;
    } catch (e, st) {
      ErrorLogger.instance.captureException(
        e,
        stackTrace: st,
        context: 'SupabaseAuthNotifier.signUp (Unexpected)',
        severity: ErrorSeverity.error,
      );
      state = SupabaseAuthState(
        status: SupabaseAuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> signInWithOAuth(OAuthProvider provider) async {
    state = state.copyWith(status: SupabaseAuthStatus.loading);
    BreadcrumbTracker.instance.add(
      Breadcrumb(
        category: 'auth',
        message: 'Initiating OAuth sign-in with ${provider.name}',
      ),
    );
    try {
      final initiated = await _authService.signInWithOAuth(provider);
      // Reset loading state after browser launches; deep link or listener will emit on authStateChanges
      state = SupabaseAuthState(
        status: _authService.isAuthenticated
            ? SupabaseAuthStatus.authenticated
            : SupabaseAuthStatus.unauthenticated,
        user: _authService.currentUser,
      );
      if (!initiated) {
        ErrorLogger.instance.captureException(
          StateError(SupabaseConfig.errOAuthInitiationFailed),
          context:
              'SupabaseAuthNotifier.signInWithOAuth(${provider.name}) returned false',
          severity: ErrorSeverity.warning,
        );
        state = const SupabaseAuthState(
          status: SupabaseAuthStatus.error,
          errorMessage: SupabaseConfig.errOAuthInitiationFailed,
        );
      }
      return initiated;
    } on AuthException catch (e, st) {
      ErrorLogger.instance.captureException(
        e,
        stackTrace: st,
        context:
            'SupabaseAuthNotifier.signInWithOAuth(${provider.name}) AuthException',
        severity: ErrorSeverity.error,
      );
      state = SupabaseAuthState(
        status: SupabaseAuthStatus.error,
        errorMessage: e.message,
      );
      return false;
    } catch (e, st) {
      ErrorLogger.instance.captureException(
        e,
        stackTrace: st,
        context:
            'SupabaseAuthNotifier.signInWithOAuth(${provider.name}) Unexpected',
        severity: ErrorSeverity.error,
      );
      state = SupabaseAuthState(
        status: SupabaseAuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> signInWithGoogle() => signInWithOAuth(OAuthProvider.google);

  Future<bool> signInWithApple() => signInWithOAuth(OAuthProvider.apple);

  void resetStatus() {
    if (state.status != SupabaseAuthStatus.authenticated) {
      final isAuth =
          state.user != null ||
          (_authServiceInstance?.isAuthenticated ?? false);
      state = SupabaseAuthState(
        status: isAuth
            ? SupabaseAuthStatus.authenticated
            : SupabaseAuthStatus.unauthenticated,
        user: state.user ?? _authServiceInstance?.currentUser,
      );
    }
  }

  Future<void> signOut() async {
    try {
      BreadcrumbTracker.instance.add(
        Breadcrumb(
          category: 'auth',
          message: 'Signing out user: ${state.user?.id}',
        ),
      );
      await _authService.signOut();
      state = const SupabaseAuthState(
        status: SupabaseAuthStatus.unauthenticated,
      );
    } catch (e, st) {
      ErrorLogger.instance.captureException(
        e,
        stackTrace: st,
        context: 'SupabaseAuthNotifier.signOut',
        severity: ErrorSeverity.warning,
      );
      state = const SupabaseAuthState(
        status: SupabaseAuthStatus.unauthenticated,
      );
    }
  }
}
