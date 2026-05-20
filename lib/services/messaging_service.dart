import 'dart:convert';
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

  MessagingService(this._db, this._encryption);

  Future<void> sendMessage(String text) async {
    final encrypted = await _encryption.encrypt(text);
    final encryptedString = jsonEncode(encrypted);
    await _db
        .into(_db.messages)
        .insert(
          MessagesCompanion.insert(
            encryptedPayload: encryptedString,
            timestamp: DateTime.now(),
            isSent: const drift.Value(true),
          ),
        );
  }

  Stream<List<MessageEntry>> watchMessages() {
    return _db.select(_db.messages).watch();
  }

  Future<String> decryptMessage(String encryptedPayload) async {
    final Map<String, dynamic> encrypted = jsonDecode(encryptedPayload) as Map<String, dynamic>;
    final String encryptedData = encrypted['encrypted_data'] as String;
    final Map<String, dynamic> metadata = encrypted['metadata'] as Map<String, dynamic>;
    return await _encryption.decrypt(encryptedData, metadata);
  }
}
