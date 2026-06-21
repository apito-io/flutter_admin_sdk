/// Base model mixin for generated Apito record classes.
library;

abstract mixin class ApitoModel {
  String get id;
  Map<String, dynamic> toJson();
}

/// Standard meta block on Apito records.
class ApitoMeta {
  const ApitoMeta({
    this.createdAt,
    this.updatedAt,
    this.status,
  });

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? status;

  factory ApitoMeta.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ApitoMeta();
    return ApitoMeta(
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      status: json['status'] as String?,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
