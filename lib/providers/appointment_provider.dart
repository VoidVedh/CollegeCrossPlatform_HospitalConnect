import 'package:flutter/foundation.dart';
import 'package:hospital_connect/core/errors/app_exceptions.dart';
import 'package:hospital_connect/core/utils/bill_calculator.dart';
import 'package:hospital_connect/core/utils/formatters.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/providers/bill_provider.dart';
import 'package:hospital_connect/services/repositories/repositories.dart';
import 'package:uuid/uuid.dart';

/// State management provider for patient appointments and bookings.
class AppointmentProvider extends ChangeNotifier {
  AppointmentProvider(
    this._repository, {
    this.doctorRepository,
    this.billRepository,
  }) {
    loadAppointments();
  }

  final AppointmentRepository _repository;
  final DoctorRepository? doctorRepository;
  final BillRepository? billRepository;
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
      _appointments =
          List<AppointmentModel>.from(await _repository.getAppointments());
    } catch (e) {
      _error = 'Failed to load appointments: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
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
      if (doctorRepository != null) {
        await doctorRepository!.markSlotAvailability(
          doctorId: doctorId,
          slot: slotDateTime,
          isAvailable: false,
        );
        slotMarked = true;
      }

      // Step 2: Book appointment in repository
      final appointmentId = generateUniqueAppointmentId(_appointments.map((a) => a.id));
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
      _appointments.insert(0, bookedAppointment);

      // Step 3: Automatically generate linked consultation invoice
      if (billRepository != null) {
        final existingBills = await billRepository!.getBills();
        final billId = BillProvider.generateUniqueBillId(existingBills.map((b) => b.id));
        final newBill = BillCalculator.createConsultationBill(
          id: billId,
          appointmentId: appointmentId,
          billDate: appointmentDate,
          doctorName: doctorName,
          doctorSpecialty: doctorSpecialty,
          consultationFee: consultationFee,
        );
        createdBill = await billRepository!.addBill(newBill);
      }

      return bookedAppointment;
    } catch (e) {
      // Transactional Rollback
      if (createdBill != null && billRepository != null) {
        try {
          await billRepository!.removeBill(createdBill.id);
        } catch (_) {}
      }
      if (bookedAppointment != null) {
        _appointments.removeWhere((a) => a.id == bookedAppointment!.id);
        try {
          await _repository.deleteAppointment(bookedAppointment.id);
        } catch (_) {}
      }
      if (slotMarked && doctorRepository != null) {
        try {
          await doctorRepository!.markSlotAvailability(
            doctorId: doctorId,
            slot: slotDateTime,
            isAvailable: true,
          );
        } catch (_) {}
      }

      _error = e is AppException ? e.message : 'Booking failed: $e';
      rethrow;
    } finally {
      _isBooking = false;
      notifyListeners();
    }
  }

  /// Cancels an upcoming appointment, frees its slot, and cancels linked pending bill.
  Future<AppointmentModel> cancelAppointment(String appointmentId) async {
    _isCancelling = true;
    _error = null;
    notifyListeners();

    try {
      final cancelled = await _repository.cancelAppointment(appointmentId);
      final index = _appointments.indexWhere((a) => a.id == appointmentId);
      if (index != -1) {
        _appointments[index] = cancelled;
      }

      // Free slot in doctor repository
      if (doctorRepository != null) {
        final slotDateTime = AppFormatters.tryParseTimeSlot(
          cancelled.appointmentDate,
          cancelled.timeSlot,
        );
        if (slotDateTime != null) {
          await doctorRepository!.markSlotAvailability(
            doctorId: cancelled.doctorId,
            slot: slotDateTime,
            isAvailable: true,
          );
        }
      }

      // Requirement 2: Void or cancel linked unpaid/pending bills
      if (billRepository != null) {
        final bills = await billRepository!.getBills();
        for (final b in bills) {
          if (b.appointmentId == appointmentId && b.status != BillStatus.paid) {
            await billRepository!.updateBillStatus(
              billId: b.id,
              status: BillStatus.cancelled,
            );
          }
        }
      }

      return cancelled;
    } catch (e) {
      _error = e is AppException ? e.message : 'Cancellation failed: $e';
      rethrow;
    } finally {
      _isCancelling = false;
      notifyListeners();
    }
  }
}
