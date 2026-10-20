import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'client.dart';
import 'types.dart';

/// Tenant subscription ledger row from ApitoProjectPayment REST.
class ProjectTenantSubscription {
  const ProjectTenantSubscription({
    this.id,
    this.projectId,
    this.tenantId,
    this.planTier,
    this.provider,
    this.status,
    this.billingContactUserId,
    this.externalSubscriptionId,
    this.productId,
    this.currentPeriodStart,
    this.currentPeriodEnd,
    this.cancelAt,
    this.createdBy,
    this.notes,
    this.manageUrl,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String? projectId;
  final String? tenantId;
  final String? planTier;
  final String? provider;
  final String? status;
  final String? billingContactUserId;
  final String? externalSubscriptionId;
  final String? productId;
  final String? currentPeriodStart;
  final String? currentPeriodEnd;
  final String? cancelAt;
  final String? createdBy;
  final String? notes;
  final String? manageUrl;
  final String? createdAt;
  final String? updatedAt;

  factory ProjectTenantSubscription.fromJson(Map<String, dynamic> json) {
    return ProjectTenantSubscription(
      id: json['id'] as String?,
      projectId: json['project_id'] as String?,
      tenantId: json['tenant_id'] as String?,
      planTier: json['plan_tier'] as String?,
      provider: json['provider'] as String?,
      status: json['status'] as String?,
      billingContactUserId: json['billing_contact_user_id'] as String?,
      externalSubscriptionId: json['external_subscription_id'] as String?,
      productId: json['product_id'] as String?,
      currentPeriodStart: json['current_period_start'] as String?,
      currentPeriodEnd: json['current_period_end'] as String?,
      cancelAt: json['cancel_at'] as String?,
      createdBy: json['created_by'] as String?,
      notes: json['notes'] as String?,
      manageUrl: json['manage_url'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}

/// Params for POST .../providers/:provider/verify.
class VerifyProjectPaymentParams {
  const VerifyProjectPaymentParams({
    required this.projectId,
    required this.tenantId,
    required this.productId,
    required this.purchaseToken,
    required this.packageName,
    this.provider = 'google_play',
    this.billingContactUserId,
  });

  final String projectId;
  final String tenantId;
  final String productId;
  final String purchaseToken;
  final String packageName;
  final String provider;
  final String? billingContactUserId;
}

/// Params for POST .../subscriptions/cancel (app-user JWT).
class CancelTenantSubscriptionParams {
  const CancelTenantSubscriptionParams({
    required this.projectId,
    required this.tenantId,
    this.mode = 'cancel',
    this.subscriptionId,
    this.forceLedgerOnly = false,
  });

  final String projectId;
  final String tenantId;

  /// `cancel` (auto-renew off, access until period end) or `revoke` (immediate).
  final String mode;
  final String? subscriptionId;
  final bool forceLedgerOnly;
}

/// Engine origin without `/system/graphql` or `/secured/graphql`.
String projectPaymentApiBaseUrl(String graphqlEndpoint) {
  final ep = graphqlEndpoint.trim().replaceAll(RegExp(r'/$'), '');
  return ep
      .replaceFirst(RegExp(r'/system/graphql$'), '')
      .replaceFirst(RegExp(r'/secured/graphql$'), '');
}

/// ApitoProjectPayment REST (verify / get / cancel) — not platform ApitoPayment.
extension ApitoProjectPayment on ApitoClient {
  Uri _projectPaymentUri(String path) {
    final base = projectPaymentApiBaseUrl(config.endpoint);
    final p = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$p');
  }

  /// App-user session tokens and `apt_` operator tokens may call project-payment
  /// REST. A bootstrap `ak_` key may not.
  void _requireProjectPaymentCredential() {
    final key =
        (config.accessToken ?? config.authToken ?? config.apiKey).trim();
    if (key.startsWith('cli-') ||
        key.startsWith('sdk-') ||
        key.startsWith('mcp-')) {
      throw ArgumentError(
        'TOKEN_FORMAT_RETIRED: cli-/sdk-/mcp- prefixed keys are no longer accepted. '
        'Generate a unified apt_ access token in Console → Access Token and pass it as accessToken.',
      );
    }
    if (key.isEmpty || key.startsWith('ak_')) {
      throw ArgumentError(
        'OPERATOR_CREDENTIAL_REQUIRED: projectPayment requires an app-user session or an apt_ operator token',
      );
    }
  }

  Future<Map<String, dynamic>> _projectPaymentRequest(
    Future<http.Response> Function() send,
  ) async {
    _requireProjectPaymentCredential();
    final response = await send();
    if (response.statusCode == 401 || response.statusCode == 403) {
      onTokenExpired?.call();
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApitoError(
        'Project payment request failed (${response.statusCode}): ${response.body}',
        statusCode: response.statusCode,
      );
    }
    if (response.body.isEmpty) return {};
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    return {};
  }

  /// Verify a store purchase and upsert the tenant subscription ledger row.
  Future<ProjectTenantSubscription> verifyProjectPayment(
    VerifyProjectPaymentParams params,
  ) async {
    final provider =
        params.provider.trim().isEmpty ? 'google_play' : params.provider.trim();
    final uri = _projectPaymentUri(
      '/system/v1/project-payment/projects/${params.projectId}/providers/$provider/verify',
    );
    final body = <String, dynamic>{
      'tenant_id': params.tenantId,
      'product_id': params.productId,
      'purchase_token': params.purchaseToken,
      'package_name': params.packageName,
      if (params.billingContactUserId != null &&
          params.billingContactUserId!.trim().isNotEmpty)
        'billing_contact_user_id': params.billingContactUserId!.trim(),
    };
    final json = await _projectPaymentRequest(
      () => httpClient.post(
        uri,
        headers: buildHeaders(projectId: params.projectId),
        body: jsonEncode(body),
      ),
    );
    return ProjectTenantSubscription.fromJson(json);
  }

  /// Latest subscription for a tenant (active preferred; else any row).
  Future<ProjectTenantSubscription> getTenantSubscription({
    required String projectId,
    required String tenantId,
  }) async {
    final uri = _projectPaymentUri(
      '/system/v1/project-payment/projects/$projectId/tenants/$tenantId/subscription',
    );
    final json = await _projectPaymentRequest(
      () => httpClient.get(
        uri,
        headers: buildHeaders(projectId: projectId, tenantId: tenantId),
      ),
    );
    return ProjectTenantSubscription.fromJson(json);
  }

  /// Cancel via provider (Play API first for google_play), then finalize ledger.
  Future<ProjectTenantSubscription> cancelTenantSubscription(
    CancelTenantSubscriptionParams params,
  ) async {
    final uri = _projectPaymentUri(
      '/system/v1/project-payment/projects/${params.projectId}/subscriptions/cancel',
    );
    final body = <String, dynamic>{
      'tenant_id': params.tenantId,
      'mode': params.mode.trim().isEmpty ? 'cancel' : params.mode.trim(),
      if (params.subscriptionId != null &&
          params.subscriptionId!.trim().isNotEmpty)
        'subscription_id': params.subscriptionId!.trim(),
      if (params.forceLedgerOnly) 'force_ledger_only': true,
    };
    final json = await _projectPaymentRequest(
      () => httpClient.post(
        uri,
        headers: buildHeaders(
          projectId: params.projectId,
          tenantId: params.tenantId,
        ),
        body: jsonEncode(body),
      ),
    );
    return ProjectTenantSubscription.fromJson(json);
  }

  /// Signed-in project user REST. These routes are behind project auth, so a
  /// login session token is enough. Operator `apt_` tokens stay required for
  /// the system GraphQL methods above.
  Future<Map<String, dynamic>> _signedInProjectPaymentRequest(
    Future<http.Response> Function() send,
  ) async {
    _requireProjectPaymentCredential();
    final response = await send();
    if (response.statusCode == 401 || response.statusCode == 403) {
      onTokenExpired?.call();
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApitoError(
        'Project payment request failed (${response.statusCode}): ${response.body}',
        statusCode: response.statusCode,
      );
    }
    if (response.body.isEmpty) return {};
    final contentType = response.headers['content-type'] ?? '';
    if (contentType.contains('application/pdf')) return {};
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    return {};
  }

  /// Latest subscription for the signed-in tenant. 404 returns null.
  Future<ProjectTenantSubscription?> getSignedInTenantSubscription({
    required String projectId,
    required String tenantId,
  }) async {
    final uri = _projectPaymentUri(
      '/system/v1/project-payment/projects/$projectId/tenants/$tenantId/subscription',
    );
    try {
      final json = await _signedInProjectPaymentRequest(
        () => httpClient.get(
          uri,
          headers: buildHeaders(projectId: projectId, tenantId: tenantId),
        ),
      );
      if (json.isEmpty) return null;
      return ProjectTenantSubscription.fromJson(json);
    } on ApitoError catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  /// Posts a Custom payment the signed-in user says they completed.
  /// Returns the subscription when the project creates one, otherwise null.
  Future<ProjectTenantSubscription?> submitCustomPayment(
    SubmitCustomPaymentParams params,
  ) async {
    final uri = _projectPaymentUri(
      '/system/v1/project-payment/projects/${params.projectId}/providers/custom/submit',
    );
    final json = await _signedInProjectPaymentRequest(
      () => httpClient.post(
        uri,
        headers: buildHeaders(
          projectId: params.projectId,
          tenantId: params.tenantId,
        ),
        body: jsonEncode({
          'email': params.email,
          'plan': params.plan,
          'amount': params.amount,
          'currency': params.currency,
          'period_months': params.periodMonths,
          'tenant_id': params.tenantId,
          'payment_reference': params.paymentReference,
        }),
      ),
    );
    final id = json['id'];
    if (id is! String || id.isEmpty) return null;
    return ProjectTenantSubscription.fromJson(json);
  }

  /// Invoices for the signed-in tenant. Issued only after a subscription is activated.
  Future<List<ProjectTenantInvoice>> listTenantInvoices({
    required String projectId,
    required String tenantId,
  }) async {
    final uri = _projectPaymentUri(
      '/system/v1/project-payment/projects/$projectId/tenants/$tenantId/invoices',
    );
    final json = await _signedInProjectPaymentRequest(
      () => httpClient.get(
        uri,
        headers: buildHeaders(projectId: projectId, tenantId: tenantId),
      ),
    );
    final raw = json['invoices'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((row) => ProjectTenantInvoice.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  /// Receipt PDF for one invoice the signed-in user can access.
  Future<Uint8List> downloadTenantInvoiceReceipt({
    required String projectId,
    required String invoiceId,
  }) async {
    final uri = _projectPaymentUri(
      '/system/v1/project-payment/projects/$projectId/invoices/$invoiceId/receipt.pdf',
    );
    _requireProjectPaymentCredential();
    final response = await httpClient.get(
      uri,
      headers: buildHeaders(projectId: projectId),
    );
    if (response.statusCode == 401 || response.statusCode == 403) {
      onTokenExpired?.call();
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApitoError(
        'Invoice receipt failed (${response.statusCode})',
        statusCode: response.statusCode,
      );
    }
    return response.bodyBytes;
  }
}

/// Body for POST .../providers/custom/submit.
class SubmitCustomPaymentParams {
  const SubmitCustomPaymentParams({
    required this.projectId,
    required this.tenantId,
    required this.email,
    required this.plan,
    required this.amount,
    required this.currency,
    required this.periodMonths,
    required this.paymentReference,
  });

  final String projectId;
  final String tenantId;
  final String email;
  final String plan;
  final double amount;
  final String currency;
  final int periodMonths;
  final String paymentReference;
}

/// One invoice row from the signed-in tenant invoice list.
class ProjectTenantInvoice {
  const ProjectTenantInvoice({
    required this.id,
    this.subscriptionId,
    this.tenantId,
    this.amount,
    this.currency,
    this.status,
    this.provider,
    this.issuedAt,
    this.paidAt,
    this.createdAt,
  });

  final String id;
  final String? subscriptionId;
  final String? tenantId;
  final double? amount;
  final String? currency;
  final String? status;
  final String? provider;
  final String? issuedAt;
  final String? paidAt;
  final String? createdAt;

  factory ProjectTenantInvoice.fromJson(Map<String, dynamic> json) {
    final rawAmount = json['amount'];
    return ProjectTenantInvoice(
      id: (json['id'] ?? '').toString(),
      subscriptionId: json['subscription_id'] as String?,
      tenantId: json['tenant_id'] as String?,
      amount: rawAmount is num ? rawAmount.toDouble() : null,
      currency: json['currency'] as String?,
      status: json['status'] as String?,
      provider: json['provider'] as String?,
      issuedAt: json['issued_at'] as String?,
      paidAt: json['paid_at'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }
}
