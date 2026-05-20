import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:SafeNest/features/auth/presentation/auth_controller.dart';
import 'package:SafeNest/features/auth/domain/auth_models.dart';
import 'package:SafeNest/core/repositories/auth_repository.dart';
import 'package:SafeNest/core/models/user_model.dart' as core_user;

import 'auth_controller_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
      ],
    );
  }

  test(
    'should not restore session if isAuthenticated returns false and refresh fails',
    () async {
      when(mockAuthRepository.isAuthenticated()).thenAnswer((_) async => false);
      when(mockAuthRepository.refreshAccessToken()).thenThrow(Exception('Refresh failed'));

      final container = createContainer();

      // Trigger build
      container.read(authControllerProvider);

      // Wait a bit for async tasks to complete
      await Future.delayed(const Duration(milliseconds: 50));

      expect(
        container.read(authControllerProvider).status,
        AuthStatus.unauthenticated,
      );
    },
  );

  test('should restore authenticated session', () async {
    final fakeUser = core_user.User(
      id: 'fake_uid',
      phoneNumber: 'fake_phone',
      isAnonymous: false,
      isVerified: true,
      languagePreference: 'en',
      status: 'active',
      createdAt: DateTime.now(),
      nickname: 'fake_name',
    );

    when(mockAuthRepository.isAuthenticated()).thenAnswer((_) async => true);
    when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => fakeUser);

    final container = createContainer();

    // Wait for the state to change to authenticated
    int retries = 0;
    while (container.read(authControllerProvider).status !=
            AuthStatus.authenticated &&
        retries < 10) {
      await Future.delayed(const Duration(milliseconds: 10));
      retries++;
    }

    expect(
      container.read(authControllerProvider).status,
      AuthStatus.authenticated,
    );
    expect(
      container.read(authControllerProvider).user?.id,
      'fake_uid',
    );
  });
}
