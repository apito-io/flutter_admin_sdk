// AUTO-GENERATED — DO NOT EDIT
import 'payment.dart';

class PaymentCreatePayload {
  const PaymentCreatePayload({
    this.customerId,
    this.customerName,
    this.paymentReference,
    this.tenantId,
    this.paymentMethod,
    this.recordedAt,
    this.loanId,
    this.businessId,
    this.notes,
    required this.amount,
    this.recordedBy,
    this.installmentId,
    this.vendorId,
    this.isVerified,
    this.paymentId,
  });
  final String? customerId;
  final String? customerName;
  final String? paymentReference;
  final String? tenantId;
  final String? paymentMethod;
  final String? recordedAt;
  final String? loanId;
  final String? businessId;
  final String? notes;
  final double amount;
  final String? recordedBy;
  final String? installmentId;
  final String? vendorId;
  final bool? isVerified;
  final String? paymentId;

  Map<String, dynamic> toJson() => {
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
  };
}

class PaymentUpdatePayload {
  const PaymentUpdatePayload({
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
  final String? customerId;
  final String? customerName;
  final String? paymentReference;
  final String? tenantId;
  final String? paymentMethod;
  final String? recordedAt;
  final String? loanId;
  final String? businessId;
  final String? notes;
  final double? amount;
  final String? recordedBy;
  final String? installmentId;
  final String? vendorId;
  final bool? isVerified;
  final String? paymentId;

  Map<String, dynamic> toJson() {
    final out = <String, dynamic>{};
    if (customerId != null) {
      out['customer_id'] = customerId;
    }
    if (customerName != null) {
      out['customer_name'] = customerName;
    }
    if (paymentReference != null) {
      out['payment_reference'] = paymentReference;
    }
    if (tenantId != null) {
      out['tenant_id'] = tenantId;
    }
    if (paymentMethod != null) {
      out['payment_method'] = paymentMethod;
    }
    if (recordedAt != null) {
      out['recorded_at'] = recordedAt;
    }
    if (loanId != null) {
      out['loan_id'] = loanId;
    }
    if (businessId != null) {
      out['business_id'] = businessId;
    }
    if (notes != null) {
      out['notes'] = notes;
    }
    if (amount != null) {
      out['amount'] = amount;
    }
    if (recordedBy != null) {
      out['recorded_by'] = recordedBy;
    }
    if (installmentId != null) {
      out['installment_id'] = installmentId;
    }
    if (vendorId != null) {
      out['vendor_id'] = vendorId;
    }
    if (isVerified != null) {
      out['is_verified'] = isVerified;
    }
    if (paymentId != null) {
      out['payment_id'] = paymentId;
    }
    return out;
  }
}

class PaymentConnect {
  const PaymentConnect({this.fields = const {}});
  final Map<String, dynamic> fields;
  Map<String, dynamic> toJson() => fields;
}
