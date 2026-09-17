import 'dart:typed_data';

import 'package:artboard/src/audio/wav_encoder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('writes a valid RIFF header', () {
    final wav = encodeWav(Int16List.fromList([0, 100, -100]), sampleRate: 8000);
    expect(String.fromCharCodes(wav.sublist(0, 4)), 'RIFF');
    expect(String.fromCharCodes(wav.sublist(8, 12)), 'WAVE');
    expect(String.fromCharCodes(wav.sublist(12, 16)), 'fmt ');
    expect(String.fromCharCodes(wav.sublist(36, 40)), 'data');
  });

  test('header fields describe the payload', () {
    final samples = Int16List(100);
    final wav = encodeWav(samples, sampleRate: 8000);
    final data = ByteData.view(wav.buffer);
    expect(wav.length, 44 + 200);
    expect(data.getUint32(4, Endian.little), 36 + 200);
    expect(data.getUint32(24, Endian.little), 8000);
    expect(data.getUint16(22, Endian.little), 1);
    expect(data.getUint16(34, Endian.little), 16);
    expect(data.getUint32(40, Endian.little), 200);
  });

  test('samples land little-endian after the header', () {
    final wav = encodeWav(Int16List.fromList([256, -2]), sampleRate: 8000);
    final data = ByteData.view(wav.buffer);
    expect(data.getInt16(44, Endian.little), 256);
    expect(data.getInt16(46, Endian.little), -2);
  });
}
