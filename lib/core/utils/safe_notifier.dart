import 'package:flutter/foundation.dart';

/// Mixin for [ChangeNotifier] instances to safely prevent calling
/// [notifyListeners] after the notifier has been disposed.
mixin SafeNotifier on ChangeNotifier {
  bool _isDisposed = false;

  /// Whether this notifier instance has been disposed.
  bool get isDisposed => _isDisposed;

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
