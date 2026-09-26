import 'package:flutter/foundation.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/services/repositories/repositories.dart';

/// State management provider for patient prescriptions.
class PrescriptionProvider extends ChangeNotifier {
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
      _prescriptions = List<PrescriptionModel>.from(
        await _repository.getPrescriptions(),
      );
    } catch (e) {
      _error = 'Failed to load prescriptions: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  PrescriptionModel? getPrescriptionById(String id) {
    try {
      return _prescriptions.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
