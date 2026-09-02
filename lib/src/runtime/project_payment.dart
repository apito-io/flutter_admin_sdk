import 'dart:convert';

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

  Future<Map<String, dynamic>> _projectPaymentRequest(
    Future<http.Response> Function() send,
  ) async {
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
    final provider = params.provider.trim().isEmpty
        ? 'google_play'
        : params.provider.trim();
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
}
