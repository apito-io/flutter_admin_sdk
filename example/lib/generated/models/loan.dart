// AUTO-GENERATED — DO NOT EDIT
import 'package:flutter_admin_sdk/flutter_admin_sdk.dart';

class Loan implements ApitoModel {
  const Loan({
    required this.id,
    this.downPayment,
    this.totalInterest,
    this.totalAmount,
    this.principalAmount,
    this.tenantId,
    this.closedAt,
    this.loanId,
    this.interestRate,
    this.grandTotal,
    this.notes,
    this.totalOutstanding,
    this.customerPhone,
    this.createdAt,
    this.businessId,
    this.itemDescription,
    this.itemName,
    this.installmentCount,
    this.interestType,
    this.customerId,
    this.updatedAt,
    this.firstPaymentDate,
    this.createdBy,
    this.vendorId,
    this.installmentType,
    this.loanStatus,
    this.startDate,
    this.installmentAmount,
    this.paidInstallments,
    this.nextDueDate,
    this.totalPaid,
    this.remainingInstallments,
    this.customerName,
  });

  @override
  final String id;
  final double? downPayment;
  final double? totalInterest;
  final double? totalAmount;
  final double? principalAmount;
  final String? tenantId;
  final String? closedAt;
  final String? loanId;
  final double? interestRate;
  final double? grandTotal;
  final String? notes;
  final double? totalOutstanding;
  final String? customerPhone;
  final String? createdAt;
  final String? businessId;
  final String? itemDescription;
  final String? itemName;
  final int? installmentCount;
  final String? interestType;
  final String? customerId;
  final String? updatedAt;
  final String? firstPaymentDate;
  final String? createdBy;
  final String? vendorId;
  final String? installmentType;
  final String? loanStatus;
  final String? startDate;
  final double? installmentAmount;
  final int? paidInstallments;
  final String? nextDueDate;
  final double? totalPaid;
  final int? remainingInstallments;
  final String? customerName;

