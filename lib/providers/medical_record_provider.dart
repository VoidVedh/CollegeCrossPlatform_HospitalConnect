import 'package:flutter/foundation.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/services/repositories/repositories.dart';

/// State management provider for patient medical visit history.
class MedicalRecordProvider extends ChangeNotifier {
  MedicalRecordProvider(this._repository) {
    loadRecords();
  }

  final MedicalRecordRepository _repository;

  List<MedicalRecordModel> _records = <MedicalRecordModel>[];
  bool _isLoading = false;
  String? _error;

  List<MedicalRecordModel> get records => List.unmodifiable(_records);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadRecords() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _records = await _repository.getMedicalRecords();
    } catch (e) {
      _error = 'Failed to load medical records: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  MedicalRecordModel? getRecordById(String id) {
    try {
      return _records.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }
}
