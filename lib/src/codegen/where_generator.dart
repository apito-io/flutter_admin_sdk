import '../runtime/naming.dart';
import 'schema_reader.dart';

class WhereGenerator {
  const WhereGenerator();

  String generateWhereFile(ApitoSchemaModel model) {
    final className = apitoSingularGraphQLTypeName(model.name);
    final buffer = StringBuffer();
    buffer.writeln('// AUTO-GENERATED — DO NOT EDIT');
    buffer.writeln("import 'package:flutter_admin_sdk/flutter_admin_sdk.dart';");
    buffer.writeln();

    buffer.writeln('class ${className}Where {');
    buffer.writeln('  const ${className}Where({');
    for (final field in model.fields) {
      if (field.name == 'id') continue;
      final opType = _whereOpType(field);
      buffer.writeln('    this.${_dartFieldName(field.name)},');
    }
    buffer.writeln('  });');
    buffer.writeln();

    for (final field in model.fields) {
      if (field.name == 'id') continue;
      final opType = _whereOpType(field);
      buffer.writeln('  final $opType? ${_dartFieldName(field.name)};');
    }

    buffer.writeln();
    buffer.writeln('  Map<String, dynamic> toJson() {');
    buffer.writeln('    return buildWhereJson({');
    for (final field in model.fields) {
      if (field.name == 'id') continue;
      final dartField = _dartFieldName(field.name);
      buffer.writeln("      '${field.name}': $dartField,");
    }
    buffer.writeln('    });');
    buffer.writeln('  }');
    buffer.writeln('}');

    return buffer.toString();
  }

  String _whereOpType(ApitoSchemaField field) {
    if (field.dartType == 'String' && !field.isList) {
      return 'WhereOp<String>';
    }
    if (field.dartType == 'int') return 'WhereOp<int>';
    if (field.dartType == 'double') return 'WhereOp<double>';
    if (field.dartType == 'bool') return 'WhereOp<bool>';
    if (field.dartType == 'DateTime') return 'WhereOp<DateTime>';
    return 'WhereOp<dynamic>';
  }

  String _dartFieldName(String snake) {
    final parts = snake.split('_');
    if (parts.length == 1) return parts.first;
    return parts.first +
        parts.skip(1).map((p) => p[0].toUpperCase() + p.substring(1)).join();
  }
}
