// Cross-platform download helper: chooses IO or Web implementation via conditional import
import 'download_helper_stub.dart'
    if (dart.library.io) 'download_helper_io.dart'
    if (dart.library.html) 'download_helper_web.dart';

abstract class DownloadHelper {
  /// Saves/opens bytes with a filename in a platform-appropriate way.
  /// Returns a resolved file path on IO platforms, and null on Web.
  static Future<String?> saveBytes({
    required List<int> bytes,
    required String fileName,
  }) => saveBytesImpl(bytes: bytes, fileName: fileName);
}
