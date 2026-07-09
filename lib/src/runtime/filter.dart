/// Typed where-clause operators for Apito filters.
library;

import 'naming.dart';

abstract class WhereOp<T> {
  const WhereOp(this.operator, this.value);

  final String operator;
  final T value;

  Map<String, dynamic> toJson() => {operator: value};
}

class Eq<T> extends WhereOp<T> {
  const Eq(T value) : super('eq', value);
}

class Ne<T> extends WhereOp<T> {
  const Ne(T value) : super('ne', value);
}

class Gt<T> extends WhereOp<T> {
  const Gt(T value) : super('gt', value);
}

class Gte<T> extends WhereOp<T> {
  const Gte(T value) : super('gte', value);
}

class Lt<T> extends WhereOp<T> {
  const Lt(T value) : super('lt', value);
}

class Lte<T> extends WhereOp<T> {
  const Lte(T value) : super('lte', value);
}

class Contains extends WhereOp<String> {
  const Contains(String value) : super('contains', value);
}

class In<T> extends WhereOp<List<T>> {
  const In(List<T> value) : super('in', value);
}

class NotIn<T> extends WhereOp<List<T>> {
  const NotIn(List<T> value) : super('not_in', value);
}

const _logicalKeys = {'OR', 'AND'};
const _reservedKeys = {'relation', '_key'};
const _operatorKeys = {
  'eq',
  'ne',
  'gt',
  'gte',
  'lt',
  'lte',
  'contains',
  'in',
  'not_in',
  'between',
  'nbetween',
};

bool _isOperatorMap(Map<dynamic, dynamic> map) =>
    map.isNotEmpty && map.keys.every((k) => _operatorKeys.contains(k));

/// Converts field keys (camelCase or snake_case) to Apito where JSON.
Map<String, dynamic> buildWhereJson(Map<String, dynamic> where) {
  final out = <String, dynamic>{};
  for (final entry in where.entries) {
    final rawKey = entry.key;
    final value = entry.value;
    if (value == null) continue;

    if (_reservedKeys.contains(rawKey)) {
      out[rawKey] = _normalizeWhereValue(value);
      continue;
    }

    final key = apitoFieldIdentifier(rawKey);

    if (_logicalKeys.contains(key) && value is Map) {
      out[key] = buildWhereJson(Map<String, dynamic>.from(value));
      continue;
    }

    if (value is WhereOp) {
      out[key] = value.toJson();
    } else if (value is Map) {
      final map = Map<String, dynamic>.from(value);
      out[key] = _isOperatorMap(map) ? map : buildWhereJson(map);
    } else {
      out[key] = {'eq': value};
    }
  }
  return out;
}

dynamic _normalizeWhereValue(dynamic value) {
  if (value is WhereOp) return value.toJson();
  if (value is Map) {
    final map = Map<String, dynamic>.from(value);
    if (_isOperatorMap(map)) return map;
    return buildWhereJson(map);
  }
  return value;
}
