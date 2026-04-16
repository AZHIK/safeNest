import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../core/database/app_database.dart';
import '../core/utils/encryption_helper.dart';
import '../core/providers/database_provider.dart';

final messagingServiceProvider = Provider<MessagingService>((ref) {
  return MessagingService(ref.watch(dbProvider), EncryptionHelperImpl());
});

class MessagingService {
  final AppDatabase _db;
  final EncryptionHelper _encryption;

  // Placeholder key for POC. In production, securely derive/store via KeyStore/Keychain.
  static const _encryptionKey = 'user_secure_key_123';

  MessagingService(this._db, this._encryption);

  Future<void> sendMessage(String text) async {
    final encrypted = await _encryption.encrypt(text, _encryptionKey);
    await _db
        .into(_db.messages)
        .insert(
          MessagesCompanion.insert(
            encryptedPayload: encrypted,
            timestamp: DateTime.now(),
            isSent: const drift.Value(true),
          ),
        );
  }

  Stream<List<MessageEntry>> watchMessages() {
    return _db.select(_db.messages).watch();
  }

  Future<String> decryptMessage(String encryptedPayload) async {
    return await _encryption.decrypt(encryptedPayload, _encryptionKey);
  }
}
