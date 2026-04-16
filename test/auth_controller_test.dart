import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:SafeNest/features/auth/presentation/auth_controller.dart';
import 'package:SafeNest/features/auth/presentation/auth_state.dart';
import 'package:SafeNest/features/auth/domain/auth_models.dart';
import 'package:SafeNest/features/auth/data/auth_service.dart';

import 'auth_controller_test.mocks.dart';

@GenerateMocks([AuthService, FlutterSecureStorage])
void main() {
  late MockAuthService mockAuthService;
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockAuthService = MockAuthService();
    mockStorage = MockFlutterSecureStorage();
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(mockAuthService),
        secureStorageProvider.overrideWithValue(mockStorage),
      ],
    );
  }

  test(
    'should not restore anonymous session and should clear storage',
    () async {
      // Setup: storage has an anonymous session
      when(
        mockStorage.read(key: 'auth_token'),
      ).thenAnswer((_) async => 'fake_token');
      when(
        mockStorage.read(key: 'user_id'),
      ).thenAnswer((_) async => 'fake_uid');
      when(
        mockStorage.read(key: 'is_anonymous'),
      ).thenAnswer((_) async => 'true');

      final container = createContainer();

      // Trigger build
      container.read(authControllerProvider);

      await untilCalled(mockStorage.deleteAll());

      expect(
        container.read(authControllerProvider).status,
        AuthStatus.unauthenticated,
      );
      verify(mockStorage.deleteAll()).called(1);
    },
  );

  test('should restore authenticated session', () async {
    // Setup: storage has an authenticated session
    when(
      mockStorage.read(key: 'auth_token'),
    ).thenAnswer((_) async => 'fake_token');
    when(mockStorage.read(key: 'user_id')).thenAnswer((_) async => 'fake_uid');
    when(
      mockStorage.read(key: 'is_anonymous'),
    ).thenAnswer((_) async => 'false');

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
    verifyNever(mockStorage.deleteAll());
  });
}
