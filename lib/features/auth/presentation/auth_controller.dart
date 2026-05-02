import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/repositories/auth_repository.dart';
import '../domain/auth_models.dart';
import 'auth_state.dart';

final authControllerProvider = NotifierProvider<AuthController, AuthState>(() {
  return AuthController();
});

class AuthController extends Notifier<AuthState> {
  late AuthRepository _authRepository;

  @override
  AuthState build() {
    _authRepository = ref.watch(authRepositoryProvider);

    // Check for existing session on build
    _loadSession();

    return AuthState.initial();
  }

  Future<void> _loadSession() async {
    final isAuth = await _authRepository.isAuthenticated();
    if (isAuth) {
      try {
        final user = await _authRepository.getCurrentUser();
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: User(
            id: user.id,
            phoneNumber: user.phoneNumber,
            name: user.nickname,
            isAnonymous: user.isAnonymous,
          ),
        );
      } catch (_) {
        // Clear invalid session
        await _authRepository.logout();
      }
    }
  }

  Future<void> requestOTP(String phoneNumber) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      await _authRepository.requestOtp(phoneNumber);
      state = state.copyWith(
        status: AuthStatus.otpSent,
        phoneNumber: phoneNumber,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
    }
  }

  Future<void> verifyOTP(String code) async {
    if (state.phoneNumber == null) return;
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final tokenResponse = await _authRepository.verifyOtp(
        state.phoneNumber!,
        code,
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: User(
          id: tokenResponse.user.id,
          phoneNumber: tokenResponse.user.phoneNumber,
          name: tokenResponse.user.nickname,
          isAnonymous: tokenResponse.user.isAnonymous,
        ),
      );
    } catch (e) {
      state = state.copyWith(status: AuthStatus.otpSent, error: e.toString());
    }
  }

  /// For testing only - bypasses real auth
  Future<void> setMockAuthenticated(String phoneNumber) async {
    debugPrint('AuthController: Setting mock authenticated for $phoneNumber');
    final user = User(
      id: "mock_user_${DateTime.now().millisecondsSinceEpoch}",
      phoneNumber: phoneNumber,
    );

    state = state.copyWith(status: AuthStatus.authenticated, user: user);
    debugPrint(
      'AuthController: Status is now ${state.status}, user name is ${state.user?.name}',
    );
  }

  Future<void> continueAnonymously() async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final session = await _authRepository.createAnonymousSession();

      state = state.copyWith(
        status: AuthStatus.anonymous,
        user: User(
          id: session.user.id,
          phoneNumber: session.user.phoneNumber,
          isAnonymous: session.user.isAnonymous,
        ),
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
    }
  }

  Future<void> completeProfile(String name) async {
    if (state.user == null) return;

    final updatedUser = User(
      id: state.user!.id,
      phoneNumber: state.user!.phoneNumber,
      name: name,
      isAnonymous: state.user!.isAnonymous,
    );

    state = state.copyWith(user: updatedUser);
  }

  Future<void> signOut() async {
    await _authRepository.logout();
    state = AuthState.initial();
  }
}
