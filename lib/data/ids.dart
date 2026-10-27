import 'dart:math';

final class IdGenerator {
  IdGenerator({Random? random}) : _random = random ?? Random.secure();

  final Random _random;
  var _counter = 0;

  String next(String prefix) {
    _counter = (_counter + 1) % 1000000;
    final time = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final noise = _random.nextInt(1 << 30).toRadixString(36);
    return '$prefix-$time-${_counter.toRadixString(36)}-$noise';
  }
}
