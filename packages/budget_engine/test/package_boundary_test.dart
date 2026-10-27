import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('engine sources never import Flutter', () {
    final sources = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));
    for (final source in sources) {
      final text = source.readAsStringSync();
      expect(text.contains('package:flutter'), isFalse, reason: source.path);
      expect(text.contains('dart:ui'), isFalse, reason: source.path);
    }
  });
}
