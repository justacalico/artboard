import 'dart:typed_data';

/// Wraps mono 16-bit PCM samples in a standard WAV container.
Uint8List encodeWav(Int16List samples, {int sampleRate = 22050}) {
  final dataSize = samples.length * 2;
  final buffer = ByteData(44 + dataSize);
  var offset = 0;

  void writeString(String s) {
    for (var i = 0; i < s.length; i++) {
      buffer.setUint8(offset++, s.codeUnitAt(i));
    }
  }

  void writeU32(int v) {
    buffer.setUint32(offset, v, Endian.little);
    offset += 4;
  }

  void writeU16(int v) {
    buffer.setUint16(offset, v, Endian.little);
    offset += 2;
  }

  writeString('RIFF');
  writeU32(36 + dataSize);
  writeString('WAVE');
  writeString('fmt ');
  writeU32(16);
  writeU16(1); // PCM
  writeU16(1); // mono
  writeU32(sampleRate);
  writeU32(sampleRate * 2); // byte rate
  writeU16(2); // block align
  writeU16(16); // bits per sample
  writeString('data');
  writeU32(dataSize);
  for (final s in samples) {
    buffer.setInt16(offset, s, Endian.little);
    offset += 2;
  }
  return buffer.buffer.asUint8List();
}
