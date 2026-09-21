import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../l10n/generated/app_localizations.dart';

part 'supabase_auth_state.freezed.dart';

enum SupabaseAuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

@freezed
abstract class SupabaseAuthState with _$SupabaseAuthState {
  const SupabaseAuthState._();

  const factory SupabaseAuthState({
    @Default(SupabaseAuthStatus.initial) SupabaseAuthStatus status,
    User? user,
    String? errorMessage,
  }) = _SupabaseAuthState;

  bool get isAuthenticated =>
      status == SupabaseAuthStatus.authenticated && user != null;
  bool get isLoading => status == SupabaseAuthStatus.loading;
  String? get email => user?.email;

  String? getLocalizedError(AppLocalizations l10n) {
    if (status != SupabaseAuthStatus.error || errorMessage == null) return null;
    final msg = errorMessage!.toLowerCase();
    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid_credentials')) {
      return l10n.authInvalidCredentials;
    }
    if (msg.contains('already registered') ||
        msg.contains('user_already_exists')) {
      return l10n.authUserAlreadyExists;
    }
    if (msg.contains('email not confirmed')) {
      return l10n.authEmailNotConfirmed;
    }
    if (msg.contains('network') ||
        msg.contains('socket') ||
        msg.contains('connection')) {
      return l10n.networkUnavailable;
    }
    return errorMessage;
  }
}
