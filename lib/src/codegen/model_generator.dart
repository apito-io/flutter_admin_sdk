import '../runtime/naming.dart';
import 'schema_reader.dart';

class ModelGenerator {
  const ModelGenerator();

  String _defaultSortFieldLiteral(ApitoSchemaModel model) {
    final pick = apitoDefaultSortField(model.sortFieldNames);
    if (pick == null) return 'null';
    return "'$pick'";
  }

  String generateModelFile(ApitoSchemaModel model) {
    final className = apitoSingularGraphQLTypeName(model.name);
    final buffer = StringBuffer();
    buffer.writeln('// AUTO-GENERATED — DO NOT EDIT');
    buffer.writeln("import 'package:flutter_admin_sdk/flutter_admin_sdk.dart';");
    buffer.writeln();

    for (final field in model.fields) {
      if (field.isEnum && field.enumValues.isNotEmpty) {
        buffer.writeln(_generateEnum(field));
        buffer.writeln();
      }
    }

    buffer.writeln('class $className implements ApitoModel {');
    buffer.writeln('  const $className({');
    buffer.writeln('    required this.id,');
    for (final field in model.fields) {
      if (field.name == 'id') continue;
      final dartField = _dartFieldName(field.name);
      if (field.required) {
        buffer.writeln('    required this.$dartField,');
      } else {
        buffer.writeln('    this.$dartField,');
      }
    }
    buffer.writeln('  });');
    buffer.writeln();
    buffer.writeln('  @override');
    buffer.writeln('  final String id;');
    for (final field in model.fields) {
      if (field.name == 'id') continue;
      final dartType = field.isEnum
          ? _enumClassName(field.name)
          : field.dartType;
      final nullable = field.required ? '' : '?';
      buffer.writeln('  final $dartType$nullable ${_dartFieldName(field.name)};');
    }

    buffer.writeln();
    buffer.writeln("  static const modelName = '${model.name}';");
    buffer.writeln('  static List<String> get allFields => const [');
    for (final field in model.fields) {
      if (field.name == 'id') continue;
      buffer.writeln("    '${field.name}',");
    }
    buffer.writeln('  ];');
    buffer.writeln();
    buffer.writeln('  /// Secured list/get selection — excludes media fields (need sub-selection).');
    buffer.writeln('  static List<String> get queryFields => const [');
    for (final field in model.fields) {
      if (field.name == 'id' || field.isMedia) continue;
      buffer.writeln("    '${field.name}',");
    }
    buffer.writeln('  ];');
    buffer.writeln();
    buffer.writeln('  /// Sortable fields from schema list sort payload.');
    buffer.writeln('  static List<String> get sortFields => const [');
    for (final name in model.sortFieldNames) {
      buffer.writeln("    '$name',");
    }
    buffer.writeln('  ];');
    buffer.writeln();
    buffer.writeln('  /// Default list sort when caller omits sortBy (schema-safe).');
    buffer.writeln(
      '  static const String? defaultSortField = ${_defaultSortFieldLiteral(model)};',
    );
    buffer.writeln();

    buffer.writeln('  factory $className.fromJson(Map<String, dynamic> json) {');
    buffer.writeln('    return $className(');
    buffer.writeln("      id: json['id']?.toString() ?? '',");
    for (final field in model.fields) {
      if (field.name == 'id') continue;
      buffer.writeln(
        '      ${_dartFieldName(field.name)}: ${_fromJsonExpr(field)},',
      );
    }
    buffer.writeln('    );');
    buffer.writeln('  }');
    buffer.writeln();

    buffer.writeln('  @override');
    buffer.writeln('  Map<String, dynamic> toJson() {');
    buffer.writeln('    return {');
    for (final field in model.fields) {
      if (field.name == 'id') continue;
      final dartField = _dartFieldName(field.name);
      if (field.isEnum) {
        buffer.writeln("      '${field.name}': $dartField?.name,");
      } else if (field.dartType == 'DateTime') {
        buffer.writeln(
          "      '${field.name}': $dartField?.toIso8601String(),",
        );
      } else {
        buffer.writeln("      '${field.name}': $dartField,");
      }
    }
    buffer.writeln('    };');
    buffer.writeln('  }');
    buffer.writeln();

    buffer.writeln('  $className copyWith({');
    buffer.writeln('    String? id,');
    for (final field in model.fields) {
      if (field.name == 'id') continue;
      final dartType = field.isEnum
          ? _enumClassName(field.name)
          : field.dartType;
      buffer.writeln('    $dartType? ${_dartFieldName(field.name)},');
    }
    buffer.writeln('  }) {');
    buffer.writeln('    return $className(');
    buffer.writeln('      id: id ?? this.id,');
    for (final field in model.fields) {
      if (field.name == 'id') continue;
      final dartField = _dartFieldName(field.name);
      buffer.writeln('      $dartField: $dartField ?? this.$dartField,');
    }
    buffer.writeln('    );');
    buffer.writeln('  }');
    buffer.writeln('}');

    if (model.relationKeys.isNotEmpty) {
      buffer.writeln();
      buffer.writeln(_generateRelationKeysClass(model));
    }

    return buffer.toString();
  }

