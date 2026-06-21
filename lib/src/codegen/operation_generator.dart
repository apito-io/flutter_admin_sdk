import '../runtime/document_builder.dart';
import '../runtime/naming.dart';
import 'schema_reader.dart';

class OperationGenerator {
  const OperationGenerator();

  String generateGraphqlFile(ApitoSchemaModel model) {
    final docs = DocumentBuilder(model.name);
    var fields = model.queryFieldNames;
    if (fields.isEmpty) {
      fields = ['id'];
    }

    final buffer = StringBuffer();
    buffer.writeln('# AUTO-GENERATED — DO NOT EDIT');
    buffer.writeln('# Model: ${model.name}');
    buffer.writeln();
    buffer.writeln(docs.buildListQuery(fields: fields));
    buffer.writeln();
    buffer.writeln(docs.buildGetQuery(fields: fields));
    buffer.writeln();
    buffer.writeln(docs.buildCreateMutation(fields: fields));
    buffer.writeln();
    buffer.writeln(docs.buildUpdateMutation(fields: fields));
    buffer.writeln();
    buffer.writeln(docs.buildDeleteMutation());

    return buffer.toString();
  }
}
