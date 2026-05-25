import 'package:flutter_test/flutter_test.dart';
import 'package:offline_assistant/src/core/storage/message_cipher.dart';

void main() {
  test('message cipher encrypts and decrypts with random iv', () {
    final cipher = MessageCipher('abcdefghijklmnopqrstuvwxyz123456');
    final plain = 'sensitive local chat data';

    final encrypted1 = cipher.encrypt(plain);
    final encrypted2 = cipher.encrypt(plain);

    expect(encrypted1, isNot(equals(encrypted2)));
    expect(cipher.decrypt(encrypted1), plain);
    expect(cipher.decrypt(encrypted2), plain);
  });
}
