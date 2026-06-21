// AUTO-GENERATED — DO NOT EDIT
import 'package:flutter_admin_sdk/flutter_admin_sdk.dart';

class CustomerWhere {
  const CustomerWhere({
    this.isBlacklisted,
    this.businessId,
    this.vendorId,
    this.phone,
    this.updatedAt,
    this.tenantId,
    this.notes,
    this.customerId,
    this.customerUid,
    this.guarantorName,
    this.totalOutstanding,
    this.address,
    this.nidNumber,
    this.activeLoansCount,
    this.name,
    this.createdAt,
    this.guarantorPhone,
  });

  final WhereOp<bool>? isBlacklisted;
  final WhereOp<String>? businessId;
  final WhereOp<String>? vendorId;
  final WhereOp<String>? phone;
  final WhereOp<String>? updatedAt;
  final WhereOp<String>? tenantId;
  final WhereOp<String>? notes;
  final WhereOp<String>? customerId;
  final WhereOp<String>? customerUid;
  final WhereOp<String>? guarantorName;
  final WhereOp<double>? totalOutstanding;
  final WhereOp<String>? address;
  final WhereOp<String>? nidNumber;
  final WhereOp<int>? activeLoansCount;
  final WhereOp<String>? name;
  final WhereOp<String>? createdAt;
  final WhereOp<String>? guarantorPhone;

  Map<String, dynamic> toJson() {
    return buildWhereJson({
      'is_blacklisted': isBlacklisted,
      'business_id': businessId,
      'vendor_id': vendorId,
      'phone': phone,
      'updated_at': updatedAt,
      'tenant_id': tenantId,
      'notes': notes,
      'customer_id': customerId,
      'customer_uid': customerUid,
      'guarantor_name': guarantorName,
      'total_outstanding': totalOutstanding,
      'address': address,
      'nid_number': nidNumber,
      'active_loans_count': activeLoansCount,
      'name': name,
      'created_at': createdAt,
      'guarantor_phone': guarantorPhone,
    });
  }
}
