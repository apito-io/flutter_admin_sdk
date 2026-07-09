import 'food_name_lookup.dart';

class FoodOrderLine {
  const FoodOrderLine({
    this.foodId,
    this.size,
    this.price = 0,
    this.quantity = 1,
    this.makingCostThatTime = 0,
  });

  factory FoodOrderLine.fromMap(Map<String, dynamic> map) => FoodOrderLine(
        foodId: map['food_id']?.toString(),
        size: map['size']?.toString(),
        price: _num(map['price']),
        quantity: _num(map['quantity'], fallback: 1).round(),
        makingCostThatTime: _num(map['making_cost_that_time']),
      );

  final String? foodId;
  final String? size;
  final double price;
  final int quantity;
  final double makingCostThatTime;

  static double _num(Object? v, {double fallback = 0}) {
    if (v is num && v.isFinite) return v.toDouble();
    return fallback;
  }
}

class FoodOrderForSummary {
  const FoodOrderForSummary({
    this.id,
    this.orderNo,
    this.discountAmount = 0,
    this.foods = const [],
  });

  factory FoodOrderForSummary.fromMap(Map<String, dynamic> map) {
    final data = map['data'];
    final foodsRaw = data is Map ? data['foods'] : null;
    final foods = <FoodOrderLine>[];
    if (foodsRaw is List) {
      for (final f in foodsRaw) {
        if (f is Map<String, dynamic>) {
          foods.add(FoodOrderLine.fromMap(f));
        } else if (f is Map) {
          foods.add(FoodOrderLine.fromMap(Map<String, dynamic>.from(f)));
        }
      }
    }
    return FoodOrderForSummary(
      id: map['id']?.toString(),
      orderNo: data is Map ? data['order_no']?.toString() : null,
      discountAmount: data is Map ? _num(data['discount_amount']) : 0,
      foods: foods,
    );
  }

  final String? id;
  final String? orderNo;
  final double discountAmount;
  final List<FoodOrderLine> foods;

  static double _num(Object? v) {
    if (v is num && v.isFinite) return v.toDouble();
    return 0;
  }
}

class FoodOrderRef {
  const FoodOrderRef({required this.id, required this.orderNo});
  final String id;
  final String orderNo;
}

class FoodSizeVariant {
  const FoodSizeVariant({
    required this.foodId,
    required this.size,
    required this.count,
    required this.actualPrice,
    required this.makingCost,
    required this.profit,
    this.orderRefs = const [],
  });

  final String foodId;
  final String size;
  final int count;
  final double actualPrice;
  final double makingCost;
  final double profit;
  final List<FoodOrderRef> orderRefs;
}

class FoodSummary {
  const FoodSummary({
    required this.foodId,
    required this.foodName,
    required this.count,
    this.totalAmount = 0,
    this.totalProfit = 0,
    this.children = const [],
    this.orderRefs = const [],
  });

  final String foodId;
  final String foodName;
  final int count;
  final double totalAmount;
  final double totalProfit;
  final List<FoodSizeVariant> children;
  final List<FoodOrderRef> orderRefs;
}

class _SizeBucket {
  _SizeBucket({
    required this.count,
    required this.price,
    required this.makingCost,
  });

  int count;
  double price;
  double makingCost;
  final Map<String, String> orderRefs = {};
}

List<FoodOrderRef> _sortOrderRefs(Map<String, String> refs) {
  final entries = refs.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));
  return [
    for (final e in entries) FoodOrderRef(id: e.value, orderNo: e.key),
  ];
}

void _recordOrderRef(_SizeBucket bucket, String? orderId, String? orderNo) {
  final trimmedNo = orderNo?.trim();
  final trimmedId = orderId?.trim();
  if (trimmedNo != null &&
      trimmedNo.isNotEmpty &&
      trimmedId != null &&
      trimmedId.isNotEmpty) {
    bucket.orderRefs[trimmedNo] = trimmedId;
  }
}

double? resolveParentUnitPrice(List<FoodSizeVariant> children) {
  if (children.isEmpty) return null;
  final prices = children.map((c) => c.actualPrice).toSet();
  return prices.length == 1 ? prices.first : null;
}

List<String> collectOrderFoodIds(
  List<FoodOrderForSummary> orders,
  Set<String>? filterFoodIdSet,
) {
  final ids = <String>{};
  for (final order in orders) {
    for (final food in order.foods) {
      final foodId = food.foodId;
      if (foodId == null || foodId.isEmpty) continue;
      if (filterFoodIdSet != null && !filterFoodIdSet.contains(foodId)) {
        continue;
      }
      ids.add(foodId);
    }
  }
  return ids.toList();
}

