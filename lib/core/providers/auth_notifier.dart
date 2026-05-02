import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/auth_model.dart';
import '../models/user_model.dart';
import '../models/trusted_contact_model.dart';
import '../repositories/auth_repository.dart';
import '../services/token_storage_service.dart';

/// Auth State
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

/// Auth Notifier
///
/// Manages authentication state using Riverpod.
/// Provides methods for OTP login, anonymous sessions, and logout.
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final TokenStorageService _tokenStorage;

  AuthNotifier(this._authRepository)
    : _tokenStorage = TokenStorageService(),
      super(const AuthState()) {
    // Check existing auth on init
    _checkAuthStatus();
  }

  /// Check if user is already authenticated
  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    try {
      final isAuth = await _authRepository.isAuthenticated();
      if (isAuth) {
        final user = await _authRepository.getCurrentUser();
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Request OTP for phone number
  Future<Map<String, dynamic>> requestOtp(
    String phoneNumber, {
    String countryCode = '+1',
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _authRepository.requestOtp(
        phoneNumber,
        countryCode: countryCode,
      );
      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to send OTP: ${e.toString()}',
      );
      rethrow;
    }
  }

  /// Verify OTP and complete login
  Future<void> verifyOtp(
    String phoneNumber,
    String otpCode, {
    String? countryCode,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final tokenResponse = await _authRepository.verifyOtp(
        phoneNumber,
        otpCode,
        countryCode: countryCode,
      );
      state = state.copyWith(
        user: tokenResponse.user,
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Invalid OTP: ${e.toString()}',
      );
      rethrow;
    }
  }

  /// Continue as anonymous user
  Future<void> continueAnonymously({
    String? deviceFingerprint,
    String languagePreference = 'en',
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final session = await _authRepository.createAnonymousSession(
        deviceFingerprint: deviceFingerprint,
        languagePreference: languagePreference,
      );
      state = state.copyWith(
        user: session.user,
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create anonymous session: ${e.toString()}',
      );
      rethrow;
    }
  }

  /// Logout user
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await _authRepository.logout();
    } finally {
      state = const AuthState(isAuthenticated: false);
    }
  }

  /// Refresh user profile
  Future<void> refreshUser() async {
    if (!state.isAuthenticated) return;
    try {
      final user = await _authRepository.getCurrentUser();
      state = state.copyWith(user: user);
    } catch (_) {
      // Silently fail on refresh
    }
  }

  /// Update user profile
  Future<void> updateProfile(UserProfileUpdate update) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authRepository.updateProfile(update);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update profile: ${e.toString()}',
      );
      rethrow;
    }
  }

  /// Get trusted contacts
  Future<List<TrustedContact>> getTrustedContacts() async {
    return _authRepository.getTrustedContacts();
  }

  /// Add trusted contact
  Future<TrustedContact> addTrustedContact(TrustedContactCreate contact) async {
    return _authRepository.addTrustedContact(contact);
  }

  /// Remove trusted contact
  Future<void> removeTrustedContact(String contactId) async {
    await _authRepository.removeTrustedContact(contactId);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for AuthNotifier
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});
