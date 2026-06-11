import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

/// Generates and encodes Ed25519 SSH key pairs.
class SshKeyService {
  /// Generates a new Ed25519 key pair and returns the private key in PEM
  /// format and the public key in OpenSSH authorized_keys format.
  static Future<({String privateKeyPem, String publicKeyOpenSsh})>
      generateKeyPair({String comment = 'double_entry'}) async {
    final algorithm = Ed25519();
    final keyPair = await algorithm.newKeyPair();

    final privateKeyBytes =
        await keyPair.extractPrivateKeyBytes();
    final publicKey = await keyPair.extractPublicKey();
    final publicKeyBytes = publicKey.bytes;

    final privateKeyPem = _encodePrivateKeyPem(
        Uint8List.fromList(privateKeyBytes),
        Uint8List.fromList(publicKeyBytes));
    final publicKeyOpenSsh =
        _encodePublicKeyOpenSsh(Uint8List.fromList(publicKeyBytes), comment);

    return (
      privateKeyPem: privateKeyPem,
      publicKeyOpenSsh: publicKeyOpenSsh,
    );
  }

  // ─────────────────────────────────────────────
  // Encoding helpers
  // ─────────────────────────────────────────────

  /// Encodes an Ed25519 private key in OpenSSH PEM format.
  /// Format: "-----BEGIN OPENSSH PRIVATE KEY-----\n...\n-----END OPENSSH PRIVATE KEY-----"
  static String _encodePrivateKeyPem(
      Uint8List privateKeyBytes, Uint8List publicKeyBytes) {
    // OpenSSH private key format (RFC 4716 / openssh-key-v1)
    final writer = _SshWriter();

    // Header
    writer.writeBytes(
        Uint8List.fromList('openssh-key-v1\x00'.codeUnits));

    // cipher, kdf, kdf options, number of keys
    writer.writeString('none');   // cipher
    writer.writeString('none');   // kdf
    writer.writeString('');       // kdf options
    writer.writeUint32(1);        // number of keys

    // Public key blob
    final pubBlob = _encodePublicKeyBlob(publicKeyBytes);
    writer.writeBytes32(pubBlob);

    // Private key blob (check bytes + private + public + comment)
    final checkInt = 0x12345678; // arbitrary check bytes
    final privWriter = _SshWriter();
    privWriter.writeUint32(checkInt);
    privWriter.writeUint32(checkInt);
    privWriter.writeString('ssh-ed25519');
    privWriter.writeBytes32(publicKeyBytes);
    // Ed25519 private key is 64 bytes: 32 seed + 32 public key
    final fullPrivate = Uint8List(64);
    fullPrivate.setAll(0, privateKeyBytes);
    fullPrivate.setAll(32, publicKeyBytes);
    privWriter.writeBytes32(fullPrivate);
    privWriter.writeString('double_entry'); // comment
    // Padding
    int pad = 1;
    while (privWriter.length % 8 != 0) {
      privWriter.writeByte(pad++);
    }
    writer.writeBytes32(privWriter.toBytes());

    final encoded = _base64Encode(writer.toBytes());
    final lines = <String>['-----BEGIN OPENSSH PRIVATE KEY-----'];
    for (int i = 0; i < encoded.length; i += 70) {
      lines.add(encoded.substring(
          i, i + 70 > encoded.length ? encoded.length : i + 70));
    }
    lines.add('-----END OPENSSH PRIVATE KEY-----');
    return lines.join('\n');
  }

  /// Encodes an Ed25519 public key in OpenSSH authorized_keys format.
  /// e.g. "ssh-ed25519 AAAA... comment"
  static String _encodePublicKeyOpenSsh(
      Uint8List publicKeyBytes, String comment) {
    final blob = _encodePublicKeyBlob(publicKeyBytes);
    final encoded = _base64Encode(blob);
    return 'ssh-ed25519 $encoded $comment';
  }

  static Uint8List _encodePublicKeyBlob(Uint8List publicKeyBytes) {
    final writer = _SshWriter();
    writer.writeString('ssh-ed25519');
    writer.writeBytes32(publicKeyBytes);
    return writer.toBytes();
  }

  static String _base64Encode(Uint8List bytes) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    final result = StringBuffer();
    for (int i = 0; i < bytes.length; i += 3) {
      final b0 = bytes[i];
      final b1 = i + 1 < bytes.length ? bytes[i + 1] : 0;
      final b2 = i + 2 < bytes.length ? bytes[i + 2] : 0;
      result.write(chars[(b0 >> 2) & 0x3F]);
      result.write(chars[((b0 << 4) | (b1 >> 4)) & 0x3F]);
      result.write(i + 1 < bytes.length ? chars[((b1 << 2) | (b2 >> 6)) & 0x3F] : '=');
      result.write(i + 2 < bytes.length ? chars[b2 & 0x3F] : '=');
    }
    return result.toString();
  }
}

/// Minimal SSH binary writer.
class _SshWriter {
  final _buf = <int>[];

  int get length => _buf.length;

  void writeByte(int b) => _buf.add(b & 0xFF);

  void writeUint32(int v) {
    _buf.add((v >> 24) & 0xFF);
    _buf.add((v >> 16) & 0xFF);
    _buf.add((v >> 8) & 0xFF);
    _buf.add(v & 0xFF);
  }

  void writeBytes(Uint8List b) => _buf.addAll(b);

  /// Writes a length-prefixed byte array (uint32 length + bytes).
  void writeBytes32(Uint8List b) {
    writeUint32(b.length);
    _buf.addAll(b);
  }

  /// Writes a length-prefixed UTF-8 string.
  void writeString(String s) {
    final bytes = Uint8List.fromList(s.codeUnits);
    writeBytes32(bytes);
  }

  Uint8List toBytes() => Uint8List.fromList(_buf);
}
