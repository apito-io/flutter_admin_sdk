import '../runtime/document_builder.dart';
import '../runtime/naming.dart';
import 'schema_reader.dart';

class OperationGenerator {
  const OperationGenerator();

  String generateGraphqlFile(ApitoSchemaModel model) {
    final docs = DocumentBuilder(
      model.name,
      options: DocumentBuilderOptions(
        supportsRelation: model.listRelationFilterKeys.isNotEmpty,
        supportsMutationRelations: model.relationConnectKeys.isNotEmpty,
      ),
    );
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
    buffer.writeln();
    final singular = apitoSingularResourceName(model.name);
    final typeName = apitoSingularGraphQLTypeName(model.name);
    buffer.writeln('''
subscription ${typeName}Changed(\$events: [String!], \$id: String, \$where: JSON) {
  ${singular}Changed(events: \$events, id: \$id, where: \$where) {
    event
    model
    id
    projectId
    node
    previousValues
  }
}''');

    return buffer.toString();
  }
}