List<FoodSummary> buildFoodOrderSummary({
  required List<FoodOrderForSummary> orders,
  Set<String>? filterFoodIdSet,
  List<String> filterFoodIds = const [],
  Map<String, String> nameLookup = const {},
  Map<String, FoodCatalogEntry> catalogLookup = const {},
  bool includeZeroSoldFoods = false,
  String standardSizeLabel = 'Standard',
}) {
  final foodSizeMap = <String, Map<String, _SizeBucket>>{};

  for (final order in orders) {
    final orderNo = order.orderNo?.trim();
    final orderId = order.id?.trim();
    for (final food in order.foods) {
      final foodId = food.foodId;
      if (foodId == null || foodId.isEmpty) continue;
      if (filterFoodIdSet != null && !filterFoodIdSet.contains(foodId)) {
        continue;
      }

      final size = (food.size == null || food.size!.isEmpty)
          ? 'default'
          : food.size!;
      final quantity = food.quantity;
      final price = food.price;
      final makingCost = food.makingCostThatTime;

      foodSizeMap.putIfAbsent(foodId, () => {});
      final sizeMap = foodSizeMap[foodId]!;

      if (!sizeMap.containsKey(size)) {
        final bucket = _SizeBucket(
          count: quantity,
          price: price,
          makingCost: makingCost,
        );
        _recordOrderRef(bucket, orderId, orderNo);
        sizeMap[size] = bucket;
      } else {
        final current = sizeMap[size]!;
        _recordOrderRef(current, orderId, orderNo);
        current.count += quantity;
        if (current.price == 0) current.price = price;
        if (makingCost != 0) current.makingCost = makingCost;
      }
    }
  }

  final summary = <FoodSummary>[];

  void appendSummaryRow(String foodId, Map<String, _SizeBucket> sizeMap) {
    final foodName = resolveFoodName(foodId, nameLookup, catalogLookup);

    final children = sizeMap.entries.map((e) {
      final sizeKey = e.key;
      final data = e.value;
      final profit = data.price - data.makingCost;
      return FoodSizeVariant(
        foodId: '$foodId-$sizeKey',
        size: sizeKey == 'default' ? standardSizeLabel : sizeKey,
        count: data.count,
        actualPrice: data.price,
        makingCost: data.makingCost,
        profit: profit,
        orderRefs: _sortOrderRefs(data.orderRefs),
      );
    }).toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    final totalCount =
        children.fold<int>(0, (sum, c) => sum + c.count);
    final totalAmount = children.fold<double>(
      0,
      (sum, c) => sum + c.count * c.actualPrice,
    );
    final totalProfit = children.fold<double>(
      0,
      (sum, c) => sum + c.count * c.profit,
    );

    final parentRefs = <String, String>{};
    for (final child in children) {
      for (final ref in child.orderRefs) {
        parentRefs[ref.orderNo] = ref.id;
      }
    }

    summary.add(
      FoodSummary(
        foodId: foodId,
        foodName: foodName,
        count: totalCount,
        totalAmount: totalAmount,
        totalProfit: totalProfit,
        children: children,
        orderRefs: _sortOrderRefs(parentRefs),
      ),
    );
  }

  for (final entry in foodSizeMap.entries) {
    appendSummaryRow(entry.key, entry.value);
  }

  if (includeZeroSoldFoods &&
      filterFoodIdSet != null &&
      filterFoodIds.isNotEmpty) {
    for (final foodId in filterFoodIds) {
      if (foodSizeMap.containsKey(foodId)) continue;
      final catalog = catalogLookup[foodId];
      appendSummaryRow(foodId, {
        'default': _SizeBucket(
          count: 0,
          price: catalog?.unitPrice ?? 0,
          makingCost: catalog?.makingCost ?? 0,
        ),
      });
    }
  }

  summary.sort((a, b) => b.count.compareTo(a.count));
  return summary;
}

class FoodOrderReportTotals {
  const FoodOrderReportTotals({
    required this.totalSales,
    required this.totalDiscount,
    required this.netAmount,
    required this.totalProfit,
    required this.totalQuantity,
    required this.orderCount,
    required this.foodTypeCount,
  });

  final double totalSales;
  final double totalDiscount;
  final double netAmount;
  final double totalProfit;
  final int totalQuantity;
  final int orderCount;
  final int foodTypeCount;

  double get averageOrderValue =>
      orderCount > 0 ? totalSales / orderCount : 0;

  double get averageProfitPerOrder =>
      orderCount > 0 ? totalProfit / orderCount : 0;

  static FoodOrderReportTotals compute({
    required List<FoodSummary> foodSummary,
    required List<FoodOrderForSummary> orders,
  }) {
    final totalSales =
        foodSummary.fold<double>(0, (s, f) => s + f.totalAmount);
    final totalProfit =
        foodSummary.fold<double>(0, (s, f) => s + f.totalProfit);
    final totalQuantity =
        foodSummary.fold<int>(0, (s, f) => s + f.count);
    final totalDiscount =
        orders.fold<double>(0, (s, o) => s + o.discountAmount);

    return FoodOrderReportTotals(
      totalSales: totalSales,
      totalDiscount: totalDiscount,
      netAmount: totalSales - totalDiscount,
      totalProfit: totalProfit,
      totalQuantity: totalQuantity,
      orderCount: orders.length,
      foodTypeCount: foodSummary.length,
    );
  }
}
