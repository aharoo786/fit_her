import 'dart:io';
import 'dart:math';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Device-only photo helper. Per Section 10 of the architecture doc:
/// progress + meal photos are NEVER uploaded to the server. They live
/// inside the app's documents directory and disappear when the user
/// uninstalls.
///
/// Pipeline:
///   1. ImagePicker → temp file
///   2. flutter_image_compress → 1024-wide JPEG @ 80% quality
///   3. Move into <docs>/photos/<bucket>/ with a UUID-ish filename
///   4. Return the absolute local path. Caller persists the path in its
///      own storage (e.g. an in-app SQLite/SharedPreferences index)
///
/// Buckets keep meal photos and progress photos in separate directories
/// so cleanup logic (delete-when-cycle-ends) can target one without
/// touching the other.
class DeviceOnlyPhotoPicker {
  DeviceOnlyPhotoPicker._();

  static const int _maxWidth = 1024;
  static const int _quality = 80;

  /// Pick from gallery (default) or camera. Returns the local path of
  /// the compressed copy stored in app docs, or null if the user
  /// cancelled / picker failed.
  static Future<String?> pickAndStore({
    required String bucket, // "progress" | "meal" | etc.
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 95, // light first-pass; flutter_image_compress is the
                          // real compressor — we let the picker decode at
                          // near-original quality so the second pass has
                          // good data to work with.
      );
      if (picked == null) return null;

      final destPath = await _allocatePath(bucket);
      final compressed = await FlutterImageCompress.compressAndGetFile(
        picked.path,
        destPath,
        quality: _quality,
        minWidth: _maxWidth,
        format: CompressFormat.jpeg,
      );
      if (compressed == null) {
        // Compression failed — fall back to direct copy so the user
        // doesn't lose their photo to a tooling hiccup.
        await File(picked.path).copy(destPath);
      }
      return destPath;
    } catch (e) {
      // Picker errors (permission denied, no camera, etc.) shouldn't
      // crash the screen. Caller's null check shows an error toast.
      // ignore: avoid_print
      print('[DeviceOnlyPhotoPicker] pick failed: $e');
      return null;
    }
  }

  /// List every photo stored in a bucket, ordered newest-first by
  /// filename (filename includes timestamp).
  static Future<List<String>> listBucket(String bucket) async {
    try {
      final dir = await _bucketDir(bucket);
      if (!await dir.exists()) return const [];
      final files = await dir
          .list()
          .where((e) => e is File && e.path.endsWith('.jpg'))
          .toList();
      files.sort((a, b) => b.path.compareTo(a.path)); // descending
      return files.map((f) => f.path).toList();
    } catch (e) {
      // ignore: avoid_print
      print('[DeviceOnlyPhotoPicker] list failed: $e');
      return const [];
    }
  }

  /// Permanently delete a single photo. Returns true on success.
  static Future<bool> delete(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      // ignore: avoid_print
      print('[DeviceOnlyPhotoPicker] delete failed: $e');
      return false;
    }
  }

  /// Allocate a unique destination path inside <docs>/photos/<bucket>/.
  /// Filename pattern: {timestamp}-{random6}.jpg so an ls is naturally
  /// time-sorted and uniqueness is guaranteed even on parallel pickers.
  static Future<String> _allocatePath(String bucket) async {
    final dir = await _bucketDir(bucket);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final ts = DateTime.now().millisecondsSinceEpoch;
    final r = (Random().nextInt(1 << 30)).toRadixString(36).padLeft(6, '0');
    return '${dir.path}${Platform.pathSeparator}$ts-$r.jpg';
  }

  static Future<Directory> _bucketDir(String bucket) async {
    final docs = await getApplicationDocumentsDirectory();
    final safeBucket = bucket.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '');
    return Directory(
      '${docs.path}${Platform.pathSeparator}photos${Platform.pathSeparator}$safeBucket',
    );
  }
}
