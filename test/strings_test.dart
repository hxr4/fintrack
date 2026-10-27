import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every user-facing string lives in the strings file', () {
    final offenders = <String>[];
    final literal = RegExp(r"Text\(\s*'([^']*)'");
    final interpolation = RegExp(r'\$\{[^}]*\}|\$[A-Za-z_]+');
    for (final file in Directory('lib/features').listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) {
        continue;
      }
      for (final match in literal.allMatches(file.readAsStringSync())) {
        if (RegExp('[A-Za-z]').hasMatch(match.group(1)!.replaceAll(interpolation, ''))) {
          offenders.add('${file.path}: ${match.group(0)}');
        }
      }
    }
    expect(offenders, isEmpty);
  });

  test('strings never discourage eating or shame spending', () {
    final text = File('lib/app/strings.dart').readAsStringSync().toLowerCase();
    const banned = [
      'stop eating',
      'eat less',
      'skip a meal',
      'skip meals',
      'too much food',
      'overeat',
      'junk',
      'waste',
      'wasted',
      'guilt',
      'shame',
      'careless',
      'irresponsible',
      'bad habit',
      'overspent',
      'splurge',
      'you failed',
      'warning',
    ];
    for (final phrase in banned) {
      expect(text.contains(phrase), isFalse, reason: phrase);
    }
  });
}
