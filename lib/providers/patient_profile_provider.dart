import 'package:flutter/foundation.dart';
import 'package:hospital_connect/core/constants/app_strings.dart';
import 'package:hospital_connect/core/utils/safe_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider managing patient identity, onboarding flag, and contact info from a single source of truth.
class PatientProfileProvider extends ChangeNotifier with SafeNotifier {
  PatientProfileProvider({
    SharedPreferences? preferences,
    bool defaultOnboardingCompleted = false,
  })  : _prefs = preferences,
        _hasSeenOnboarding = defaultOnboardingCompleted {
    _loadFromPrefs();
  }

  static const String _keyName = 'patient_name';
  static const String _keyFullName = 'patient_full_name';
  static const String _keyAge = 'patient_age';
  static const String _keyPhone = 'patient_phone';
  static const String _keyOnboardingSeen = 'has_seen_onboarding';

  SharedPreferences? _prefs;

  String _name = AppStrings.defaultPatientName;
  String _fullName = AppStrings.defaultPatientFullName;
  int _age = 28;
  String _phone = '9876543210';
  bool _hasSeenOnboarding = false;

  String get name => _name;
  String get fullName => _fullName;
  int get age => _age;
  String get phone => _phone;
  bool get hasSeenOnboarding => _hasSeenOnboarding;

  String get initials {
    final parts = _fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return AppStrings.defaultPatientInitials;
  }

  Future<void> _loadFromPrefs() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      _name = _prefs?.getString(_keyName) ?? _name;
      _fullName = _prefs?.getString(_keyFullName) ?? _fullName;
      _age = _prefs?.getInt(_keyAge) ?? _age;
      _phone = _prefs?.getString(_keyPhone) ?? _phone;
      _hasSeenOnboarding = _prefs?.getBool(_keyOnboardingSeen) ?? _hasSeenOnboarding;
      notifyListeners();
    } catch (_) {
      // In isolated pure unit tests
    }
  }

  Future<void> updateProfile({
    String? name,
    String? fullName,
    int? age,
    String? phone,
  }) async {
    if (name != null) _name = name;
    if (fullName != null) {
      _fullName = fullName;
      _name = fullName.split(' ').first;
    }
    if (age != null) _age = age;
    if (phone != null) _phone = phone;

    notifyListeners();

    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.setString(_keyName, _name);
      await _prefs?.setString(_keyFullName, _fullName);
      await _prefs?.setInt(_keyAge, _age);
      await _prefs?.setString(_keyPhone, _phone);
    } catch (_) {
      // In isolated pure unit tests
    }
  }

  Future<void> completeOnboarding() async {
    _hasSeenOnboarding = true;
    notifyListeners();

    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.setBool(_keyOnboardingSeen, true);
    } catch (_) {
      // In isolated pure unit tests
    }
  }
}
