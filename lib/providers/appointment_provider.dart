import 'package:flutter/foundation.dart';
import 'package:hospital_connect/core/errors/app_exceptions.dart';
import 'package:hospital_connect/core/utils/bill_calculator.dart';
import 'package:hospital_connect/core/utils/formatters.dart';
import 'package:hospital_connect/core/utils/safe_notifier.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/providers/bill_provider.dart';
import 'package:hospital_connect/services/repositories/repositories.dart';
import 'package:uuid/uuid.dart';

/// State management provider for patient appointments and bookings.
class AppointmentProvider extends ChangeNotifier with SafeNotifier {
  AppointmentProvider(
    AppointmentRepository repository, {
    required this.doctorRepository,
    required this.billRepository,
  }) : _repository = repository {
    loadAppointments();
  }

  final AppointmentRepository _repository;
  final DoctorRepository doctorRepository;
  final BillRepository billRepository;
  static const Uuid _uuid = Uuid();

  List<AppointmentModel> _appointments = <AppointmentModel>[];
  bool _isLoading = false;
  bool _isBooking = false;
  bool _isCancelling = false;
  String? _error;

  List<AppointmentModel> get appointments => List.unmodifiable(_appointments);
  bool get isLoading => _isLoading;
  bool get isBooking => _isBooking;
  bool get isCancelling => _isCancelling;
  String? get error => _error;

  List<AppointmentModel> get upcomingAppointments => _appointments
      .where((a) => a.status == AppointmentStatus.upcoming)
      .toList();

  List<AppointmentModel> get pastAppointments => _appointments
      .where((a) =>
          a.status == AppointmentStatus.completed ||
          a.status == AppointmentStatus.cancelled)
      .toList();

  /// Highlights the immediate next upcoming appointment for dashboard card.
  AppointmentModel? get nextUpcomingAppointment {
    final upcoming = upcomingAppointments;
    if (upcoming.isEmpty) return null;
    final sorted = List<AppointmentModel>.from(upcoming)
      ..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
    return sorted.first;
  }

