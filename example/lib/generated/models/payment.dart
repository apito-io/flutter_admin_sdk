// AUTO-GENERATED — DO NOT EDIT
import 'package:flutter_admin_sdk/flutter_admin_sdk.dart';

class Payment implements ApitoModel {
  const Payment({
    required this.id,
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

  @override
  final String id;
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

  static const modelName = 'payment';
  static List<String> get allFields => const [
    'customer_id',
    'customer_name',
    'payment_reference',
    'tenant_id',
    'payment_method',
    'recorded_at',
    'loan_id',
    'business_id',
    'notes',
    'amount',
    'recorded_by',
    'installment_id',
    'vendor_id',
    'is_verified',
    'payment_id',
  ];

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id']?.toString() ?? '',
      customerId: json['customer_id']?.toString(),
      customerName: json['customer_name']?.toString(),
      paymentReference: json['payment_reference']?.toString(),
      tenantId: json['tenant_id']?.toString(),
      paymentMethod: json['payment_method']?.toString(),
      recordedAt: json['recorded_at']?.toString(),
      loanId: json['loan_id']?.toString(),
      businessId: json['business_id']?.toString(),
      notes: json['notes']?.toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      recordedBy: json['recorded_by']?.toString(),
      installmentId: json['installment_id']?.toString(),
      vendorId: json['vendor_id']?.toString(),
      isVerified: json['is_verified'] as bool?,
      paymentId: json['payment_id']?.toString(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
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

  Payment copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? paymentReference,
    String? tenantId,
    String? paymentMethod,
    String? recordedAt,
    String? loanId,
    String? businessId,
    String? notes,
    double? amount,
    String? recordedBy,
    String? installmentId,
    String? vendorId,
    bool? isVerified,
    String? paymentId,
  }) {
    return Payment(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      paymentReference: paymentReference ?? this.paymentReference,
      tenantId: tenantId ?? this.tenantId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      recordedAt: recordedAt ?? this.recordedAt,
      loanId: loanId ?? this.loanId,
      businessId: businessId ?? this.businessId,
      notes: notes ?? this.notes,
      amount: amount ?? this.amount,
      recordedBy: recordedBy ?? this.recordedBy,
      installmentId: installmentId ?? this.installmentId,
      vendorId: vendorId ?? this.vendorId,
      isVerified: isVerified ?? this.isVerified,
      paymentId: paymentId ?? this.paymentId,
    );
  }
}
