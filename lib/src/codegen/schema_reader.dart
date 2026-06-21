import 'dart:convert';

import 'package:http/http.dart' as http;

import '../runtime/naming.dart';
/// Parsed Apito field from schema introspection or JSON snapshot.
class ApitoSchemaField {
  const ApitoSchemaField({
    required this.name,
    required this.graphqlType,
    this.required = false,
    this.isList = false,
    this.isEnum = false,
    this.enumValues = const [],
    this.isMedia = false,
  });

  final String name;
  final String graphqlType;
  final bool required;
  final bool isList;
  final bool isEnum;
  final List<String> enumValues;

  /// Apito media fields require GraphQL sub-selection — omit from list/get queries.
  final bool isMedia;

  String get dartType => _mapGraphqlToDart(graphqlType, isList: isList);

  static String _mapGraphqlToDart(String type, {required bool isList}) {
    final base = switch (type.replaceAll('!', '')) {
      'String' => 'String',
      'Int' => 'int',
      'Float' => 'double',
      'Boolean' => 'bool',
      'DateTime' => 'DateTime',
      'JSON' => 'Map<String, dynamic>',
      _ => 'String',
    };
    return isList ? 'List<$base>' : base;
  }
}

/// Parsed Apito model definition.
class ApitoSchemaModel {
  const ApitoSchemaModel({
    required this.name,
    required this.fields,
    this.relations = const [],
    this.sortFieldNames = const [],
  });

  final String name;
  final List<ApitoSchemaField> fields;
  final List<String> relations;
  final List<String> sortFieldNames;

  List<String> get fieldNames => fields.map((f) => f.name).toList();

  /// Scalar/list fields safe for secured list/get `.select()` (excludes media).
  List<String> get queryFieldNames => fields
      .where((f) => f.name != 'id' && !f.isMedia)
      .map((f) => f.name)
      .toList();
}

/// Picks a schema-safe default sort field (never assumes `created_at` exists).
String? apitoDefaultSortField(List<String> sortFieldNames) {
  if (sortFieldNames.isEmpty) return null;
  for (final candidate in ['created_at', 'updated_at', 'name', 'uid']) {
    if (sortFieldNames.contains(candidate)) return candidate;
  }
  return sortFieldNames.first;
}

/// Full parsed schema.
class ApitoSchema {
  const ApitoSchema({required this.models});

  final List<ApitoSchemaModel> models;

  ApitoSchemaModel? modelNamed(String name) {
    for (final m in models) {
      if (m.name == name) return m;
    }
    return null;
  }
}

const _introspectionQuery = r'''
query IntrospectionQuery {
  __schema {
    queryType {
      name
      fields {
        name
      }
    }
    types {
      kind
      name
      fields {
        name
        type {
          kind
          name
          ofType {
            kind
            name
            ofType {
              kind
              name
              ofType { kind name }
            }
          }
        }
      }
      inputFields {
        name
        type {
          kind
          name
          ofType {
            kind
            name
            ofType { kind name ofType { kind name } }
          }
        }
      }
      enumValues { name }
    }
  }
}
''';

