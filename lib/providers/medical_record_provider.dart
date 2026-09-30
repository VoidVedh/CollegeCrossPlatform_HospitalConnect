import 'package:flutter/foundation.dart';
import 'package:hospital_connect/core/errors/app_exceptions.dart';
import 'package:hospital_connect/core/utils/safe_notifier.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/services/repositories/repositories.dart';

/// State management provider for patient medical visit history.
class MedicalRecordProvider extends ChangeNotifier with SafeNotifier {
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
      final loaded = await _repository.getMedicalRecords();
      if (isDisposed) return;
      _records = List<MedicalRecordModel>.from(loaded);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('MedicalRecordProvider loadRecords error: $e');
      }
      _error = e is AppException
          ? e.userFriendlyMessage
          : 'Failed to load medical records. Please retry.';
    } finally {
      if (!isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  MedicalRecordModel? getRecordById(String id) {
    try {
      return _records.firstWhere((r) => r.id == id);
    } on StateError {
      return null;
    }
  }
}
