/// Core types for Apito GraphQL responses.
library;

/// Parse an Apito list/get row into a generated model.
///
/// Mutations must use generated `*CreatePayload` / `*UpdatePayload.toJson()`,
/// not Firestore or domain `Model.toJson()`.
T parseApitoRecord<T>(
  ApitoRecord record,
  T Function(Map<String, dynamic> json) fromJson,
) =>
    fromJson({...record.data, 'id': record.id});

List<T> parseApitoRecords<T>(
  List<ApitoRecord> records,
  T Function(Map<String, dynamic> json) fromJson,
) =>
    records.map((r) => parseApitoRecord(r, fromJson)).toList();

class ApitoRecord {
  const ApitoRecord({
    required this.id,
    required this.data,
    this.meta = const {},
    this.connections = const {},
  });

  final String id;
  final Map<String, dynamic> data;
  final Map<String, dynamic> meta;
  final Map<String, dynamic> connections;

  factory ApitoRecord.fromGraphql(Map<String, dynamic> json) {
    return ApitoRecord(
      id: json['id'] as String? ?? '',
      data: Map<String, dynamic>.from(json['data'] as Map? ?? {}),
      meta: Map<String, dynamic>.from(json['meta'] as Map? ?? {}),
      connections: Map<String, dynamic>.from(json)
        ..remove('id')
        ..remove('data')
        ..remove('meta'),
    );
  }
}

class ApitoListResponse {
  const ApitoListResponse({required this.data, required this.total});

  final List<ApitoRecord> data;
  final int total;
}

class ApitoListResponseTyped<T> {
  const ApitoListResponseTyped({required this.data, required this.total});

  final List<T> data;
  final int total;
}

class ApitoError implements Exception {
  ApitoError(this.message, {this.path, this.statusCode});

  final String message;
  final String? path;
  final int? statusCode;

  @override
  String toString() => 'ApitoError: $message${path != null ? ' (path: $path)' : ''}';
}
