import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/repositories/auth_repository.dart';
import '../../../core/models/user_model.dart' hide User;
import '../../../core/models/trusted_contact_model.dart' as core;
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

    return AuthState(status: AuthStatus.loading);
  }

  Future<void> _loadSession() async {
    try {
      final isAuth = await _authRepository.isAuthenticated();
      if (isAuth) {
        try {
          // Attempt to fetch current user with valid token
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
        } catch (e) {
          // Token exists but fetching user failed
          // Try silent refresh before giving up
          try {
            await _authRepository.refreshAccessToken();
            // Retry user fetch after successful refresh
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
            // Refresh also failed - clear tokens and go to login
            await _authRepository.clearStoredTokens();
            state = state.copyWith(status: AuthStatus.unauthenticated);
          }
        }
      } else {
        // Not authenticated - check if we can refresh
        try {
          await _authRepository.refreshAccessToken();
          // Refresh succeeded - fetch user
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
          // No valid session - go to login
          state = state.copyWith(status: AuthStatus.unauthenticated);
        }
      }
    } catch (_) {
      // isAuthenticated() itself threw — fall back to unauthenticated
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> requestOTP(String phoneNumber) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final result = await _authRepository.requestOtp(phoneNumber);

      if (result['is_authenticated'] == true) {
        final tokenData = result['token_data'] as Map<String, dynamic>;
        final userMap = tokenData['user'] as Map<String, dynamic>;
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: User(
            id: userMap['id'] as String,
            phoneNumber: userMap['phone_number'] as String?,
            name: userMap['nickname'] as String?,
            isAnonymous: userMap['is_anonymous'] as bool? ?? false,
          ),
        );
        return;
      }

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

  Future<void> completeProfile(
    String name,
    List<TrustedContact> contacts,
  ) async {
    if (state.user == null) return;

    state = state.copyWith(status: AuthStatus.loading, error: null);

    try {
      // Update profile on backend
      final updatedUserResponse = await _authRepository.updateProfile(
        UserProfileUpdate(nickname: name),
      );

      // Add all trusted contacts to backend
      for (final contact in contacts) {
        await _authRepository.addTrustedContact(
          core.TrustedContactCreate(
            name: contact.name,
            phoneNumber: contact.phoneNumber,
          ),
        );
      }

      // Update local state with backend response
      final updatedUser = User(
        id: updatedUserResponse.id,
        phoneNumber: updatedUserResponse.phoneNumber,
        name: updatedUserResponse.nickname,
        isAnonymous: updatedUserResponse.isAnonymous,
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: updatedUser,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        error: 'Failed to save profile: ${e.toString()}',
      );
    }
  }

  Future<void> signOut() async {
    // Clear tokens from secure storage (always runs even if backend call fails)
    await _authRepository.logout();
    // Reset state to unauthenticated — router redirectListenable fires and
    // sends the user to /phone-entry immediately. Next cold launch also lands
    // on /phone-entry because the token is gone from secure storage.
    state = AuthState(status: AuthStatus.unauthenticated);

    // Clear any cached user data or auth-related state
    // This ensures complete logout cleanup
    _clearAuthState();
  }

  void _clearAuthState() {
    // Clear any additional auth-related state if needed
    // This method can be extended to clear other cached data
    state = state.copyWith(user: null, phoneNumber: null, error: null);
  }
}
