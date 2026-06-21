// AUTO-GENERATED — DO NOT EDIT
import 'package:flutter_admin_sdk/flutter_admin_sdk.dart';

class Customer implements ApitoModel {
  const Customer({
    required this.id,
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

  @override
  final String id;
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

  static const modelName = 'customer';
  static List<String> get allFields => const [
    'is_blacklisted',
    'business_id',
    'vendor_id',
    'phone',
    'updated_at',
    'tenant_id',
    'notes',
    'customer_id',
    'customer_uid',
    'guarantor_name',
    'total_outstanding',
    'address',
    'nid_number',
    'active_loans_count',
    'name',
    'created_at',
    'guarantor_phone',
  ];

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id']?.toString() ?? '',
      isBlacklisted: json['is_blacklisted'] as bool?,
      businessId: json['business_id']?.toString(),
      vendorId: json['vendor_id']?.toString(),
      phone: json['phone']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      tenantId: json['tenant_id']?.toString(),
      notes: json['notes']?.toString(),
      customerId: json['customer_id']?.toString(),
      customerUid: json['customer_uid']?.toString(),
      guarantorName: json['guarantor_name']?.toString(),
      totalOutstanding: (json['total_outstanding'] as num?)?.toDouble(),
      address: json['address']?.toString(),
      nidNumber: json['nid_number']?.toString(),
      activeLoansCount: (json['active_loans_count'] as num?)?.toInt(),
      name: json['name']?.toString(),
      createdAt: json['created_at']?.toString(),
      guarantorPhone: json['guarantor_phone']?.toString(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
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

  Customer copyWith({
    String? id,
    bool? isBlacklisted,
    String? businessId,
    String? vendorId,
    String? phone,
    String? updatedAt,
    String? tenantId,
    String? notes,
    String? customerId,
    String? customerUid,
    String? guarantorName,
    double? totalOutstanding,
    String? address,
    String? nidNumber,
    int? activeLoansCount,
    String? name,
    String? createdAt,
    String? guarantorPhone,
  }) {
    return Customer(
      id: id ?? this.id,
      isBlacklisted: isBlacklisted ?? this.isBlacklisted,
      businessId: businessId ?? this.businessId,
      vendorId: vendorId ?? this.vendorId,
      phone: phone ?? this.phone,
      updatedAt: updatedAt ?? this.updatedAt,
      tenantId: tenantId ?? this.tenantId,
      notes: notes ?? this.notes,
      customerId: customerId ?? this.customerId,
      customerUid: customerUid ?? this.customerUid,
      guarantorName: guarantorName ?? this.guarantorName,
      totalOutstanding: totalOutstanding ?? this.totalOutstanding,
      address: address ?? this.address,
      nidNumber: nidNumber ?? this.nidNumber,
      activeLoansCount: activeLoansCount ?? this.activeLoansCount,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      guarantorPhone: guarantorPhone ?? this.guarantorPhone,
    );
  }
}
