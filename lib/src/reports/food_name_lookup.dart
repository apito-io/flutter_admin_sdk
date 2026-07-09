const deletedFoodLabel = 'Deleted food';

class FoodCatalogEntry {
  const FoodCatalogEntry({
    required this.name,
    required this.unitPrice,
    required this.makingCost,
  });

  final String name;
  final double unitPrice;
  final double makingCost;
}

double _readNumber(Object? value) {
  if (value is num && value.isFinite) return value.toDouble();
  return 0;
}

FoodCatalogEntry? foodRecordToCatalogEntry(Map<String, dynamic>? food) {
  if (food == null) return null;
  final id = food['id']?.toString();
  final data = food['data'];
  if (id == null || id.isEmpty || data is! Map) return null;
  final name = data['name']?.toString().trim() ?? '';
  if (name.isEmpty) return null;

  final sizes = data['sizes'];
  if (sizes is List && sizes.isNotEmpty) {
    final first = sizes.first;
    if (first is Map) {
      return FoodCatalogEntry(
        name: name,
        unitPrice: _readNumber(first['price'] ?? data['price']),
        makingCost: _readNumber(first['making_cost']),
      );
    }
  }

  return FoodCatalogEntry(
    name: name,
    unitPrice: _readNumber(data['price']),
    makingCost: 0,
  );
}

Map<String, String> buildFoodNameLookupFromOrders(
  List<Map<String, dynamic>> orders,
) {
  final lookup = <String, String>{};
  for (final order in orders) {
    final foodList = order['foodList'];
    if (foodList is! List) continue;
    for (final food in foodList) {
      if (food is! Map) continue;
      final id = food['id']?.toString();
      final data = food['data'];
      final name = data is Map ? data['name']?.toString().trim() : null;
      if (id != null && name != null && name.isNotEmpty) {
        lookup[id] = name;
      }
    }
  }
  return lookup;
}

void applyFoodRecordsToLookup(
  Map<String, String> lookup,
  List<Map<String, dynamic>>? records,
) {
  if (records == null) return;
  for (final food in records) {
    final entry = foodRecordToCatalogEntry(food);
    if (entry != null) {
      lookup[food['id']?.toString() ?? ''] = entry.name;
    }
  }
}

void applyFoodRecordsToCatalog(
  Map<String, FoodCatalogEntry> lookup,
  List<Map<String, dynamic>>? records,
) {
  if (records == null) return;
  for (final food in records) {
    final id = food['id']?.toString();
    final entry = foodRecordToCatalogEntry(food);
    if (id != null && entry != null) {
      lookup[id] = entry;
    }
  }
}

String resolveFoodName(
  String foodId,
  Map<String, String> nameLookup, [
  Map<String, FoodCatalogEntry>? catalogLookup,
]) {
  final name = nameLookup[foodId];
  if (name != null && name.isNotEmpty) return name;
  final catalogName = catalogLookup?[foodId]?.name;
  if (catalogName != null && catalogName.isNotEmpty) return catalogName;
  return deletedFoodLabel;
}

const foodLookupBatchSize = 100;

List<List<String>> chunkIds(List<String> ids, [int size = foodLookupBatchSize]) {
  if (ids.length <= size) return [ids];
  final chunks = <List<String>>[];
  for (var i = 0; i < ids.length; i += size) {
    chunks.add(ids.sublist(i, i + size > ids.length ? ids.length : i + size));
  }
  return chunks;
}
