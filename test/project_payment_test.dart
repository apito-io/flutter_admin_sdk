import 'package:flutter_admin_sdk/flutter_admin_sdk.dart';
import 'package:test/test.dart';

void main() {
  group('projectPaymentApiBaseUrl', () {
    test('strips system graphql', () {
      expect(
        projectPaymentApiBaseUrl('http://localhost:5050/system/graphql'),
        'http://localhost:5050',
      );
    });

    test('strips secured graphql', () {
      expect(
        projectPaymentApiBaseUrl('http://localhost:5050/secured/graphql/'),
        'http://localhost:5050',
      );
    });
  });

  group('ProjectTenantSubscription.fromJson', () {
    test('maps snake_case fields', () {
      final row = ProjectTenantSubscription.fromJson({
        'id': 'sub_1',
        'project_id': 'proj',
        'tenant_id': 'ten',
        'plan_tier': 'paid',
        'provider': 'google_play',
        'status': 'canceled',
        'product_id': 'kisti_pro_user',
        'current_period_end': '2026-09-01T00:00:00Z',
        'cancel_at': '2026-08-11T12:00:00Z',
        'manage_url': 'https://play.google.com/store/account/subscriptions?sku=x&package=y',
      });
      expect(row.id, 'sub_1');
      expect(row.planTier, 'paid');
      expect(row.status, 'canceled');
      expect(row.manageUrl, contains('play.google.com'));
      expect(row.productId, 'kisti_pro_user');
    });
  });

  group('CancelTenantSubscriptionParams', () {
    test('defaults mode to cancel', () {
      const p = CancelTenantSubscriptionParams(
        projectId: 'p',
        tenantId: 't',
      );
      expect(p.mode, 'cancel');
      expect(p.forceLedgerOnly, isFalse);
    });
  });
}
