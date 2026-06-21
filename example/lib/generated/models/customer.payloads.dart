// AUTO-GENERATED — DO NOT EDIT
import 'customer.dart';

class CustomerCreatePayload {
  const CustomerCreatePayload({
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
  final bool? isBlacklisted;
  final String? businessId;
  final String? vendorId;
  final String? phone;
  final String? updatedAt;
  final String? tenantId;
  final String? notes;
  final String? customerId;
  final String? customerUid;
  final String? guarantorName;
  final double? totalOutstanding;
  final String? address;
  final String? nidNumber;
  final int? activeLoansCount;
  final String? name;
  final String? createdAt;
  final String? guarantorPhone;

  Map<String, dynamic> toJson() => {
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
  };
}

class CustomerUpdatePayload {
  const CustomerUpdatePayload({
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
  final bool? isBlacklisted;
  final String? businessId;
  final String? vendorId;
  final String? phone;
  final String? updatedAt;
  final String? tenantId;
  final String? notes;
  final String? customerId;
  final String? customerUid;
  final String? guarantorName;
  final double? totalOutstanding;
  final String? address;
  final String? nidNumber;
  final int? activeLoansCount;
  final String? name;
  final String? createdAt;
  final String? guarantorPhone;

  Map<String, dynamic> toJson() {
    final out = <String, dynamic>{};
    if (isBlacklisted != null) {
      out['is_blacklisted'] = isBlacklisted;
    }
    if (businessId != null) {
      out['business_id'] = businessId;
    }
    if (vendorId != null) {
      out['vendor_id'] = vendorId;
    }
    if (phone != null) {
      out['phone'] = phone;
    }
    if (updatedAt != null) {
      out['updated_at'] = updatedAt;
    }
    if (tenantId != null) {
      out['tenant_id'] = tenantId;
    }
    if (notes != null) {
      out['notes'] = notes;
    }
    if (customerId != null) {
      out['customer_id'] = customerId;
    }
    if (customerUid != null) {
      out['customer_uid'] = customerUid;
    }
    if (guarantorName != null) {
      out['guarantor_name'] = guarantorName;
    }
    if (totalOutstanding != null) {
      out['total_outstanding'] = totalOutstanding;
    }
    if (address != null) {
      out['address'] = address;
    }
    if (nidNumber != null) {
      out['nid_number'] = nidNumber;
    }
    if (activeLoansCount != null) {
      out['active_loans_count'] = activeLoansCount;
    }
    if (name != null) {
      out['name'] = name;
    }
    if (createdAt != null) {
      out['created_at'] = createdAt;
    }
    if (guarantorPhone != null) {
      out['guarantor_phone'] = guarantorPhone;
    }
    return out;
  }
}

class CustomerConnect {
  const CustomerConnect({this.fields = const {}});
  final Map<String, dynamic> fields;
  Map<String, dynamic> toJson() => fields;
}
