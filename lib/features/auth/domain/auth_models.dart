enum AuthStatus { unauthenticated, otpSent, authenticated, anonymous, loading }

class User {
  final String id;
  final String? phoneNumber;
  final String? name;
  final bool isAnonymous;

  User({
    required this.id,
    this.phoneNumber,
    this.name,
    this.isAnonymous = false,
  });

  factory User.anonymous(String id) => User(id: id, isAnonymous: true);
}

class AuthSession {
  final String token;
  final User user;

  AuthSession({required this.token, required this.user});
}

class OTPRequest {
  final String phoneNumber;

  OTPRequest({required this.phoneNumber});
}

class OTPVerification {
  final String phoneNumber;
  final String code;

  OTPVerification({required this.phoneNumber, required this.code});
}

class TrustedContact {
  final String name;
  final String phoneNumber;

  TrustedContact({required this.name, required this.phoneNumber});
}
