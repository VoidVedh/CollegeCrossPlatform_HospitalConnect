import 'package:flutter/foundation.dart';
import 'package:hospital_connect/core/errors/app_exceptions.dart';
import 'package:hospital_connect/core/utils/safe_notifier.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/services/repositories/repositories.dart';

/// State management provider for patient prescriptions.
class PrescriptionProvider extends ChangeNotifier with SafeNotifier {
  PrescriptionProvider(this._repository) {
    loadPrescriptions();
  }

  final PrescriptionRepository _repository;

  List<PrescriptionModel> _prescriptions = <PrescriptionModel>[];
  bool _isLoading = false;
  String? _error;

  List<PrescriptionModel> get prescriptions =>
      List.unmodifiable(_prescriptions);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPrescriptions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final loaded = await _repository.getPrescriptions();
      if (isDisposed) return;
      _prescriptions = List<PrescriptionModel>.from(loaded);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('PrescriptionProvider loadPrescriptions error: $e');
      }
      _error = e is AppException
          ? e.userFriendlyMessage
          : 'Failed to load prescriptions. Please retry.';
    } finally {
      if (!isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  PrescriptionModel? getPrescriptionById(String id) {
    try {
      return _prescriptions.firstWhere((p) => p.id == id);
    } on StateError {
      return null;
    }
  }
}
