import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

abstract class EncryptionHelper {
  Future<Map<String, dynamic>> encrypt(String data);
  Future<String> decrypt(String encryptedData, Map<String, dynamic> metadata);
  Future<Map<String, dynamic>> encryptBytes(Uint8List bytes);
  Future<Uint8List> decryptBytes(Uint8List encryptedBytes, Map<String, dynamic> metadata);
}

class EncryptionHelperImpl implements EncryptionHelper {
  final _algorithm = AesGcm.with256bits();
  
  // Master Key Encryption Key (KEK) - In production, this should be in secure storage
  static const String _masterKek = 'default-kek-change-in-production';

  @override
  Future<Map<String, dynamic>> encrypt(String data) async {
    final bytes = Uint8List.fromList(utf8.encode(data));
    return await encryptBytes(bytes);
  }

  @override
  Future<String> decrypt(String encryptedData, Map<String, dynamic> metadata) async {
    final encryptedBytes = base64.decode(encryptedData);
    final decryptedBytes = await decryptBytes(encryptedBytes, metadata);
    return utf8.decode(decryptedBytes);
  }

  @override
  Future<Map<String, dynamic>> encryptBytes(Uint8List bytes) async {
    // 1. Generate a random Data Encryption Key (DEK)
    final dek = await _algorithm.newSecretKey();
    final dekBytes = await dek.extractBytes();

    // 2. Encrypt the data with the DEK
    final secretBox = await _algorithm.encrypt(
      bytes,
      secretKey: dek,
    );

    // 3. Encrypt (Wrap) the DEK with the Master KEK
    // For simplicity in this POC, we'll use AES-CBC or similar for the DEK wrapping
    // as seen in the admin dashboard's current CryptoJS implementation.
    // However, since we want GCM for the data, let's use a simple scheme for DEK.
    final kek = await _algorithm.newSecretKeyFromBytes(
      Uint8List.fromList(utf8.encode(_masterKek.padRight(32, ' ').substring(0, 32)))
    );
    
    final wrappedDekBox = await _algorithm.encrypt(
      dekBytes,
      secretKey: kek,
    );

    return {
      'encrypted_data': base64.encode(secretBox.concatenation()),
      'metadata': {
        'algorithm': 'AES-256-GCM',
        'encrypted_key': base64.encode(wrappedDekBox.concatenation()),
        'iv': base64.encode(secretBox.nonce),
        'key_iv': base64.encode(wrappedDekBox.nonce),
      }
    };
  }

  @override
  Future<Uint8List> decryptBytes(Uint8List encryptedBytes, Map<String, dynamic> metadata) async {
    final encryptedKey = base64.decode(metadata['encrypted_key']);
    final iv = base64.decode(metadata['iv']);
    final keyIv = base64.decode(metadata['key_iv']);

    // 1. Unwrapped the DEK using Master KEK
    final kek = await _algorithm.newSecretKeyFromBytes(
      Uint8List.fromList(utf8.encode(_masterKek.padRight(32, ' ').substring(0, 32)))
    );

    final wrappedDekBox = SecretBox(
      encryptedKey.sublist(0, encryptedKey.length - 16),
      nonce: keyIv,
      mac: Mac(encryptedKey.sublist(encryptedKey.length - 16)),
    );

    final dekBytes = await _algorithm.decrypt(
      wrappedDekBox,
      secretKey: kek,
    );
    
    final dek = await _algorithm.newSecretKeyFromBytes(Uint8List.fromList(dekBytes));

    // 2. Decrypt data with the DEK
    final secretBox = SecretBox(
      encryptedBytes.sublist(0, encryptedBytes.length - 16),
      nonce: iv,
      mac: Mac(encryptedBytes.sublist(encryptedBytes.length - 16)),
    );

    final decryptedBytes = await _algorithm.decrypt(
      secretBox,
      secretKey: dek,
    );

    return Uint8List.fromList(decryptedBytes);
  }
}
