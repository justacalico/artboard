import 'package:artboard/src/drawing/drawing_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('load returns null before anything is saved', () async {
    SharedPreferences.setMockInitialValues({});
    expect(await DrawingStore().load(), isNull);
  });

  test('save then load round trips the payload', () async {
    SharedPreferences.setMockInitialValues({});
    final store = DrawingStore();
    await store.save('{"layers":[]}');
    expect(await store.load(), '{"layers":[]}');
  });
}
