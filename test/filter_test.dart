import 'package:flutter_admin_sdk/src/runtime/filter.dart';
import 'package:flutter_admin_sdk/src/runtime/naming.dart';
import 'package:test/test.dart';

void main() {
  group('apitoFieldIdentifier', () {
    test('camelCase to snake_case', () {
      expect(apitoFieldIdentifier('ownerId'), 'owner_id');
      expect(apitoFieldIdentifier('vendorId'), 'vendor_id');
      expect(apitoFieldIdentifier('businessId'), 'business_id');
      expect(apitoFieldIdentifier('customerPhone'), 'customer_phone');
    });

    test('preserves snake_case and simple keys', () {
      expect(apitoFieldIdentifier('owner_id'), 'owner_id');
      expect(apitoFieldIdentifier('uid'), 'uid');
    });

    test('preserves logical keys', () {
      expect(apitoFieldIdentifier('OR'), 'OR');
      expect(apitoFieldIdentifier('AND'), 'AND');
    });
  });

  group('buildWhereJson', () {
    test('normalizes camelCase filter keys', () {
      expect(
        buildWhereJson({'ownerId': '01ABC'}),
        {'owner_id': {'eq': '01ABC'}},
      );
      expect(
        buildWhereJson({
          'vendorId': 'v1',
          'businessId': 'b1',
        }),
        {
          'vendor_id': {'eq': 'v1'},
          'business_id': {'eq': 'b1'},
        },
      );
    });

    test('supports WhereOp and snake_case passthrough', () {
      expect(
        buildWhereJson({'owner_id': const Eq('x')}),
        {'owner_id': {'eq': 'x'}},
      );
    });

    test('passes between operator through unchanged', () {
      expect(
        buildWhereJson({
          'date': {
            'between': ['2026-07-08T00:00:00.000Z', '2026-07-08T23:59:59.999Z'],
          },
        }),
        {
          'date': {
            'between': ['2026-07-08T00:00:00.000Z', '2026-07-08T23:59:59.999Z'],
          },
        },
      );
    });
  });
}
