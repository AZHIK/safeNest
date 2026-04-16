import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/auth_service.dart';
import '../data/auth_service_impl.dart';
import '../domain/auth_models.dart';
import 'auth_state.dart';

final secureStorageProvider = Provider((ref) => const FlutterSecureStorage());

final authServiceProvider = Provider<AuthService>((ref) {
  return MockAuthService();
});

final authControllerProvider = NotifierProvider<AuthController, AuthState>(() {
  return AuthController();
});

class AuthController extends Notifier<AuthState> {
  late AuthService _authService;
  late FlutterSecureStorage _storage;

  @override
  AuthState build() {
    _authService = ref.watch(authServiceProvider);
    _storage = ref.watch(secureStorageProvider);

    // Check for existing session on build
    _loadSession();

    return AuthState.initial();
  }

  Future<void> _loadSession() async {
    final token = await _storage.read(key: 'auth_token');
    final userId = await _storage.read(key: 'user_id');
    final isAnon = await _storage.read(key: 'is_anonymous') == 'true';

    if (token != null && userId != null) {
      if (isAnon) {
        // Clear anonymous session so it's not restored next time
        await _storage.deleteAll();
        return;
      }

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: User(id: userId, isAnonymous: false),
      );
    }
  }

  Future<void> requestOTP(String phoneNumber) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      await _authService.requestOTP(phoneNumber);
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
      final session = await _authService.verifyOTP(state.phoneNumber!, code);

      await _storage.write(key: 'auth_token', value: session.token);
      await _storage.write(key: 'user_id', value: session.user.id);
      await _storage.write(key: 'is_anonymous', value: 'false');

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: session.user,
      );
    } catch (e) {
      state = state.copyWith(status: AuthStatus.otpSent, error: e.toString());
    }
  }

  Future<void> setMockAuthenticated(String phoneNumber) async {
    debugPrint('AuthController: Setting mock authenticated for $phoneNumber');
    final user = User(
      id: "mock_user_${DateTime.now().millisecondsSinceEpoch}",
      phoneNumber: phoneNumber,
    );

    // We also save to storage so it survives internal router redirects
    await _storage.write(key: 'auth_token', value: "mock_token");
    await _storage.write(key: 'user_id', value: user.id);
    await _storage.write(key: 'is_anonymous', value: 'false');

    state = state.copyWith(status: AuthStatus.authenticated, user: user);
    debugPrint(
      'AuthController: Status is now ${state.status}, user name is ${state.user?.name}',
    );
  }

  Future<void> continueAnonymously() async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final session = await _authService.continueAnonymously();

      await _storage.write(key: 'auth_token', value: session.token);
      await _storage.write(key: 'user_id', value: session.user.id);
      await _storage.write(key: 'is_anonymous', value: 'true');

      state = state.copyWith(status: AuthStatus.anonymous, user: session.user);
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
    await _authService.signOut();
    await _storage.deleteAll();
    state = AuthState.initial();
  }
}
