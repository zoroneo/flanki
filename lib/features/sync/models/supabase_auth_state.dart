import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
}