class SchemaReader {
  SchemaReader({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  final http.Client _http;

  Future<ApitoSchema> fetchFromEndpoint({
    required String endpoint,
    required String apiKey,
    String? tenantId,
    List<String>? modelFilter,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (apiKey.isNotEmpty) 'X-Apito-Key': apiKey,
      if (tenantId != null && tenantId.isNotEmpty) 'X-Apito-Tenant-ID': tenantId,
    };

    final response = await _http.post(
      Uri.parse(endpoint),
      headers: headers,
      body: jsonEncode({'query': _introspectionQuery}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Introspection failed: HTTP ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final errors = decoded['errors'];
    if (errors != null) {
      throw StateError('Introspection GraphQL errors: $errors');
    }

    return parseIntrospection(decoded, modelFilter: modelFilter);
  }

  ApitoSchema parseJsonFile(String jsonSource, {List<String>? modelFilter}) {
    final decoded = jsonDecode(jsonSource);
    if (decoded is Map && decoded.containsKey('models')) {
      return _parseSimpleJson(decoded as Map<String, dynamic>, modelFilter: modelFilter);
    }
    return parseIntrospection(decoded as Map<String, dynamic>, modelFilter: modelFilter);
  }

  ApitoSchema parseIntrospection(
    Map<String, dynamic> introspection, {
    List<String>? modelFilter,
  }) {
    final schema = introspection['data']?['__schema'] as Map<String, dynamic>?;
    if (schema == null) {
      return parseSimpleJson(introspection, modelFilter: modelFilter);
    }

    final types = (schema['types'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();

    final queryTypeBlock = schema['queryType'] as Map<String, dynamic>? ?? {};
    final queryFields = (queryTypeBlock['fields'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();

    final listFields = queryFields.where((f) {
      final name = f['name'] as String;
      return name.endsWith('List') && !name.endsWith('ListCount');
    });

    final models = <ApitoSchemaModel>[];
    for (final listField in listFields) {
      final listName = listField['name'] as String;
      final modelName = _listFieldToModelName(listName);
      if (modelFilter != null &&
          modelFilter.isNotEmpty &&
          !modelFilter.contains(modelName)) {
        continue;
      }

      final createPayloadName = _findCreatePayloadType(types, listName);
      final fields = createPayloadName != null
          ? _fieldsFromInputType(types, createPayloadName)
          : _defaultFields();
      final sortPayloadName = _findSortPayloadType(types, modelName);
      final sortFieldNames = sortPayloadName != null
          ? _fieldNamesFromInputType(types, sortPayloadName)
          : const <String>[];

      models.add(ApitoSchemaModel(
        name: modelName,
        fields: fields,
        sortFieldNames: sortFieldNames,
      ));
    }

    models.sort((a, b) => a.name.compareTo(b.name));
    return ApitoSchema(models: models);
  }

  ApitoSchema parseSimpleJson(
    Map<String, dynamic> json, {
    List<String>? modelFilter,
  }) =>
      _parseSimpleJson(json, modelFilter: modelFilter);

  ApitoSchema _parseSimpleJson(
    Map<String, dynamic> json, {
    List<String>? modelFilter,
  }) {
    final rawModels = (json['models'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    final models = <ApitoSchemaModel>[];

    for (final raw in rawModels) {
      final name = raw['name'] as String;
      if (modelFilter != null &&
          modelFilter.isNotEmpty &&
          !modelFilter.contains(name)) {
        continue;
      }
      final fieldsRaw = (raw['fields'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      final fields = fieldsRaw
          .map(
            (f) {
              final rawType = f['type'] as String? ?? 'string';
              final graphqlType = _simpleTypeToGraphql(rawType);
              return ApitoSchemaField(
                name: f['name'] as String,
                graphqlType: graphqlType,
                required: f['required'] as bool? ?? false,
                isList: f['is_list'] as bool? ?? false,
                isEnum: f['enum_values'] != null,
                enumValues: (f['enum_values'] as List<dynamic>? ?? [])
                    .map((e) => e.toString())
                    .toList(),
                isMedia:
                    _isMediaGraphqlType(rawType) || _isMediaGraphqlType(graphqlType),
              );
            },
          )
          .toList();
      models.add(
        ApitoSchemaModel(
          name: name,
          fields: fields,
          relations: (raw['relations'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList(),
          sortFieldNames: (raw['sort_fields'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList(),
        ),
      );
    }

    return ApitoSchema(models: models);
  }

  String _listFieldToModelName(String listFieldName) {
    if (listFieldName.endsWith('List')) {
      final camel = listFieldName.substring(0, listFieldName.length - 4);
      return _camelToSnake(camel);
    }
    return listFieldName;
  }

  String _camelToSnake(String input) {
    final buffer = StringBuffer();
    for (var i = 0; i < input.length; i++) {
      final ch = input[i];
      if (ch == ch.toUpperCase() && i > 0) {
        buffer.write('_');
      }
      buffer.write(ch.toLowerCase());
    }
    return buffer.toString();
  }

  String? _findSortPayloadType(
    List<Map<String, dynamic>> types,
    String modelName,
  ) {
    final expected = apitoSortInputType(modelName);
    for (final t in types) {
      if (t['name'] == expected) return expected;
    }
    return null;
  }

  List<String> _fieldNamesFromInputType(
    List<Map<String, dynamic>> types,
    String typeName,
  ) {
    final typeDef = types.firstWhere(
      (t) => t['name'] == typeName,
      orElse: () => <String, dynamic>{},
    );
    final inputFields = (typeDef['inputFields'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    return inputFields
        .map((f) => f['name'] as String)
        .where((name) => !name.startsWith('_'))
        .toList();
  }

  String? _findCreatePayloadType(
    List<Map<String, dynamic>> types,
    String listFieldName,
  ) {
    final modelName = _listFieldToModelName(listFieldName);
    final expected = apitoGraphQLComposedTypeName(modelName, 'Create_Payload');
    for (final t in types) {
      if (t['name'] == expected) return expected;
    }
    for (final t in types) {
      final name = t['name'] as String?;
      if (name == null) continue;
      if (!name.endsWith('_Create_Payload')) continue;
      if (name.toLowerCase() ==
          expected.replaceAll('_', '').toLowerCase()) {
        return name;
      }
    }
    return null;
  }

  List<ApitoSchemaField> _fieldsFromInputType(
    List<Map<String, dynamic>> types,
    String typeName,
  ) {
    final typeDef = types.firstWhere(
      (t) => t['name'] == typeName,
      orElse: () => <String, dynamic>{},
    );
    final inputFields = (typeDef['inputFields'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    if (inputFields.isEmpty) return _defaultFields();

    return inputFields
        .where((f) => !(f['name'] as String).startsWith('_'))
        .map((f) {
      final name = f['name'] as String;
      final typeInfo = _unwrapType(f['type'] as Map<String, dynamic>?);
      final enumValues = _enumValuesForType(types, typeInfo.graphqlType);
      final graphqlType = typeInfo.graphqlType;
      return ApitoSchemaField(
        name: name,
        graphqlType: graphqlType,
        required: typeInfo.required,
        isList: typeInfo.isList,
        isEnum: enumValues.isNotEmpty,
        enumValues: enumValues,
        isMedia: _isMediaGraphqlType(graphqlType),
      );
    }).toList();
  }

  List<String> _enumValuesForType(
    List<Map<String, dynamic>> types,
    String typeName,
  ) {
    for (final t in types) {
      if (t['name'] != typeName) continue;
      if (t['kind'] != 'ENUM') return const [];
      return (t['enumValues'] as List<dynamic>? ?? [])
          .map((e) => (e as Map)['name'] as String)
          .toList();
    }
    return const [];
  }

  _UnwrappedType _unwrapType(Map<String, dynamic>? type) {
    if (type == null) {
      return const _UnwrappedType(graphqlType: 'String');
    }
    final kind = type['kind'] as String?;
    if (kind == 'NON_NULL') {
      final inner = _unwrapType(type['ofType'] as Map<String, dynamic>?);
      return _UnwrappedType(
        graphqlType: inner.graphqlType,
        required: true,
        isList: inner.isList,
      );
    }
    if (kind == 'LIST') {
      final inner = _unwrapType(type['ofType'] as Map<String, dynamic>?);
      return _UnwrappedType(
        graphqlType: inner.graphqlType,
        required: inner.required,
        isList: true,
      );
    }
    return _UnwrappedType(graphqlType: type['name'] as String? ?? 'String');
  }

  List<ApitoSchemaField> _defaultFields() => const [
        ApitoSchemaField(name: 'id', graphqlType: 'String', required: true),
      ];

  static bool _isMediaGraphqlType(String graphqlType) {
    return graphqlType.contains('MediaInput') ||
        graphqlType.contains('MediaField') ||
        graphqlType.contains('SingleMedia');
  }

  String _simpleTypeToGraphql(String type) {
    return switch (type.toLowerCase()) {
      'text' || 'string' || 'dropdown' => 'String',
      'int' || 'number' => 'Int',
      'double' || 'float' => 'Float',
      'bool' || 'boolean' => 'Boolean',
      'date' || 'datetime' => 'DateTime',
      'json' => 'JSON',
      _ => 'String',
    };
  }
}

class _UnwrappedType {
  const _UnwrappedType({
    required this.graphqlType,
    this.required = false,
    this.isList = false,
  });

  final String graphqlType;
  final bool required;
  final bool isList;
}

/// Minimal SDL parser: extracts `type X { field: Type }` blocks.
ApitoSchema parseSdl(String sdl, {List<String>? modelFilter}) {
  final typeRe = RegExp(
    r'type\s+(\w+)\s*\{([^}]*)\}',
    multiLine: true,
  );
  final fieldRe = RegExp(r'(\w+)\s*:\s*([\w\[\]!]+)');

  final models = <ApitoSchemaModel>[];
  for (final match in typeRe.allMatches(sdl)) {
    final typeName = match.group(1)!;
    if (!typeName.endsWith('List')) continue;
    if (typeName.endsWith('ListCount')) continue;

    final modelName = typeName.substring(0, typeName.length - 4);
    final snake = modelName.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (m) => '${m[1]}_${m[2]}',
    ).toLowerCase();

    if (modelFilter != null &&
        modelFilter.isNotEmpty &&
        !modelFilter.contains(snake)) {
      continue;
    }

    final body = match.group(2)!;
    final fields = <ApitoSchemaField>[];
    for (final fieldMatch in fieldRe.allMatches(body)) {
      final fieldName = fieldMatch.group(1)!;
      if (fieldName == 'id' || fieldName == 'data' || fieldName == 'meta') {
        continue;
      }
      final rawType = fieldMatch.group(2)!;
      final isList = rawType.startsWith('[');
      final graphqlType = rawType.replaceAll(RegExp(r'[\[\]!]'), '');
      fields.add(
        ApitoSchemaField(
          name: fieldName,
          graphqlType: graphqlType,
          isList: isList,
        ),
      );
    }

    if (fields.isEmpty) {
      fields.add(const ApitoSchemaField(name: 'id', graphqlType: 'String'));
    }

    models.add(ApitoSchemaModel(name: snake, fields: fields));
  }

  return ApitoSchema(models: models);
}
