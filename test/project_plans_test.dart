import 'package:flutter_admin_sdk/flutter_admin_sdk.dart';
import 'package:test/test.dart';

void main() {
  group('ProjectPlan.fromJson', () {
    test('parses prices and provider_products', () {
      final plan = ProjectPlan.fromJson({
        'id': 'paid',
        'name': 'Pro',
        'description': 'Pro plan',
        'currency': 'BDT',
        'price_monthly': 200,
        'prices': [
          {'currency': 'BDT', 'amount': 200, 'default': true},
          {'currency': 'USD', 'amount': 1.99},
        ],
        'provider_products': [
          {
            'provider': 'google_play',
            'product_id': 'kisti_pro_user',
            'variant_id': 'kisti-pro-plan',
          },
        ],
      });
      expect(plan.id, 'paid');
      expect(plan.priceMonthly, 200);
      expect(plan.prices.length, 2);
      expect(plan.prices.first.isDefault, isTrue);
      expect(plan.googlePlayProductIds, ['kisti_pro_monthly']);
    });

    test('falls back to legacy play_product_id', () {
      final plan = ProjectPlan.fromJson({
        'id': 'paid',
        'play_product_id': 'legacy_sku',
        'provider_products': [],
      });
      expect(plan.googlePlayProductIds, ['legacy_sku']);
    });
  });
}
