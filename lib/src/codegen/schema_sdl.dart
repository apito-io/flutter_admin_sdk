/// Converts introspection JSON to minimal GraphQL SDL for optional graphql_codegen use.
library;

import 'dart:convert';

String introspectionJsonToSdl(String jsonSource) {
  final decoded = jsonDecode(jsonSource) as Map<String, dynamic>;
  final schema = decoded['data']?['__schema'] as Map<String, dynamic>?;
  if (schema == null) return '# empty schema\n';

  final types = (schema['types'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
  final buffer = StringBuffer('# AUTO-GENERATED — DO NOT EDIT\n\n');

  for (final t in types) {
    final kind = t['kind'] as String?;
    final name = t['name'] as String?;
    if (name == null || name.startsWith('__')) continue;

    switch (kind) {
      case 'OBJECT':
        buffer.writeln('type $name {');
        final fields = (t['fields'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
        if (fields.isEmpty) {
          buffer.writeln('  _codegenPlaceholder: String');
        } else {
          for (final f in fields) {
            buffer.writeln('  ${f['name']}: ${_unwrapTypeName(f['type'] as Map<String, dynamic>?)}');
          }
        }
        buffer.writeln('}\n');
      case 'INPUT_OBJECT':
        buffer.writeln('input $name {');
        for (final f in (t['inputFields'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>()) {
          buffer.writeln('  ${f['name']}: ${_unwrapTypeName(f['type'] as Map<String, dynamic>?)}');
        }
        buffer.writeln('}\n');
      case 'ENUM':
        buffer.writeln('enum $name {');
        for (final v in (t['enumValues'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>()) {
          buffer.writeln('  ${v['name']}');
        }
        buffer.writeln('}\n');
      case 'SCALAR':
        buffer.writeln('scalar $name\n');
    }
  }
  return buffer.toString();
}

String _unwrapTypeName(Map<String, dynamic>? type) {
  if (type == null) return 'String';
  final kind = type['kind'] as String?;
  if (kind == 'NON_NULL') {
    return '${_unwrapTypeName(type['ofType'] as Map<String, dynamic>?)}!';
  }
  if (kind == 'LIST') {
    return '[${_unwrapTypeName(type['ofType'] as Map<String, dynamic>?)}]';
  }
  return type['name'] as String? ?? 'String';
}
