import '../domain/auth_models.dart';

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? error;
  final String? phoneNumber;

  AuthState({required this.status, this.user, this.error, this.phoneNumber});

  factory AuthState.initial() => AuthState(status: AuthStatus.unauthenticated);

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
    String? phoneNumber,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error, // Allow clearing error by setting to null or passing null
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}