  static const modelName = 'loan';
  static List<String> get allFields => const [
    'down_payment',
    'total_interest',
    'total_amount',
    'principal_amount',
    'tenant_id',
    'closed_at',
    'loan_id',
    'interest_rate',
    'grand_total',
    'notes',
    'total_outstanding',
    'customer_phone',
    'created_at',
    'business_id',
    'item_description',
    'item_name',
    'installment_count',
    'interest_type',
    'customer_id',
    'updated_at',
    'first_payment_date',
    'created_by',
    'vendor_id',
    'installment_type',
    'loan_status',
    'start_date',
    'installment_amount',
    'paid_installments',
    'next_due_date',
    'total_paid',
    'remaining_installments',
    'customer_name',
  ];

  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      id: json['id']?.toString() ?? '',
      downPayment: (json['down_payment'] as num?)?.toDouble(),
      totalInterest: (json['total_interest'] as num?)?.toDouble(),
      totalAmount: (json['total_amount'] as num?)?.toDouble(),
      principalAmount: (json['principal_amount'] as num?)?.toDouble(),
      tenantId: json['tenant_id']?.toString(),
      closedAt: json['closed_at']?.toString(),
      loanId: json['loan_id']?.toString(),
      interestRate: (json['interest_rate'] as num?)?.toDouble(),
      grandTotal: (json['grand_total'] as num?)?.toDouble(),
      notes: json['notes']?.toString(),
      totalOutstanding: (json['total_outstanding'] as num?)?.toDouble(),
      customerPhone: json['customer_phone']?.toString(),
      createdAt: json['created_at']?.toString(),
      businessId: json['business_id']?.toString(),
      itemDescription: json['item_description']?.toString(),
      itemName: json['item_name']?.toString(),
      installmentCount: (json['installment_count'] as num?)?.toInt(),
      interestType: json['interest_type']?.toString(),
      customerId: json['customer_id']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      firstPaymentDate: json['first_payment_date']?.toString(),
      createdBy: json['created_by']?.toString(),
      vendorId: json['vendor_id']?.toString(),
      installmentType: json['installment_type']?.toString(),
      loanStatus: json['loan_status']?.toString(),
      startDate: json['start_date']?.toString(),
      installmentAmount: (json['installment_amount'] as num?)?.toDouble(),
      paidInstallments: (json['paid_installments'] as num?)?.toInt(),
      nextDueDate: json['next_due_date']?.toString(),
      totalPaid: (json['total_paid'] as num?)?.toDouble(),
      remainingInstallments: (json['remaining_installments'] as num?)?.toInt(),
      customerName: json['customer_name']?.toString(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'down_payment': downPayment,
      'total_interest': totalInterest,
      'total_amount': totalAmount,
      'principal_amount': principalAmount,
      'tenant_id': tenantId,
      'closed_at': closedAt,
      'loan_id': loanId,
      'interest_rate': interestRate,
      'grand_total': grandTotal,
      'notes': notes,
      'total_outstanding': totalOutstanding,
      'customer_phone': customerPhone,
      'created_at': createdAt,
      'business_id': businessId,
      'item_description': itemDescription,
      'item_name': itemName,
      'installment_count': installmentCount,
      'interest_type': interestType,
      'customer_id': customerId,
      'updated_at': updatedAt,
      'first_payment_date': firstPaymentDate,
      'created_by': createdBy,
      'vendor_id': vendorId,
      'installment_type': installmentType,
      'loan_status': loanStatus,
      'start_date': startDate,
      'installment_amount': installmentAmount,
      'paid_installments': paidInstallments,
      'next_due_date': nextDueDate,
      'total_paid': totalPaid,
      'remaining_installments': remainingInstallments,
      'customer_name': customerName,
    };
  }

  Loan copyWith({
    String? id,
    double? downPayment,
    double? totalInterest,
    double? totalAmount,
    double? principalAmount,
    String? tenantId,
    String? closedAt,
    String? loanId,
    double? interestRate,
    double? grandTotal,
    String? notes,
    double? totalOutstanding,
    String? customerPhone,
    String? createdAt,
    String? businessId,
    String? itemDescription,
    String? itemName,
    int? installmentCount,
    String? interestType,
    String? customerId,
    String? updatedAt,
    String? firstPaymentDate,
    String? createdBy,
    String? vendorId,
    String? installmentType,
    String? loanStatus,
    String? startDate,
    double? installmentAmount,
    int? paidInstallments,
    String? nextDueDate,
    double? totalPaid,
    int? remainingInstallments,
    String? customerName,
  }) {
    return Loan(
      id: id ?? this.id,
      downPayment: downPayment ?? this.downPayment,
      totalInterest: totalInterest ?? this.totalInterest,
      totalAmount: totalAmount ?? this.totalAmount,
      principalAmount: principalAmount ?? this.principalAmount,
      tenantId: tenantId ?? this.tenantId,
      closedAt: closedAt ?? this.closedAt,
      loanId: loanId ?? this.loanId,
      interestRate: interestRate ?? this.interestRate,
      grandTotal: grandTotal ?? this.grandTotal,
      notes: notes ?? this.notes,
      totalOutstanding: totalOutstanding ?? this.totalOutstanding,
      customerPhone: customerPhone ?? this.customerPhone,
      createdAt: createdAt ?? this.createdAt,
      businessId: businessId ?? this.businessId,
      itemDescription: itemDescription ?? this.itemDescription,
      itemName: itemName ?? this.itemName,
      installmentCount: installmentCount ?? this.installmentCount,
      interestType: interestType ?? this.interestType,
      customerId: customerId ?? this.customerId,
      updatedAt: updatedAt ?? this.updatedAt,
      firstPaymentDate: firstPaymentDate ?? this.firstPaymentDate,
      createdBy: createdBy ?? this.createdBy,
      vendorId: vendorId ?? this.vendorId,
      installmentType: installmentType ?? this.installmentType,
      loanStatus: loanStatus ?? this.loanStatus,
      startDate: startDate ?? this.startDate,
      installmentAmount: installmentAmount ?? this.installmentAmount,
      paidInstallments: paidInstallments ?? this.paidInstallments,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      totalPaid: totalPaid ?? this.totalPaid,
      remainingInstallments: remainingInstallments ?? this.remainingInstallments,
      customerName: customerName ?? this.customerName,
    );
  }
}
