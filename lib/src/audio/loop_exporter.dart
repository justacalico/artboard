import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';

/// Platform boundary for handing a finished file to the user.
// coverage:ignore-start
class LoopExporter {
  Future<void> save(Uint8List wav) {
    return FileSaver.instance.saveFile(
      name: 'artboard-loop',
      bytes: wav,
      fileExtension: 'wav',
      mimeType: MimeType.custom,
      customMimeType: 'audio/wav',
    );
  }
}
// coverage:ignore-end
