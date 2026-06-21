// AUTO-GENERATED — DO NOT EDIT
import 'package:flutter_admin_sdk/flutter_admin_sdk.dart';

class PaymentWhere {
  const PaymentWhere({
    this.customerId,
    this.customerName,
    this.paymentReference,
    this.tenantId,
    this.paymentMethod,
    this.recordedAt,
    this.loanId,
    this.businessId,
    this.notes,
    this.amount,
    this.recordedBy,
    this.installmentId,
    this.vendorId,
    this.isVerified,
    this.paymentId,
  });

  final WhereOp<String>? customerId;
  final WhereOp<String>? customerName;
  final WhereOp<String>? paymentReference;
  final WhereOp<String>? tenantId;
  final WhereOp<String>? paymentMethod;
  final WhereOp<String>? recordedAt;
  final WhereOp<String>? loanId;
  final WhereOp<String>? businessId;
  final WhereOp<String>? notes;
  final WhereOp<double>? amount;
  final WhereOp<String>? recordedBy;
  final WhereOp<String>? installmentId;
  final WhereOp<String>? vendorId;
  final WhereOp<bool>? isVerified;
  final WhereOp<String>? paymentId;

  Map<String, dynamic> toJson() {
    return buildWhereJson({
      'customer_id': customerId,
      'customer_name': customerName,
      'payment_reference': paymentReference,
      'tenant_id': tenantId,
      'payment_method': paymentMethod,
      'recorded_at': recordedAt,
      'loan_id': loanId,
      'business_id': businessId,
      'notes': notes,
      'amount': amount,
      'recorded_by': recordedBy,
      'installment_id': installmentId,
      'vendor_id': vendorId,
      'is_verified': isVerified,
      'payment_id': paymentId,
    });
  }
}
