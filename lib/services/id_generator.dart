import 'dart:math';

/// Generates locally-unique ids from the current timestamp plus a random
/// suffix. Sufficient for a single-device offline store; not a UUID.
class IdGenerator {
  IdGenerator({Random? random}) : _random = random ?? Random();

  final Random _random;

  String next() =>
      '${DateTime.now().millisecondsSinceEpoch}${_random.nextInt(100000)}';
}
