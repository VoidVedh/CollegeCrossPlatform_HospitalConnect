/// Injectable Clock interface and implementations for deterministic time handling.
library;

/// Abstract clock interface providing the current [DateTime].
abstract interface class Clock {
  DateTime now();
}

/// Production implementation that delegates to the system clock via [DateTime.now].
class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}

/// Controllable clock implementation for unit and widget testing.
class FakeClock implements Clock {
  FakeClock([DateTime? initialTime]) : _now = initialTime ?? DateTime.now();

  DateTime _now;

  @override
  DateTime now() => _now;

  /// Sets the clock to an exact [time].
  void setTime(DateTime time) {
    _now = time;
  }

  /// Advances the clock forward by [duration].
  void advance(Duration duration) {
    _now = _now.add(duration);
  }

  /// Rewinds the clock backward by [duration].
  void rewind(Duration duration) {
    _now = _now.subtract(duration);
  }
}
