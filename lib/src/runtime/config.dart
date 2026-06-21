/// Apito client configuration.
library;

class ApitoConfig {
  const ApitoConfig({
    required this.endpoint,
    required this.apiKey,
    this.projectId,
    this.tenantId,
    this.authToken,
    this.useBearerAuth = false,
    this.restBaseUrl,
  });

  final String endpoint;
  final String apiKey;
  final String? projectId;
  final String? tenantId;
  final String? authToken;

  /// When true, sends `Authorization: Bearer` instead of `X-Apito-Key`.
  final bool useBearerAuth;

  /// REST base URL for file storage. Defaults to endpoint with `/graphql` stripped.
  final String? restBaseUrl;

  ApitoConfig copyWith({
    String? endpoint,
    String? apiKey,
    String? projectId,
    String? tenantId,
    String? authToken,
    bool? useBearerAuth,
    String? restBaseUrl,
  }) {
    return ApitoConfig(
      endpoint: endpoint ?? this.endpoint,
      apiKey: apiKey ?? this.apiKey,
      projectId: projectId ?? this.projectId,
      tenantId: tenantId ?? this.tenantId,
      authToken: authToken ?? this.authToken,
      useBearerAuth: useBearerAuth ?? this.useBearerAuth,
      restBaseUrl: restBaseUrl ?? this.restBaseUrl,
    );
  }
}
