abstract class AuthService {
  Future<bool> login(String username, String password);
  Future<bool> register(String username, String password);
  Future<bool> continueAnonymously();
  Future<void> logout();
  Future<bool> get isAuthenticated;
}

class MockAuthService implements AuthService {
  bool _authenticated = false;

  @override
  Future<bool> login(String username, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    _authenticated = true;
    return true;
  }

  @override
  Future<bool> register(String username, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    _authenticated = true;
    return true;
  }

  @override
  Future<bool> continueAnonymously() async {
    await Future.delayed(const Duration(seconds: 1));
    _authenticated = true;
    return true;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _authenticated = false;
  }

  @override
  Future<bool> get isAuthenticated async => _authenticated;
}
