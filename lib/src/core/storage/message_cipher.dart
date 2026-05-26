import 'package:encrypt/encrypt.dart';

class MessageCipher {
  MessageCipher(String secret)
      : _encrypter = Encrypter(
          AES(
            Key.fromUtf8(secret.substring(0, 32)),
            mode: AESMode.cbc,
          ),
        );

  final Encrypter _encrypter;

  String encrypt(String plainText) {
    final iv = IV.fromSecureRandom(16);
    final encrypted = _encrypter.encrypt(plainText, iv: iv);
    return '${iv.base64}:${encrypted.base64}';
  }

  String decrypt(String encryptedText) {
    final parts = encryptedText.split(':');
    if (parts.length != 2) {
      throw const FormatException('Invalid encrypted message format');
    }
    final iv = IV.fromBase64(parts[0]);
    final decrypted = _encrypter.decrypt(Encrypted.fromBase64(parts[1]), iv: iv);
    return decrypted;
  }
}
