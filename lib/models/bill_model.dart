import 'package:flutter/foundation.dart';
import 'package:hospital_connect/models/enums.dart';

/// Immutable model representing an itemized medical bill / invoice.
@immutable
class BillModel {
  const BillModel({
    required this.id,
    required this.billDate,
    required this.serviceName,
    required this.consultationFee,
    required this.labCharges,
    required this.tax,
    required this.status,
    this.paymentMethod,
    this.paidAt,
    this.appointmentId,
  });

  final String id;
  final DateTime billDate;
  final String serviceName;
  final double consultationFee;
  final double labCharges;
  final double tax;
  final BillStatus status;
  final PaymentMethodType? paymentMethod;
  final DateTime? paidAt;
  final String? appointmentId;

  /// Dynamic computed total amount: Consultation + Lab + Tax.
  /// Note: totalAmount is intentionally computed dynamically and never hardcoded or stored.
  double get totalAmount => consultationFee + labCharges + tax;

  BillModel copyWith({
    String? id,
    DateTime? billDate,
    String? serviceName,
    double? consultationFee,
    double? labCharges,
    double? tax,
    BillStatus? status,
    PaymentMethodType? paymentMethod,
    DateTime? paidAt,
    String? appointmentId,
  }) {
    return BillModel(
      id: id ?? this.id,
      billDate: billDate ?? this.billDate,
      serviceName: serviceName ?? this.serviceName,
      consultationFee: consultationFee ?? this.consultationFee,
      labCharges: labCharges ?? this.labCharges,
      tax: tax ?? this.tax,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paidAt: paidAt ?? this.paidAt,
      appointmentId: appointmentId ?? this.appointmentId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
