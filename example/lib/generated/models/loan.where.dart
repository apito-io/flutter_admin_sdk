// AUTO-GENERATED — DO NOT EDIT
import 'package:flutter_admin_sdk/flutter_admin_sdk.dart';

class LoanWhere {
  const LoanWhere({
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

  final WhereOp<double>? downPayment;
  final WhereOp<double>? totalInterest;
  final WhereOp<double>? totalAmount;
  final WhereOp<double>? principalAmount;
  final WhereOp<String>? tenantId;
  final WhereOp<String>? closedAt;
  final WhereOp<String>? loanId;
  final WhereOp<double>? interestRate;
  final WhereOp<double>? grandTotal;
  final WhereOp<String>? notes;
  final WhereOp<double>? totalOutstanding;
  final WhereOp<String>? customerPhone;
  final WhereOp<String>? createdAt;
  final WhereOp<String>? businessId;
  final WhereOp<String>? itemDescription;
  final WhereOp<String>? itemName;
  final WhereOp<int>? installmentCount;
  final WhereOp<String>? interestType;
  final WhereOp<String>? customerId;
  final WhereOp<String>? updatedAt;
  final WhereOp<String>? firstPaymentDate;
  final WhereOp<String>? createdBy;
  final WhereOp<String>? vendorId;
  final WhereOp<String>? installmentType;
  final WhereOp<String>? loanStatus;
  final WhereOp<String>? startDate;
  final WhereOp<double>? installmentAmount;
  final WhereOp<int>? paidInstallments;
  final WhereOp<String>? nextDueDate;
  final WhereOp<double>? totalPaid;
  final WhereOp<int>? remainingInstallments;
  final WhereOp<String>? customerName;

  Map<String, dynamic> toJson() {
    return buildWhereJson({
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
    });
  }
}
