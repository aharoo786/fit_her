// AES helper matching ZINDIGI's "Encryption And WebView JavaScript
// Interface Documentation" (partner integration spec) exactly:
//   - AES-256, CBC mode, PKCS7 padding
//   - Key + IV both derived from ONE shared secret via SHA-256:
//       32-char key = first 32 hex chars of sha256(secret)
//       16-char IV  = first 16 hex chars of sha256(secret)
//   - Payload is Base64
//
// This is REAL, spec-correct logic — not a stub. Only the shared secret
// itself is a placeholder (see ZindigiCrypto.mockSharedSecret) until
// Zindigi hands over the real one during onboarding.
//
// Needs the `encrypt` package (wraps AES/PointyCastle) — add to
// pubspec.yaml dependencies:
//   encrypt: ^5.0.3
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt_pkg;

class ZindigiCrypto {
  ZindigiCrypto._();

  /// PLACEHOLDER ONLY. Real value comes from Zindigi during partner
  /// onboarding — do not ship this to production. Kept here so the
  /// entry-screen mock is runnable/demoable before that credential
  /// exists.
  static const String mockSharedSecret = 'MOCK_SHARED_SECRET_REPLACE_ME';

  /// Derives the 32-character (32-byte, once UTF-8 encoded) AES-256 key
  /// from any shared secret string, per the doc's `to32CharacterKey`.
  static String to32CharacterKey(String input) {
    final digest = sha256.convert(utf8.encode(input));
    return digest.toString().substring(0, 32);
  }

  /// Derives the 16-character (16-byte) IV from any shared secret
  /// string, per the doc's `to16CharacterIV`.
  static String to16CharacterIV(String input) {
    final digest = sha256.convert(utf8.encode(input));
    return digest.toString().substring(0, 16);
  }

  /// Decrypts a Base64 AES-256/CBC/PKCS7 payload using ONE shared
  /// secret (matches the doc's `decryptAES(encryptedText, keyText)`
  /// two-argument contract — key and IV both come from the same
  /// secret, unlike the Web-3 sample code, which hardcoded a separate
  /// literal IV as a testing shortcut).
  static String decrypt(String encryptedBase64, String sharedSecret) {
    final keyHex = to32CharacterKey(sharedSecret);
    final ivHex = to16CharacterIV(sharedSecret);

    final key = encrypt_pkg.Key.fromUtf8(keyHex);
    final iv = encrypt_pkg.IV.fromUtf8(ivHex);
    final encrypter = encrypt_pkg.Encrypter(
      encrypt_pkg.AES(key, mode: encrypt_pkg.AESMode.cbc),
    );

    return encrypter.decrypt64(encryptedBase64, iv: iv);
  }

  /// Encrypts plain text the same way — needed if FitHer's webpage
  /// ever has to send an encrypted payload back (not just receive
  /// one), e.g. building the URL Zindigi's app should open next.
  static String encryptText(String text, String sharedSecret) {
    final keyHex = to32CharacterKey(sharedSecret);
    final ivHex = to16CharacterIV(sharedSecret);

    final key = encrypt_pkg.Key.fromUtf8(keyHex);
    final iv = encrypt_pkg.IV.fromUtf8(ivHex);
    final encrypter = encrypt_pkg.Encrypter(
      encrypt_pkg.AES(key, mode: encrypt_pkg.AESMode.cbc),
    );

    return encrypter.encrypt(text, iv: iv).base64;
  }

  /// Parses the decrypted "cnic=...&email=...&name=...&mobile=..."
  /// query-string-style payload into a map — matches the doc's Sample
  /// Payload format exactly.
  static Map<String, String> parseFieldPayload(String decrypted) {
    final result = <String, String>{};
    for (final pair in decrypted.split('&')) {
      final idx = pair.indexOf('=');
      if (idx == -1) continue;
      result[pair.substring(0, idx)] = pair.substring(idx + 1);
    }
    return result;
  }
}
