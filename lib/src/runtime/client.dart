import 'dart:convert';

import 'package:http/http.dart' as http;

import 'client_runtime.dart';
import 'config.dart';
import 'query_builder.dart';
import 'system_operation_classifier.dart';
import 'types.dart';

/// HTTP GraphQL client for Apito secured/project endpoint.
class ApitoClient {
  ApitoClient({
    required ApitoConfig config,
    http.Client? httpClient,
    this.onTokenExpired,
  })  : _config = config,
        _http = httpClient ?? http.Client();

  final ApitoConfig _config;
  final http.Client _http;
  final void Function()? onTokenExpired;

  ApitoConfig get config => _config;
  http.Client get httpClient => _http;

  /// Whether this client has the credential class reserved for system
  /// administration. The server still enforces the token's actual grants.
  bool get hasOperatorCredential {
    final key =
        (_config.accessToken ?? _config.authToken ?? _config.apiKey).trim();
    return key.startsWith('apt_');
  }

  bool get _usesSystemGraphQLEndpoint {
    final uri = Uri.tryParse(_config.endpoint);
    final path = uri?.path
            .toLowerCase()
            .replaceAll(RegExp(r'/+$'), '') ??
        '';
    return path == '/system/graphql' || path == '/system/graphql/v2';
  }

  /// Fail before a request is made when a system-only SDK method is called
  /// with a bootstrap or app-user credential.
  void requireOperatorCredential(String operation) {
    if (hasOperatorCredential) return;
    throw ArgumentError(
      'OPERATOR_CREDENTIAL_REQUIRED: $operation requires an apt_ operator token',
    );
  }

  QueryBuilder from(String model) => QueryBuilder(client: this, model: model);

  Map<String, String> buildHeaders({String? projectId, String? tenantId}) {
    final headers = <String, String>{'Content-Type': 'application/json'};
    final key =
        (_config.accessToken ?? _config.authToken ?? _config.apiKey).trim();
    if (key.startsWith('cli-') ||
        key.startsWith('sdk-') ||
        key.startsWith('mcp-')) {
      throw ArgumentError(
        'TOKEN_FORMAT_RETIRED: cli-/sdk-/mcp- prefixed keys are no longer accepted. '
        'Generate a unified apt_ access token in Console → Access Token and pass it as accessToken.',
      );
    }
    if (key.startsWith('apt_')) {
      headers['Authorization'] = 'Bearer $key';
      headers['X-Use-Cookies'] = 'false';
    } else if (key.startsWith('ak_')) {
      headers['X-Apito-Key'] = key;
    } else if (_config.useBearerAuth ||
        (_config.authToken?.isNotEmpty ?? false) ||
        (_config.accessToken?.isNotEmpty ?? false)) {
      if (key.isNotEmpty) {
        headers['Authorization'] = 'Bearer $key';
        headers['X-Use-Cookies'] = 'false';
      }
    } else if (key.isNotEmpty) {
      headers['X-Apito-Key'] = key;
    }
    final effectiveTenantId = (tenantId ?? _config.tenantId)?.trim();
    if (effectiveTenantId != null && effectiveTenantId.isNotEmpty) {
      headers['X-Apito-Tenant-ID'] = effectiveTenantId;
    }
    final effectiveProjectId = (projectId ?? _config.projectId)?.trim();
    if (effectiveProjectId != null && effectiveProjectId.isNotEmpty) {
      headers['X-Apito-Project-Id'] = effectiveProjectId;
    }
    return headers;
  }

