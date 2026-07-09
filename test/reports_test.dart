import 'package:flutter_admin_sdk/reports.dart';
import 'package:test/test.dart';

void main() {
  group('buildFoodOrderSummary', () {
    test('groups by food and size with profit', () {
      final orders = [
        FoodOrderForSummary.fromMap({
          'id': 'o1',
          'data': {
            'order_no': 'O-1',
            'discount_amount': 10,
            'foods': [
              {
                'food_id': 'f1',
                'size': 'L',
                'price': 100,
                'quantity': 2,
                'making_cost_that_time': 40,
              },
            ],
          },
        }),
      ];

      final summary = buildFoodOrderSummary(
        orders: orders,
        nameLookup: {'f1': 'Biryani'},
      );

      expect(summary, hasLength(1));
      expect(summary.first.foodName, 'Biryani');
      expect(summary.first.count, 2);
      expect(summary.first.totalAmount, 200);
      expect(summary.first.totalProfit, 120);

      final totals = FoodOrderReportTotals.compute(
        foodSummary: summary,
        orders: orders,
      );
      expect(totals.totalSales, 200);
      expect(totals.totalDiscount, 10);
      expect(totals.netAmount, 190);
      expect(totals.orderCount, 1);
    });
  });

  group('ledger report', () {
    test('calculates income expense and food profit', () {
      final rows = [
        LedgerTransactionForSummary.fromMap({
          'id': '1',
          'data': {
            'date': '2026-07-08T06:00:00.000Z',
            'transaction_type': 'food_order',
            'transaction_amount': 500,
          },
        }),
        LedgerTransactionForSummary.fromMap({
          'id': '2',
          'data': {
            'date': '2026-07-08T06:00:00.000Z',
            'transaction_type': 'expense',
            'transaction_amount': -200,
          },
        }),
        LedgerTransactionForSummary.fromMap({
          'id': '3',
          'data': {
            'date': '2026-07-08T06:00:00.000Z',
            'transaction_type': 'food_profit',
            'transaction_amount': 150,
          },
        }),
      ];

      final totals = calculateLedgerTotals(rows);
      expect(totals.income, 500);
      expect(totals.expense, 200);
      expect(totals.foodProfit, 150);
      expect(totals.netAmount, 300);
    });
  });
}
