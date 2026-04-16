import 'dart:async';
import '../domain/auth_models.dart';
import 'auth_service.dart';

class MockAuthService implements AuthService {
  @override
  Future<void> requestOTP(String phoneNumber) async {
    // Simulate short delay for UI
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<AuthSession> verifyOTP(String phoneNumber, String code) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Accept any 6-digit code for showcasing
    if (code.length == 6) {
      final user = User(id: "user_123", phoneNumber: phoneNumber);
      return AuthSession(token: "mock_token_abc_123", user: user);
    } else {
      throw Exception("OTP must be 6 digits.");
    }
  }

  @override
  Future<AuthSession> continueAnonymously() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final id = "anon_${DateTime.now().millisecondsSinceEpoch}";
    return AuthSession(token: "mock_anon_token_$id", user: User.anonymous(id));
  }

  @override
  Future<User?> getCurrentUser() async {
    // This will be handled by the controller checking storage
    return null;
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