  /// Retrieves a specific appointment by its ID, or null if not found.
  AppointmentModel? getAppointmentById(String id) {
    try {
      return _appointments.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Collision-safe appointment ID generator.
  static String generateUniqueAppointmentId(Iterable<String> existingIds) {
    final existingSet = existingIds.toSet();
    for (int attempt = 0; attempt < 50; attempt++) {
      final randomSuffix = _uuid.v4().substring(0, 6).toUpperCase();
      final id = 'APT-$randomSuffix';
      if (!existingSet.contains(id)) return id;
    }
    return 'APT-${DateTime.now().microsecondsSinceEpoch.toRadixString(36).toUpperCase()}';
  }

  Future<void> loadAppointments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final loaded = await _repository.getAppointments();
      if (isDisposed) return;
      _appointments = List<AppointmentModel>.from(loaded);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AppointmentProvider loadAppointments error: $e');
      }
      _error = e is AppException
          ? e.userFriendlyMessage
          : 'Failed to load appointments list. Please retry.';
    } finally {
      if (!isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  /// Books an appointment atomically with rollback, double-booking guard, and billing integration.
  Future<AppointmentModel> bookAppointment({
    required String doctorId,
    required String doctorName,
    required String doctorSpecialty,
    required String patientName,
    required int patientAge,
    required String patientPhone,
    required DateTime appointmentDate,
    required String timeSlot,
    required String symptomsNote,
    double consultationFee = 500.0,
    DateTime? currentTime,
  }) async {
    final now = currentTime ?? DateTime.now();
    final slotDateTime = AppFormatters.tryParseTimeSlot(appointmentDate, timeSlot);
    if (slotDateTime == null) {
      throw ValidationException('Invalid time slot format: "$timeSlot"');
    }

    // Guard 1: Slot in the past
    if (slotDateTime.isBefore(now)) {
      throw const PastSlotBookingException();
    }

    // Guard 2: Double-booking guard
    final isAlreadyBooked = _appointments.any((a) =>
        a.doctorId == doctorId &&
        a.status == AppointmentStatus.upcoming &&
        a.appointmentDate.year == appointmentDate.year &&
        a.appointmentDate.month == appointmentDate.month &&
        a.appointmentDate.day == appointmentDate.day &&
        a.timeSlot.trim().toLowerCase() == timeSlot.trim().toLowerCase());

    if (isAlreadyBooked) {
      throw const SlotUnavailableException(
        'This doctor is already booked for the selected slot. Please select another time.',
      );
    }

    _isBooking = true;
    _error = null;
    notifyListeners();

    AppointmentModel? bookedAppointment;
    bool slotMarked = false;
    BillModel? createdBill;

    try {
      // Step 1: Mark slot in doctor repository
      await doctorRepository.markSlotAvailability(
        doctorId: doctorId,
        slot: slotDateTime,
        isAvailable: false,
      );
      slotMarked = true;

      // Step 2: Book appointment in repository
      final appointmentId =
          generateUniqueAppointmentId(_appointments.map((a) => a.id));
      final newAppointment = AppointmentModel(
        id: appointmentId,
        doctorId: doctorId,
        doctorName: doctorName,
        doctorSpecialty: doctorSpecialty,
        patientName: patientName,
        patientAge: patientAge,
        patientPhone: patientPhone,
        appointmentDate: appointmentDate,
        timeSlot: timeSlot,
        status: AppointmentStatus.upcoming,
        symptomsNote: symptomsNote,
      );

      bookedAppointment = await _repository.bookAppointment(newAppointment);
      if (!isDisposed) {
        _appointments.insert(0, bookedAppointment);
      }

      // Step 3: Automatically generate linked consultation invoice
      final existingBills = await billRepository.getBills();
      final billId =
          BillProvider.generateUniqueBillId(existingBills.map((b) => b.id));
      final newBill = BillCalculator.createConsultationBill(
        id: billId,
        appointmentId: appointmentId,
        billDate: appointmentDate,
        doctorName: doctorName,
        doctorSpecialty: doctorSpecialty,
        consultationFee: consultationFee,
      );
      createdBill = await billRepository.addBill(newBill);

      return bookedAppointment;
    } catch (e) {
      // Transactional Rollback
      if (createdBill != null) {
        try {
          await billRepository.removeBill(createdBill.id);
        } catch (rollbackError) {
          if (kDebugMode) {
            debugPrint('Rollback error removing bill: $rollbackError');
          }
        }
      }
      if (bookedAppointment != null) {
        _appointments.removeWhere((a) => a.id == bookedAppointment!.id);
        try {
          await _repository.deleteAppointment(bookedAppointment.id);
        } catch (rollbackError) {
          if (kDebugMode) {
            debugPrint('Rollback error deleting appointment: $rollbackError');
          }
        }
      }
      if (slotMarked) {
        try {
          await doctorRepository.markSlotAvailability(
            doctorId: doctorId,
            slot: slotDateTime,
            isAvailable: true,
          );
        } catch (rollbackError) {
          if (kDebugMode) {
            debugPrint('Rollback error releasing slot: $rollbackError');
          }
        }
      }

      _error = e is AppException ? e.userFriendlyMessage : 'Booking failed: $e';
      rethrow;
    } finally {
      if (!isDisposed) {
        _isBooking = false;
        notifyListeners();
      }
    }
  }

  /// Cancels an upcoming appointment, frees its slot, and cancels linked pending bill.
  Future<AppointmentModel> cancelAppointment(String appointmentId) async {
    _isCancelling = true;
    _error = null;
    notifyListeners();

    try {
      final cancelled = await _repository.cancelAppointment(appointmentId);
      if (!isDisposed) {
        final index = _appointments.indexWhere((a) => a.id == appointmentId);
        if (index != -1) {
          _appointments[index] = cancelled;
        }
      }

      // Free slot in doctor repository
      final slotDateTime = AppFormatters.tryParseTimeSlot(
        cancelled.appointmentDate,
        cancelled.timeSlot,
      );
      if (slotDateTime != null) {
        await doctorRepository.markSlotAvailability(
          doctorId: cancelled.doctorId,
          slot: slotDateTime,
          isAvailable: true,
        );
      }

      // Requirement 2: Void or cancel linked unpaid/pending bills
      final bills = await billRepository.getBills();
      for (final b in bills) {
        if (b.appointmentId == appointmentId && b.status != BillStatus.paid) {
          await billRepository.updateBillStatus(
            billId: b.id,
            status: BillStatus.cancelled,
          );
        }
      }

      return cancelled;
    } catch (e) {
      _error = e is AppException ? e.userFriendlyMessage : 'Cancellation failed: $e';
      rethrow;
    } finally {
      if (!isDisposed) {
        _isCancelling = false;
        notifyListeners();
      }
    }
  }

  /// Reschedules an existing upcoming appointment to a new date and time slot.
  Future<AppointmentModel> rescheduleAppointment({
    required String appointmentId,
    required DateTime newDate,
    required String newTimeSlot,
    DateTime? currentTime,
  }) async {
    final now = currentTime ?? DateTime.now();
    final newSlotDateTime = AppFormatters.tryParseTimeSlot(newDate, newTimeSlot);
    if (newSlotDateTime == null) {
      throw ValidationException('Invalid time slot format: "$newTimeSlot"');
    }
    if (newSlotDateTime.isBefore(now)) {
      throw const PastSlotBookingException();
    }

    final appointment = _appointments.firstWhere(
      (a) => a.id == appointmentId,
      orElse: () => throw NotFoundException('Appointment $appointmentId not found'),
    );

    final isAlreadyBooked = _appointments.any((a) =>
        a.id != appointmentId &&
        a.doctorId == appointment.doctorId &&
        a.status == AppointmentStatus.upcoming &&
        a.appointmentDate.year == newDate.year &&
        a.appointmentDate.month == newDate.month &&
        a.appointmentDate.day == newDate.day &&
        a.timeSlot.trim().toLowerCase() == newTimeSlot.trim().toLowerCase());

    if (isAlreadyBooked) {
      throw const SlotUnavailableException(
        'The selected slot is already booked. Please choose another time.',
      );
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final oldSlot = AppFormatters.tryParseTimeSlot(
        appointment.appointmentDate,
        appointment.timeSlot,
      );
      if (oldSlot != null) {
        await doctorRepository.markSlotAvailability(
          doctorId: appointment.doctorId,
          slot: oldSlot,
          isAvailable: true,
        );
      }

      await doctorRepository.markSlotAvailability(
        doctorId: appointment.doctorId,
        slot: newSlotDateTime,
        isAvailable: false,
      );

      final updated = appointment.copyWith(
        appointmentDate: newDate,
        timeSlot: newTimeSlot,
      );
      await _repository.deleteAppointment(appointmentId);
      final saved = await _repository.bookAppointment(updated);

      if (!isDisposed) {
        final index = _appointments.indexWhere((a) => a.id == appointmentId);
        if (index != -1) {
          _appointments[index] = saved;
        }
      }

      final bills = await billRepository.getBills();
      for (final b in bills) {
        if (b.appointmentId == appointmentId && b.status != BillStatus.paid) {
          final updatedBill = b.copyWith(billDate: newDate);
          await billRepository.removeBill(b.id);
          await billRepository.addBill(updatedBill);
        }
      }

      return saved;
    } catch (e) {
      _error = e is AppException ? e.userFriendlyMessage : 'Rescheduling failed: $e';
      rethrow;
    } finally {
      if (!isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }
}

