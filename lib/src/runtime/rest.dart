import 'dart:convert';

import 'package:http/http.dart' as http;

import 'config.dart';
import 'types.dart';

/// Internal REST transport for file storage (mirrors go-admin-sdk rest.go).
class ApitoRestClient {
  ApitoRestClient({
    required ApitoConfig config,
    required http.Client httpClient,
    required Map<String, String> Function() buildHeaders,
  })  : _config = config,
        _http = httpClient,
        _buildHeaders = buildHeaders;

  final ApitoConfig _config;
  final http.Client _http;
  final Map<String, String> Function() _buildHeaders;

  String get restBaseUrl {
    final explicit = _config.restBaseUrl?.trim();
    if (explicit != null && explicit.isNotEmpty) return explicit;
    return _deriveRestBaseUrl(_config.endpoint);
  }

  static String _deriveRestBaseUrl(String graphqlUrl) {
    final u = graphqlUrl.trim().replaceAll(RegExp(r'/$'), '');
    if (u.endsWith('/graphql')) {
      final base = u.substring(0, u.length - '/graphql'.length);
      // Project file REST lives on /secured even when GraphQL uses /system/graphql.
      if (base.endsWith('/system')) {
        return '${base.substring(0, base.length - '/system'.length)}/secured';
      }
      return base;
    }
    return u;
  }

  Map<String, String> _authHeaders({bool multipart = false}) {
    final headers = Map<String, String>.from(_buildHeaders());
    if (multipart) headers.remove('Content-Type');
    return headers;
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? query,
  }) async {
    final uri = _buildUri(path, query);
    final response = await _http.get(uri, headers: _authHeaders());
    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    required Map<String, dynamic> body,
    bool allowFailure = false,
  }) async {
    final uri = _buildUri(path);
    final response = await _http.post(
      uri,
      headers: _authHeaders(),
      body: jsonEncode(body),
    );
    return _parseResponse(response, allowFailure: allowFailure);
  }

  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required List<int> fileBytes,
    required String fileName,
    String? fileType,
  }) async {
    final uri = _buildUri(path);
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(_authHeaders(multipart: true));
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      fileBytes,
      filename: fileName,
    ));
    if (fileType != null && fileType.trim().isNotEmpty) {
      request.fields['file_type'] = fileType.trim();
    }
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    return _parseResponse(response);
  }

  Uri _buildUri(String path, [Map<String, String>? query]) {
    final base = restBaseUrl.replaceAll(RegExp(r'/$'), '');
    final uri = Uri.parse('$base$path');
    if (query == null || query.isEmpty) return uri;
    return uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        for (final e in query.entries)
          if (e.value.isNotEmpty) e.key: e.value,
      },
    );
  }

  Map<String, dynamic> _parseResponse(
    http.Response response, {
    bool allowFailure = false,
  }) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApitoError(
        'REST HTTP ${response.statusCode}: ${response.body}',
        statusCode: response.statusCode,
      );
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final success = decoded['success'];
    if (success == false && !allowFailure) {
      throw ApitoError(decoded['message'] as String? ?? 'request failed');
    }
    return decoded;
  }
}