  String _generateRelationKeysClass(ApitoSchemaModel model) {
    final className = apitoSingularGraphQLTypeName(model.name);
    final keysClass = '${className}RelationKeys';
    final buffer = StringBuffer();
    buffer.writeln('/// GraphQL relation field names from live schema.');
    buffer.writeln('///');
    buffer.writeln('/// List `relation` keys match output relation fields: `known_as` when');
    buffer.writeln('/// set (e.g. `owner`), otherwise the public model name (e.g. `users`).');
    buffer.writeln('/// Mutation `connect` keys come from `*_Relation_Connect_Payload`.');
    buffer.writeln('/// Connect values are scalar related document ids (e.g. `owner_id: "01…"`).');
    buffer.writeln('class $keysClass {');
    buffer.writeln('  const $keysClass._();');
    for (final key in model.relationKeys) {
      final constName = _relationKeyConstName(key.name);
      final notes = <String>[];
      if (key.forListFilter) notes.add('list relation filter');
      if (key.forConnect) notes.add('mutation connect');
      buffer.writeln('  /// ${notes.join(' + ')}');
      buffer.writeln("  static const $constName = '${key.name}';");
    }
    buffer.writeln('}');
    return buffer.toString();
  }

  String _relationKeyConstName(String graphqlName) {
    if (graphqlName.endsWith('_id')) {
      final base = graphqlName.substring(0, graphqlName.length - 3);
      return _dartFieldName('${base}_connect');
    }
    return _dartFieldName(graphqlName);
  }

  String _connectFactoryName(String graphqlConnectKey) {
    if (graphqlConnectKey.endsWith('_id')) {
      return _dartFieldName(
        graphqlConnectKey.substring(0, graphqlConnectKey.length - 3),
      );
    }
    return _dartFieldName(graphqlConnectKey);
  }

