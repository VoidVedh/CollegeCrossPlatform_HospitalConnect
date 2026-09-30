import 'package:flutter/foundation.dart';
import 'package:hospital_connect/core/errors/app_exceptions.dart';
import 'package:hospital_connect/core/utils/safe_notifier.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/services/repositories/repositories.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// State management provider for Doctor catalog, filtering, sorting, favorites, and slot availability.
class DoctorProvider extends ChangeNotifier with SafeNotifier {
  DoctorProvider(this._repository, {SharedPreferences? preferences})
      : _prefs = preferences {
    _loadFavorites();
    loadDoctors();
  }

  static const String _keyFavorites = 'favorite_doctors';

  final DoctorRepository _repository;
  SharedPreferences? _prefs;

  List<DoctorModel> _doctors = <DoctorModel>[];
  bool _isLoading = false;
  String? _error;
  String _selectedSpecialty = 'All';
  String _searchQuery = '';
  DoctorSortOption _sortOption = DoctorSortOption.rating;
  bool _showFavoritesOnly = false;
  final Set<String> _favoriteDoctorIds = <String>{};

  List<DoctorModel> get doctors => List.unmodifiable(_doctors);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedSpecialty => _selectedSpecialty;
  String get searchQuery => _searchQuery;
  DoctorSortOption get sortOption => _sortOption;
  bool get showFavoritesOnly => _showFavoritesOnly;
  Set<String> get favoriteDoctorIds => Set.unmodifiable(_favoriteDoctorIds);

  bool isFavorite(String doctorId) => _favoriteDoctorIds.contains(doctorId);

  Future<void> _loadFavorites() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final favList = _prefs?.getStringList(_keyFavorites);
      if (favList != null && !isDisposed) {
        _favoriteDoctorIds
          ..clear()
          ..addAll(favList);
        notifyListeners();
      }
    } catch (_) {
      // In isolated pure unit tests where ServicesBinding is uninitialized
    }
  }

  Future<void> toggleFavorite(String doctorId) async {
    if (_favoriteDoctorIds.contains(doctorId)) {
      _favoriteDoctorIds.remove(doctorId);
    } else {
      _favoriteDoctorIds.add(doctorId);
    }
    notifyListeners();

    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.setStringList(_keyFavorites, _favoriteDoctorIds.toList());
    } catch (_) {
      // In isolated pure unit tests where ServicesBinding is uninitialized
    }
  }

  void setSortOption(DoctorSortOption option) {
    if (_sortOption != option) {
      _sortOption = option;
      notifyListeners();
    }
  }

  void setShowFavoritesOnly(bool value) {
    if (_showFavoritesOnly != value) {
      _showFavoritesOnly = value;
      notifyListeners();
    }
  }

  /// Returns doctors filtered by current search query, specialty, favorites, and sort order.
  List<DoctorModel> get filteredDoctors {
    final query = _searchQuery.trim().toLowerCase();
    final list = _doctors.where((doctor) {
      final matchesQuery = query.isEmpty ||
          doctor.name.toLowerCase().contains(query) ||
          doctor.specialty.toLowerCase().contains(query) ||
          doctor.hospitalName.toLowerCase().contains(query);
      final matchesSpecialty = _selectedSpecialty == 'All' ||
          doctor.specialty.toLowerCase() == _selectedSpecialty.toLowerCase();
      final matchesFavorite =
          !_showFavoritesOnly || _favoriteDoctorIds.contains(doctor.id);
      return matchesQuery && matchesSpecialty && matchesFavorite;
    }).toList();

    switch (_sortOption) {
      case DoctorSortOption.rating:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case DoctorSortOption.feeLowToHigh:
        list.sort((a, b) => a.consultationFee.compareTo(b.consultationFee));
        break;
      case DoctorSortOption.feeHighToLow:
        list.sort((a, b) => b.consultationFee.compareTo(a.consultationFee));
        break;
      case DoctorSortOption.experience:
        list.sort((a, b) => b.experienceYears.compareTo(a.experienceYears));
        break;
    }
    return list;
  }

  /// Finds the earliest upcoming slot available for this doctor.
  DateTime? getNextAvailableSlot(DoctorModel doctor, [DateTime? now]) {
    final reference = now ?? DateTime.now();
    final upcoming = doctor.availableSlots
        .where((s) => s.isAfter(reference))
        .toList()
      ..sort();
    return upcoming.isNotEmpty ? upcoming.first : null;
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
