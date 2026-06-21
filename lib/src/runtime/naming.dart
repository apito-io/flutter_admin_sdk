/// Apito model naming aligned with refine-apito / Go `apito_naming.go`.
library;

const _singularKeepAsIs = {'news', 'data', 'media', 'analytics', 'series', 'species'};
final _canonicalIdRe = RegExp(r'^[a-z][a-z0-9]*(?:_[a-z0-9]+)*$');
const _unsafeDynamicKeys = {'__proto__', 'constructor', 'prototype'};

void rejectRunOnLowercaseConcat(String raw) {
  if (RegExp(r'[\s_\-]').hasMatch(raw)) return;
  if (RegExp(r'[a-z][A-Z]').hasMatch(raw)) return;
  if (!RegExp(r'^[a-z]+$').hasMatch(raw)) return;
  if (raw.length >= 9) {
    throw ArgumentError(
      'model name needs a word boundary between words: use food_order, '
      'food-order, foodOrder, or "food order"',
    );
  }
}

List<String> splitCamelPieces(String piece) {
  final spaced = piece.replaceAllMapped(
    RegExp(r'([a-z0-9])([A-Z])'),
    (m) => '${m[1]} ${m[2]}',
  );
  return spaced
      .split(RegExp(r'\s+'))
      .where((s) => s.isNotEmpty)
      .map((s) => s.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase())
      .where((s) => s.isNotEmpty)
      .toList();
}

List<String> splitIntoWordSegments(String raw) {
  final normalized = raw.trim().replaceAll('-', '_');
  final chunks = normalized.split(RegExp(r'[\s_]+')).where((c) => c.isNotEmpty);
  final segments = <String>[];
  for (final chunk in chunks) {
    final lettersOnly = chunk.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    final pieces = lettersOnly == chunk
        ? splitCamelPieces(chunk)
        : [lettersOnly.toLowerCase()];
    for (final p in pieces) {
      final s = p.replaceAll(RegExp(r'[^a-z0-9]', caseSensitive: false), '').toLowerCase();
      if (s.isNotEmpty) segments.add(s);
    }
  }
  return segments;
}

String singularizeSegment(String seg) {
  if (_singularKeepAsIs.contains(seg)) return seg;
  if (seg.endsWith('ies') && seg.length > 3) {
    return '${seg.substring(0, seg.length - 3)}y';
  }
  if (seg.endsWith('ses') && seg.length > 3) return seg.substring(0, seg.length - 2);
  if (seg.endsWith('s') && seg.length > 1 && !seg.endsWith('ss')) {
    return seg.substring(0, seg.length - 1);
  }
  return seg;
}

void reservedCheck(String canonical) {
  switch (canonical) {
    case 'list':
      throw ArgumentError(
        'naming a Model `List` is not allowed. Apito uses List for plural resources.',
      );
    case 'user':
      throw ArgumentError(
        'naming a Model `User` is protected. Add the Authentication module from Settings.',
      );
    case 'system':
      throw ArgumentError('naming a Model `System` is not allowed.');
    case 'function':
      throw ArgumentError('naming a Model `Function` is not allowed.');
  }
}

String canonicalizeModelName(String raw) {
  final t = raw.trim();
  if (t.isEmpty) throw ArgumentError('model name is required');
  rejectRunOnLowercaseConcat(t);
  final segments = splitIntoWordSegments(t);
  if (segments.isEmpty) throw ArgumentError('invalid model name');
  segments[segments.length - 1] = singularizeSegment(segments.last);
  final out = segments.join('_');
  if (!_canonicalIdRe.hasMatch(out)) throw ArgumentError('invalid model name');
  reservedCheck(out);
  return out;
}

String camelFromCanonical(String canonical) {
  final parts = canonical.split('_').where((p) => p.isNotEmpty).toList();
  return parts.asMap().entries.map((e) {
    final p = e.value;
    if (e.key == 0) return p.toLowerCase();
    return p[0].toUpperCase() + p.substring(1).toLowerCase();
  }).join();
}

String pascalFromCanonical(String canonical) {
  return canonical
      .split('_')
      .where((p) => p.isNotEmpty)
      .map((p) => p[0].toUpperCase() + p.substring(1).toLowerCase())
      .join();
}

String pascalFromAnyModelId(String modelId) {
  if (modelId.isEmpty) return '';
  if (modelId.contains('_')) return pascalFromCanonical(modelId);
  return splitCamelPieces(modelId)
      .map((s) => s[0].toUpperCase() + s.substring(1).toLowerCase())
      .join();
}

String listGraphQLTypeName(String modelId) {
  return '${pascalFromAnyModelId(apitoSingularResourceName(modelId))}List';
}

String apitoGraphQLComposedTypeName(String modelId, String suffix) {
  final singular = apitoSingularResourceName(modelId);
  final suf = suffix.replaceFirst(RegExp(r'^_'), '').split('_').where((s) => s.isNotEmpty);
  final modelSegs = singular.contains('_')
      ? singular.split('_').where((s) => s.isNotEmpty).toList()
      : splitCamelPieces(singular).map((s) => s.toLowerCase()).toList();
  final extra = suf.expand((chunk) => splitCamelPieces(chunk).map((x) => x.toLowerCase()));
  return [...modelSegs, ...extra]
      .map((p) => p[0].toUpperCase() + p.substring(1).toLowerCase())
      .join('_');
}

String apitoSingularResourceName(String name) {
  var t = name.trim();
  if (t.endsWith('ListCount')) {
    t = t.substring(0, t.length - 'ListCount'.length);
  } else if (t.endsWith('List')) {
    t = t.substring(0, t.length - 'List'.length);
  }
  t = t.trim();
  if (t.isEmpty) return '';
  if (t.contains('_')) return camelFromCanonical(t);
  final segs = splitCamelPieces(t);
  if (segs.isEmpty) return t.toLowerCase();
  return segs.asMap().entries.map((e) {
    final s = e.value;
    if (e.key == 0) return s.toLowerCase();
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }).join();
}

