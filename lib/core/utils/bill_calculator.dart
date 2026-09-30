import 'package:hospital_connect/core/constants/app_constants.dart';
import 'package:hospital_connect/models/enums.dart';
import 'package:hospital_connect/models/bill_model.dart';

/// Centralized utility and factory for medical billing calculations and invoice creation.
class BillCalculator {
  const BillCalculator._();

  /// Computes standard GST on medical consultation and diagnostics.
  static double calculateTax(double consultationFee, [double labCharges = 0.0]) {
    final taxableAmount = consultationFee + labCharges;
    return ((taxableAmount * AppConstants.gstTaxRate) * 100).round() / 100.0;
  }

  /// Factory creating an immutable consultation bill with dynamic GST and itemized items.
  static BillModel createConsultationBill({
    required String id,
    required String appointmentId,
    required DateTime billDate,
    required String doctorName,
    required String doctorSpecialty,
    required double consultationFee,
    double labCharges = 0.0,
    BillStatus status = BillStatus.pending,
    PaymentMethodType? paymentMethod,
    DateTime? paidAt,
  }) {
    final tax = calculateTax(consultationFee, labCharges);
    return BillModel(
      id: id,
      appointmentId: appointmentId,
      billDate: billDate,
      serviceName: 'Consultation - $doctorName ($doctorSpecialty)',
      consultationFee: consultationFee,
      labCharges: labCharges,
      tax: tax,
      status: status,
      paymentMethod: paymentMethod,
      paidAt: paidAt,
    );
  }
}
