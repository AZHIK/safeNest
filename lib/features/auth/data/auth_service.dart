import '../domain/auth_models.dart';

abstract class AuthService {
  Future<void> requestOTP(String phoneNumber);
  Future<AuthSession> verifyOTP(String phoneNumber, String code);
  Future<AuthSession> continueAnonymously();
  Future<User?> getCurrentUser();
  Future<void> signOut();
}