  Future<Map<String, dynamic>> execute(
    String document, {
    Map<String, dynamic>? variables,
    String? projectId,
    String? tenantId,
  }) async {
    if (_usesSystemGraphQLEndpoint &&
        !hasOperatorCredential &&
        classifySystemOperation(document) == SystemOperationClass.privileged) {
      throw ArgumentError(
        'OPERATOR_CREDENTIAL_REQUIRED: bootstrap credentials cannot call '
        'privileged system operations',
      );
    }
    final response = await _http.post(
      Uri.parse(_config.endpoint),
      headers: buildHeaders(projectId: projectId, tenantId: tenantId),
      body: jsonEncode({'query': document, 'variables': variables ?? {}}),
    );

    if (response.statusCode == 401 || response.statusCode == 403) {
      onTokenExpired?.call();
      throw ApitoError(
        'Authentication failed (${response.statusCode})',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApitoError(
        'GraphQL HTTP ${response.statusCode}: ${response.body}',
        statusCode: response.statusCode,
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final errors = decoded['errors'] as List<dynamic>?;
    if (errors != null && errors.isNotEmpty) {
      final first = errors.first as Map<String, dynamic>;
      final msg = errors.map((e) => (e as Map)['message']).join('; ');
      final path = (first['path'] as List?)?.join('.');
      if (_isAuthError(msg)) onTokenExpired?.call();
      throw ApitoError(msg, path: path);
    }

    return decoded['data'] as Map<String, dynamic>? ?? {};
  }

  /// Pre-login project runtime for one platform. Does not take a model name.
  Future<ClientRuntime> fetchClientRuntime(String platform) async {
    final data = await execute(
      r'''
      query ClientRuntime($platform: String!) {
        clientRuntime(platform: $platform) {
          platform
          min_version_name
          min_build_number
          force_update
          store_url
          message_en
          message_bn
          maintenance
          maintenance_hours
          extras
        }
      }
      ''',
      variables: {'platform': platform},
    );
    final runtime = data['clientRuntime'];
    if (runtime is! Map) {
      throw ApitoError('clientRuntime returned no payload');
    }
    return ClientRuntime.fromGraphql(
      Map<dynamic, dynamic>.from(runtime),
      platform: platform,
    );
  }

  bool _isAuthError(String msg) {
    final lower = msg.toLowerCase();
    return lower.contains('unauthorized') ||
        lower.contains('forbidden') ||
        lower.contains('token') ||
        lower.contains('authentication');
  }

  /// System GraphQL fallback: list via `getModelData`.
  ///
  /// Pass [connection] to scope children of a parent document (e.g. all
  /// `timetable_stop` rows linked to one `train`). Shape matches
  /// `ListAllDataDetailedOfAModelConnectionPayload`.
  Future<ApitoListResponse> listModelSystem({
    required String modelName,
    Map<String, dynamic>? where,
    Map<String, dynamic>? connection,
    int page = 1,
    int limit = 200,
  }) async {
    requireOperatorCredential('listModelSystem');
    const query = r'''
      query GetModelData(
        $model: String!
        $page: Int
        $limit: Int
        $where: JSON
        $connection: ListAllDataDetailedOfAModelConnectionPayload
      ) {
        getModelData(
          model: $model
          page: $page
          limit: $limit
          where: $where
          connection: $connection
        ) {
          count
          results {
            id
            data
            relation_doc_id
            meta { created_at updated_at status }
          }
        }
      }
    ''';

    final data = await execute(query, variables: {
      'model': modelName,
      'page': page,
      'limit': limit,
      if (where != null && where.isNotEmpty) 'where': where,
      if (connection != null && connection.isNotEmpty) 'connection': connection,
    });

    final block = data['getModelData'] as Map<String, dynamic>? ?? {};
    final results = block['results'] as List<dynamic>? ?? [];
    return ApitoListResponse(
      data: results
          .map((r) => ApitoRecord.fromGraphql(r as Map<String, dynamic>))
          .toList(),
      total: block['count'] as int? ?? results.length,
    );
  }

  /// System GraphQL fallback: upsert via `upsertModelData`.
  Future<ApitoRecord> upsertModelSystem({
    required String modelName,
    required Map<String, dynamic> payload,
    String? id,
    Map<String, dynamic>? connect,
  }) async {
    requireOperatorCredential('upsertModelSystem');
    const mutation = r'''
      mutation UpsertModelData(
        $model_name: String!
        $payload: JSON!
        $status: String!
        $_id: String
        $connect: JSON
      ) {
        upsertModelData(
          model_name: $model_name
          payload: $payload
          status: $status
          _id: $_id
          connect: $connect
        ) {
          id
          data
          meta { created_at updated_at status }
        }
      }
    ''';

    final data = await execute(mutation, variables: {
      'model_name': modelName,
      'payload': payload,
      'status': 'published',
      if (id != null) '_id': id,
      if (connect != null) 'connect': connect,
    });

    final doc = data['upsertModelData'] as Map<String, dynamic>;
    return ApitoRecord.fromGraphql(doc);
  }

  /// System GraphQL fallback: delete via `deleteModelData`.
  Future<void> deleteModelSystem({
    required String modelName,
    required String id,
  }) async {
    requireOperatorCredential('deleteModelSystem');
    const mutation = r'''
      mutation DeleteModelData($model_name: String!, $_id: String) {
        deleteModelData(model_name: $model_name, _id: $_id) {
          id
        }
      }
    ''';

    final data = await execute(mutation, variables: {
      'model_name': modelName,
      '_id': id,
    });
    // Already-gone docs return null without throwing in some engines; treat as success.
    data['deleteModelData'];
  }

  void close() => _http.close();
}
