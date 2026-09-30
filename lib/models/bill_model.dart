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

  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      id: json['id'] as String,
      billDate: DateTime.parse(json['billDate'] as String),
      serviceName: json['serviceName'] as String,
      consultationFee: (json['consultationFee'] as num).toDouble(),
      labCharges: (json['labCharges'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      status: BillStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => BillStatus.unpaid,
      ),
      paymentMethod: json['paymentMethod'] != null
          ? PaymentMethodType.values.firstWhere(
              (m) => m.name == json['paymentMethod'],
              orElse: () => PaymentMethodType.upi,
            )
          : null,
      paidAt: json['paidAt'] != null
          ? DateTime.parse(json['paidAt'] as String)
          : null,
      appointmentId: json['appointmentId'] as String?,
    );
  }

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'billDate': billDate.toIso8601String(),
      'serviceName': serviceName,
      'consultationFee': consultationFee,
      'labCharges': labCharges,
      'tax': tax,
      'status': status.name,
      if (paymentMethod != null) 'paymentMethod': paymentMethod!.name,
      if (paidAt != null) 'paidAt': paidAt!.toIso8601String(),
      if (appointmentId != null) 'appointmentId': appointmentId,
    };
  }

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
          id == other.id &&
          billDate == other.billDate &&
          serviceName == other.serviceName &&
          consultationFee == other.consultationFee &&
          labCharges == other.labCharges &&
          tax == other.tax &&
          status == other.status &&
          paymentMethod == other.paymentMethod &&
          paidAt == other.paidAt &&
          appointmentId == other.appointmentId;

  @override
  int get hashCode => Object.hash(
        id,
        billDate,
        serviceName,
        consultationFee,
        labCharges,
        tax,
        status,
        paymentMethod,
        paidAt,
        appointmentId,
      );
}
