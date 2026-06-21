// AUTO-GENERATED — DO NOT EDIT
import 'loan.dart';

class LoanCreatePayload {
  const LoanCreatePayload({
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

  Map<String, dynamic> toJson() => {
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

class LoanUpdatePayload {
  const LoanUpdatePayload({
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

  Map<String, dynamic> toJson() {
    final out = <String, dynamic>{};
    if (downPayment != null) {
      out['down_payment'] = downPayment;
    }
    if (totalInterest != null) {
      out['total_interest'] = totalInterest;
    }
    if (totalAmount != null) {
      out['total_amount'] = totalAmount;
    }
    if (principalAmount != null) {
      out['principal_amount'] = principalAmount;
    }
    if (tenantId != null) {
      out['tenant_id'] = tenantId;
    }
    if (closedAt != null) {
      out['closed_at'] = closedAt;
    }
    if (loanId != null) {
      out['loan_id'] = loanId;
    }
    if (interestRate != null) {
      out['interest_rate'] = interestRate;
    }
    if (grandTotal != null) {
      out['grand_total'] = grandTotal;
    }
    if (notes != null) {
      out['notes'] = notes;
    }
    if (totalOutstanding != null) {
      out['total_outstanding'] = totalOutstanding;
    }
    if (customerPhone != null) {
      out['customer_phone'] = customerPhone;
    }
    if (createdAt != null) {
      out['created_at'] = createdAt;
    }
    if (businessId != null) {
      out['business_id'] = businessId;
    }
    if (itemDescription != null) {
      out['item_description'] = itemDescription;
    }
    if (itemName != null) {
      out['item_name'] = itemName;
    }
    if (installmentCount != null) {
      out['installment_count'] = installmentCount;
    }
    if (interestType != null) {
      out['interest_type'] = interestType;
    }
    if (customerId != null) {
      out['customer_id'] = customerId;
    }
    if (updatedAt != null) {
      out['updated_at'] = updatedAt;
    }
    if (firstPaymentDate != null) {
      out['first_payment_date'] = firstPaymentDate;
    }
    if (createdBy != null) {
      out['created_by'] = createdBy;
    }
    if (vendorId != null) {
      out['vendor_id'] = vendorId;
    }
    if (installmentType != null) {
      out['installment_type'] = installmentType;
    }
    if (loanStatus != null) {
      out['loan_status'] = loanStatus;
    }
    if (startDate != null) {
      out['start_date'] = startDate;
    }
    if (installmentAmount != null) {
      out['installment_amount'] = installmentAmount;
    }
    if (paidInstallments != null) {
      out['paid_installments'] = paidInstallments;
    }
    if (nextDueDate != null) {
      out['next_due_date'] = nextDueDate;
    }
    if (totalPaid != null) {
      out['total_paid'] = totalPaid;
    }
    if (remainingInstallments != null) {
      out['remaining_installments'] = remainingInstallments;
    }
    if (customerName != null) {
      out['customer_name'] = customerName;
    }
    return out;
  }
}

class LoanConnect {
  const LoanConnect({this.fields = const {}});
  final Map<String, dynamic> fields;
  Map<String, dynamic> toJson() => fields;
}
