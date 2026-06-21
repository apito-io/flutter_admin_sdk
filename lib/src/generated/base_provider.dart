/// Base types for generated Riverpod providers (apps supply ApitoClient).
library;

import '../runtime/client.dart';
import '../runtime/types.dart';

/// Apps should expose `apitoClientProvider` returning [ApitoClient].
typedef ApitoClientReader = ApitoClient Function();

/// Wraps list query results for generated providers.
class ApitoProviderListState<T> {
  const ApitoProviderListState({required this.data, required this.total});

  final List<T> data;
  final int total;
}

/// Helper to map runtime list response into typed provider state.
ApitoProviderListState<T> mapListResponse<T>(
  ApitoListResponse response,
  T Function(Map<String, dynamic> json) fromJson,
) {
  return ApitoProviderListState(
    data: response.data
        .map((record) => fromJson({...record.data, 'id': record.id}))
        .toList(),
    total: response.total,
  );
}
