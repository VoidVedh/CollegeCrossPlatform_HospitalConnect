import 'package:flutter/foundation.dart';
import 'package:hospital_connect/core/errors/app_exceptions.dart';
import 'package:hospital_connect/core/utils/safe_notifier.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/services/repositories/repositories.dart';

/// State management provider for Doctor catalog, filtering, and slot availability.
class DoctorProvider extends ChangeNotifier with SafeNotifier {
  DoctorProvider(this._repository) {
    loadDoctors();
  }

  final DoctorRepository _repository;

  List<DoctorModel> _doctors = <DoctorModel>[];
  bool _isLoading = false;
  String? _error;
  String _selectedSpecialty = 'All';
  String _searchQuery = '';

  List<DoctorModel> get doctors => List.unmodifiable(_doctors);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedSpecialty => _selectedSpecialty;
  String get searchQuery => _searchQuery;

  /// Returns doctors filtered by current search query and selected specialty.
  List<DoctorModel> get filteredDoctors {
    final query = _searchQuery.trim().toLowerCase();
    return _doctors.where((doctor) {
      final matchesQuery = query.isEmpty ||
          doctor.name.toLowerCase().contains(query) ||
          doctor.specialty.toLowerCase().contains(query) ||
          doctor.hospitalName.toLowerCase().contains(query);
      final matchesSpecialty = _selectedSpecialty == 'All' ||
          doctor.specialty.toLowerCase() == _selectedSpecialty.toLowerCase();
      return matchesQuery && matchesSpecialty;
    }).toList();
  }

  /// Returns up to 5 highest-rated doctors sorted descending by rating.
  List<DoctorModel> get topRatedDoctors {
    final sorted = List<DoctorModel>.from(_doctors)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(5).toList();
  }

  Future<void> loadDoctors() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final loaded = await _repository.getDoctors();
      if (isDisposed) return;
      _doctors = loaded;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DoctorProvider loadDoctors error: $e');
      }
      _error = e is AppException
          ? e.userFriendlyMessage
          : 'Failed to load doctors list. Please check your connection and retry.';
    } finally {
      if (!isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void setSpecialty(String specialty) {
    if (_selectedSpecialty != specialty) {
      _selectedSpecialty = specialty;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  DoctorModel? getDoctorById(String id) {
    try {
      return _doctors.firstWhere((d) => d.id == id);
    } on StateError {
      return null;
    }
  }

  /// Removes booked slot from doctor availability.
  Future<void> markSlotUnavailable(String doctorId, DateTime slot) async {
    await _repository.markSlotAvailability(
      doctorId: doctorId,
      slot: slot,
      isAvailable: false,
    );
    if (isDisposed) return;
    final index = _doctors.indexWhere((d) => d.id == doctorId);
    if (index != -1) {
      final updatedSlots = List<DateTime>.from(_doctors[index].availableSlots)
        ..removeWhere((s) => s.isAtSameMomentAs(slot));
      _doctors[index] = _doctors[index].copyWith(availableSlots: updatedSlots);
      notifyListeners();
    }
  }

  /// Frees a previously booked slot back into doctor availability upon cancellation.
  Future<void> markSlotAvailable(String doctorId, DateTime slot) async {
    await _repository.markSlotAvailability(
      doctorId: doctorId,
      slot: slot,
      isAvailable: true,
    );
    if (isDisposed) return;
    final index = _doctors.indexWhere((d) => d.id == doctorId);
    if (index != -1) {
      final updatedSlots = List<DateTime>.from(_doctors[index].availableSlots);
      if (!updatedSlots.any((s) => s.isAtSameMomentAs(slot))) {
        updatedSlots.add(slot);
        updatedSlots.sort();
      }
      _doctors[index] = _doctors[index].copyWith(availableSlots: updatedSlots);
      notifyListeners();
    }
  }
}