String apitoModelName(String name) => apitoSingularResourceName(name);

String apitoMultipleResourceName(String name) {
  return '${apitoSingularResourceName(name)}List';
}

String apitoConnectionFieldNameForRelation(
  String relatedModelRef,
  String relation,
) {
  if (relation == 'has_many') {
    return apitoMultipleResourceName(relatedModelRef);
  }
  return apitoSingularResourceName(relatedModelRef);
}

String apitoGraphqlConnectionFieldFromMetaKey(String key) {
  final k = key.trim();
  if (k.isEmpty) return k;
  if (k.contains('_')) return apitoSingularResourceName(k);
  if (RegExp(r'List$', caseSensitive: false).hasMatch(k) &&
      !RegExp(r'ListCount$', caseSensitive: false).hasMatch(k)) {
    return k[0].toLowerCase() + k.substring(1);
  }
  return apitoSingularResourceName(k);
}

String apitoGraphQLTypeNameForFilterArg(String modelId) => listGraphQLTypeName(modelId);

String apitoListGraphQLTypeName(String resource) => listGraphQLTypeName(resource);

String apitoListCountGraphQLTypeName(String resource) {
  return apitoGraphQLComposedTypeName(resource, 'List_Count');
}

String apitoSingularGraphQLTypeName(String resource) {
  return pascalFromAnyModelId(apitoSingularResourceName(resource));
}

String apitoStoredSnakeModelId(String resource) {
  final singular = apitoSingularResourceName(resource);
  if (singular.contains('_')) return singular;
  return splitCamelPieces(singular).join('_');
}

/// Apito GraphQL where/sort field identifier (snake_case), aligned with codegen Where types.
String apitoFieldIdentifier(String raw) {
  final key = raw.trim();
  if (key.isEmpty) return key;
  if (key == 'OR' || key == 'AND' || key == 'relation' || key == '_key') {
    return key;
  }
  if (key.contains('_')) {
    return key.toLowerCase();
  }
  final pieces = splitCamelPieces(key);
  if (pieces.isEmpty) return key.toLowerCase();
  return pieces.join('_').toLowerCase();
}

String apitoMutationConnectHasOneIdField(String relatedModelRef) {
  return '${apitoStoredSnakeModelId(relatedModelRef)}_id';
}

String apitoMutationConnectHasManyIdsField(String relatedModelRef) {
  return '${apitoStoredSnakeModelId(relatedModelRef)}_ids';
}

String apitoConnectionFilterConditionType(String resource) {
  return '${apitoStoredSnakeModelId(resource)}_Connection_Filter_Condition'.toUpperCase();
}

String apitoWhereRelationFilterConditionType(String resource) {
  return '${apitoStoredSnakeModelId(resource)}_Where_Relation_Filter_Condition'.toUpperCase();
}

String apitoWhereInputType(String resource) {
  return '${listGraphQLTypeName(resource)}_Input_Where_Payload'.toUpperCase();
}

String apitoSortInputType(String resource) {
  return '${listGraphQLTypeName(resource)}_Input_Sort_Payload'.toUpperCase();
}

String apitoListKeyConditionType(String resource) {
  return '${listGraphQLTypeName(resource)}_Key_Condition'.toUpperCase();
}

String apitoListCountKeyConditionType(String resource) {
  return '${apitoGraphQLComposedTypeName(resource, 'List_Count')}_Key_Condition'.toUpperCase();
}

String apitoListCountWhereInputType(String resource) {
  return '${apitoGraphQLComposedTypeName(resource, 'List_Count')}_Input_Where_Payload'.toUpperCase();
}

String apitoListCountSortInputType(String resource) {
  return '${apitoGraphQLComposedTypeName(resource, 'List_Count')}_Input_Sort_Payload'.toUpperCase();
}

String formatApitoConnectionSubselections(
  Map<String, String> connectionFields, [
  Map<String, String> aliasFields = const {},
]) {
  return connectionFields.keys.map((key) {
    final selection = connectionFields[key]!;
    final rawTarget = aliasFields[key];
    final hasExplicitAlias =
        rawTarget != null && rawTarget.trim().isNotEmpty;

    final targetField = apitoGraphqlConnectionFieldFromMetaKey(
      hasExplicitAlias ? rawTarget.trim() : key,
    );

    if (hasExplicitAlias) {
      final responseKey = key;
      if (responseKey == targetField) {
        return '$targetField { $selection }';
      }
      return '$responseKey: $targetField { $selection }';
    }
    return '$targetField { $selection }';
  }).join('\n');
}

String buildApitoCreateMutation(String resource, List<String> fields) {
  final id = apitoSingularResourceName(resource);
  final pascal = pascalFromAnyModelId(id);
  final payload = apitoGraphQLComposedTypeName(id, 'Create_Payload');
  final rel = apitoGraphQLComposedTypeName(id, 'Relation_Connect_Payload');
  return '''
mutation Create$pascal(\$payload: $payload!, \$connect: $rel) {
  create$pascal(payload: \$payload, connect: \$connect, status: published) {
    id
    data {
      ${fields.join('\n      ')}
    }
    meta {
      created_at
      status
      updated_at
    }
  }
}''';
}

bool isSafeDynamicKey(String key) {
  return key.isNotEmpty && !_unsafeDynamicKeys.contains(key);
}

Map<String, dynamic> emptyDynamicMap() => <String, dynamic>{};