  String generatePayloadFile(ApitoSchemaModel model) {
    final className = apitoSingularGraphQLTypeName(model.name);
    final fileBase = model.name;
    final buffer = StringBuffer();
    buffer.writeln('// AUTO-GENERATED — DO NOT EDIT');
    buffer.writeln("import '$fileBase.dart';");
    buffer.writeln();

    buffer.writeln('class ${className}CreatePayload {');
    buffer.writeln('  const ${className}CreatePayload({');
    for (final field in model.fields) {
      if (field.name == 'id') continue;
      final dartField = _dartFieldName(field.name);
      if (field.required) {
        buffer.writeln('    required this.$dartField,');
      } else {
        buffer.writeln('    this.$dartField,');
      }
    }
    buffer.writeln('  });');
    for (final field in model.fields) {
      if (field.name == 'id') continue;
      final dartType = field.isEnum
          ? _enumClassName(field.name)
          : field.dartType;
      final nullable = field.required ? '' : '?';
      buffer.writeln('  final $dartType$nullable ${_dartFieldName(field.name)};');
    }
    buffer.writeln();
    buffer.writeln('  Map<String, dynamic> toJson() => {');
    for (final field in model.fields) {
      if (field.name == 'id') continue;
      final dartField = _dartFieldName(field.name);
      if (field.isEnum) {
        buffer.writeln("    '${field.name}': $dartField?.name,");
      } else if (field.dartType == 'DateTime') {
        buffer.writeln(
          "    '${field.name}': $dartField?.toIso8601String(),",
        );
      } else {
        buffer.writeln("    '${field.name}': $dartField,");
      }
    }
    buffer.writeln('  };');
    buffer.writeln('}');
    buffer.writeln();

    buffer.writeln('class ${className}UpdatePayload {');
    buffer.writeln('  const ${className}UpdatePayload({');
    for (final field in model.fields) {
      if (field.name == 'id') continue;
      final dartType = field.isEnum
          ? _enumClassName(field.name)
          : field.dartType;
      buffer.writeln('    this.${_dartFieldName(field.name)},');
    }
    buffer.writeln('  });');
    for (final field in model.fields) {
      if (field.name == 'id') continue;
      final dartType = field.isEnum
          ? _enumClassName(field.name)
          : field.dartType;
      buffer.writeln('  final $dartType? ${_dartFieldName(field.name)};');
    }
    buffer.writeln();
    buffer.writeln('  Map<String, dynamic> toJson() {');
    buffer.writeln('    final out = <String, dynamic>{};');
    for (final field in model.fields) {
      if (field.name == 'id') continue;
      final dartField = _dartFieldName(field.name);
      buffer.writeln('    if ($dartField != null) {');
      if (field.isEnum) {
        buffer.writeln("      out['${field.name}'] = $dartField!.name;");
      } else if (field.dartType == 'DateTime') {
        buffer.writeln(
          "      out['${field.name}'] = $dartField!.toIso8601String();",
        );
      } else {
        buffer.writeln("      out['${field.name}'] = $dartField;");
      }
      buffer.writeln('    }');
    }
    buffer.writeln('    return out;');
    buffer.writeln('  }');
    buffer.writeln('}');
    buffer.writeln();

    buffer.writeln('class ${className}Connect {');
    buffer.writeln('  const ${className}Connect({this.fields = const {}});');
    buffer.writeln('  final Map<String, dynamic> fields;');
    buffer.writeln('  Map<String, dynamic> toJson() => fields;');
    for (final key in model.relationKeys.where((k) => k.forConnect)) {
      final factoryName = _connectFactoryName(key.name);
      final constName = _relationKeyConstName(key.name);
      buffer.writeln();
      buffer.writeln('  /// Scalar `${key.name}` on mutation/upsert `connect`.');
      buffer.writeln(
        '  factory ${className}Connect.$factoryName(String documentId) => '
        '${className}Connect(fields: {${className}RelationKeys.$constName: documentId});',
      );
    }
    buffer.writeln('}');

    return buffer.toString();
  }

  String _generateEnum(ApitoSchemaField field) {
    final enumName = _enumClassName(field.name);
    final values = field.enumValues
        .map((v) => "  ${ _enumValueName(v) },")
        .join('\n');
    return 'enum $enumName {\n$values\n}';
  }

  String _enumClassName(String fieldName) {
    final parts = fieldName.split('_').where((p) => p.isNotEmpty).toList();
    return parts
        .map((p) => p[0].toUpperCase() + p.substring(1).toLowerCase())
        .join();
  }

  String _enumValueName(String value) =>
      value.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_').toLowerCase();

  String _dartFieldName(String snake) {
    if (snake.startsWith('_')) {
      snake = 'apito${snake.substring(1)}';
    }
    final parts = snake.split('_');
    if (parts.length == 1) return parts.first;
    return parts.first +
        parts.skip(1).map((p) => p[0].toUpperCase() + p.substring(1)).join();
  }

  String _fromJsonExpr(ApitoSchemaField field) {
    final key = field.name;
    if (field.isEnum) {
      final enumName = _enumClassName(field.name);
      if (field.required) {
        return "${enumName}.values.byName(json['$key'].toString().replaceAll('-', '_').toLowerCase())";
      }
      return "json['$key'] == null ? null : ${enumName}.values.byName(json['$key'].toString().replaceAll('-', '_').toLowerCase())";
    }
    final expr = switch (field.dartType) {
      'int' => "(json['$key'] as num?)?.toInt()",
      'double' => "(json['$key'] as num?)?.toDouble()",
      'bool' => "json['$key'] as bool?",
      'DateTime' =>
        "json['$key'] == null ? null : DateTime.tryParse(json['$key'].toString())",
      'List<String>' =>
        "(json['$key'] as List?)?.map((e) => e.toString()).toList()",
      _ => "json['$key']?.toString()",
    };
    if (!field.required) return expr;
    return switch (field.dartType) {
      'int' => '$expr ?? 0',
      'double' => '$expr ?? 0.0',
      'bool' => '$expr ?? false',
      'List<String>' => '$expr ?? const []',
      _ => "$expr ?? ''",
    };
  }
}
