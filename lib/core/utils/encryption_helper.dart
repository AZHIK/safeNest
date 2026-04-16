abstract class EncryptionHelper {
  Future<String> encrypt(String data, String key);
  Future<String> decrypt(String encryptedData, String key);
}

class EncryptionHelperImpl implements EncryptionHelper {
  @override
  Future<String> encrypt(String data, String key) async {
    // Placeholder encryption
    return 'encrypted_$data';
  }

  @override
  Future<String> decrypt(String encryptedData, String key) async {
    // Placeholder decryption
    return encryptedData.replaceAll('encrypted_', '');
  }
}
