class LedgerTransactionForSummary {
  const LedgerTransactionForSummary({
    required this.id,
    required this.date,
    required this.transactionType,
    required this.transactionAmount,
    this.foodOrderId,
    this.categoryName,
  });

  factory LedgerTransactionForSummary.fromMap(Map<String, dynamic> map) {
    final data = map['data'];
    final category = map['transactionCategory'];
    String? categoryName;
    if (category is Map) {
      final catData = category['data'];
      if (catData is Map) {
        categoryName = catData['name']?.toString();
      }
    }
    return LedgerTransactionForSummary(
      id: map['id']?.toString() ?? '',
      date: data is Map ? data['date']?.toString() ?? '' : '',
      transactionType:
          data is Map ? data['transaction_type']?.toString() ?? '' : '',
      transactionAmount: data is Map ? _num(data['transaction_amount']) : 0,
      foodOrderId: data is Map ? data['food_order_id']?.toString() : null,
      categoryName: categoryName,
    );
  }

  final String id;
  final String date;
  final String transactionType;
  final double transactionAmount;
  final String? foodOrderId;
  final String? categoryName;

  static double _num(Object? v) {
    if (v is num && v.isFinite) return v.abs().toDouble();
    return 0;
  }
}

class CategorySummary {
  const CategorySummary({required this.categoryName, required this.total});
  final String categoryName;
  final double total;
}

class LedgerReportTotals {
  const LedgerReportTotals({
    required this.foodProfit,
    required this.income,
    required this.expense,
  });

  final double foodProfit;
  final double income;
  final double expense;

  double get netAmount => income - expense;
  double get balance => foodProfit + income - expense;
}

const incomeTransactionTypes = {
  'food_order',
  'initial_balance',
  'deposit',
  'other_deposit',
  'income',
  'capital',
  'collectable_due',
};

const expenseTransactionTypes = {
  'withdraw',
  'expense',
  'salary',
  'giveable_due',
};

typedef LedgerCategoryLabelResolver = String Function(
  LedgerTransactionForSummary transaction,
);

String defaultIncomeCategoryLabel(LedgerTransactionForSummary t) {
  if (t.categoryName != null && t.categoryName!.isNotEmpty) {
    return t.categoryName!;
  }
  if (t.foodOrderId != null && t.foodOrderId!.isNotEmpty) return 'food_order';
  return t.transactionType.isEmpty ? 'other' : t.transactionType;
}

String defaultExpenseCategoryLabel(LedgerTransactionForSummary t) {
  if (t.categoryName != null && t.categoryName!.isNotEmpty) {
    return t.categoryName!;
  }
  return t.transactionType.isEmpty ? 'other' : t.transactionType;
}

List<CategorySummary> buildIncomeCategorySummary(
  List<LedgerTransactionForSummary> transactions, {
  LedgerCategoryLabelResolver? labelFor,
}) {
  final label = labelFor ?? defaultIncomeCategoryLabel;
  final categoryMap = <String, double>{};

  for (final t in transactions) {
    if (!incomeTransactionTypes.contains(t.transactionType)) continue;
    final amount = t.transactionAmount;
    if (amount <= 0) continue;
    final name = label(t);
    categoryMap[name] = (categoryMap[name] ?? 0) + amount;
  }

  final rows = categoryMap.entries
      .map((e) => CategorySummary(categoryName: e.key, total: e.value))
      .toList()
    ..sort((a, b) => b.total.compareTo(a.total));
  return rows;
}

List<CategorySummary> buildExpenseCategorySummary(
  List<LedgerTransactionForSummary> transactions, {
  LedgerCategoryLabelResolver? labelFor,
}) {
  final label = labelFor ?? defaultExpenseCategoryLabel;
  final categoryMap = <String, double>{};

  for (final t in transactions) {
    if (!expenseTransactionTypes.contains(t.transactionType)) continue;
    final amount = t.transactionAmount;
    if (amount <= 0) continue;
    final name = label(t);
    categoryMap[name] = (categoryMap[name] ?? 0) + amount;
  }

  final rows = categoryMap.entries
      .map((e) => CategorySummary(categoryName: e.key, total: e.value))
      .toList()
    ..sort((a, b) => b.total.compareTo(a.total));
  return rows;
}

LedgerReportTotals calculateLedgerTotals(
  List<LedgerTransactionForSummary> transactions,
) {
  var foodProfit = 0.0;
  var income = 0.0;
  var expense = 0.0;

  for (final t in transactions) {
    final amount = t.transactionAmount;
    if (t.transactionType == 'food_profit') {
      foodProfit += amount;
    } else if (incomeTransactionTypes.contains(t.transactionType) &&
        (t.transactionType != 'food_order' || t.transactionAmount > 0)) {
      if (const {
        'initial_balance',
        'deposit',
        'other_deposit',
        'income',
        'capital',
      }.contains(t.transactionType) ||
          t.transactionType == 'food_order') {
        income += amount;
      }
    } else if (expenseTransactionTypes.contains(t.transactionType)) {
      expense += amount;
    }
  }

  return LedgerReportTotals(
    foodProfit: foodProfit,
    income: income,
    expense: expense,
  );
}

bool isWithinReportDateRange(
  String isoDate,
  DateTime rangeStart,
  DateTime rangeEnd,
) {
  final parsed = DateTime.tryParse(isoDate);
  if (parsed == null) return false;
  final day = DateTime(parsed.year, parsed.month, parsed.day);
  final start = DateTime(rangeStart.year, rangeStart.month, rangeStart.day);
  final end = DateTime(rangeEnd.year, rangeEnd.month, rangeEnd.day);
  return !day.isBefore(start) && !day.isAfter(end);
}
