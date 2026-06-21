import 'naming.dart';

/// Builds GraphQL operation strings for Apito secured/project API.
class DocumentBuilder {
  const DocumentBuilder(this.model);

  final String model;

  String get _listField => apitoMultipleResourceName(model);
  String get _countField => '${_listField}Count';
  String get _singularField => apitoSingularResourceName(model);
  String get _singularPascal => apitoSingularGraphQLTypeName(model);
  String get _listPascal => apitoListGraphQLTypeName(model);

  String buildListQuery({
    required List<String> fields,
    Map<String, String> connectionFields = const {},
    Map<String, String> aliasFields = const {},
    bool includeCount = true,
    bool includeRelationWhere = false,
    bool includeKey = false,
  }) {
    final connectionSelection = connectionFields.isEmpty
        ? ''
        : formatApitoConnectionSubselections(connectionFields, aliasFields);

    final queryVariables = [
      if (includeKey) r'$_key: ${KEY_TYPE}',
      r'$connection: ${CONNECTION}',
      r'$where: ${WHERE}',
      if (includeRelationWhere) r'$relationWhere: ${RELATION_WHERE}',
      if (includeKey) r'$_keyCount: ${KEY_COUNT_TYPE}',
      r'$whereCount: ${WHERE_COUNT}',
      if (includeRelationWhere) r'$relationWhereCount: ${RELATION_WHERE}',
      r'$sort: ${SORT}',
      r'$page: Int',
      r'$limit: Int',
    ].join('\n    ');

    final vars = queryVariables
        .replaceAll(r'${KEY_TYPE}', apitoListKeyConditionType(model))
        .replaceAll(r'${CONNECTION}', apitoConnectionFilterConditionType(model))
        .replaceAll(r'${WHERE}', apitoWhereInputType(model))
        .replaceAll(r'${RELATION_WHERE}', apitoWhereRelationFilterConditionType(model))
        .replaceAll(r'${KEY_COUNT_TYPE}', apitoListCountKeyConditionType(model))
        .replaceAll(r'${WHERE_COUNT}', apitoListCountWhereInputType(model))
        .replaceAll(r'${SORT}', apitoSortInputType(model));

    final queryArguments = [
      if (includeKey) '_key: \$_key',
      'connection: \$connection',
      'where: \$where',
      if (includeRelationWhere) 'relation: \$relationWhere',
      'sort: \$sort',
      'page: \$page',
      'limit: \$limit',
    ].join(', ');

    final countArguments = [
      if (includeKey) '_key: \$_keyCount',
      'connection: \$connection',
      'where: \$whereCount',
      if (includeRelationWhere) 'relation: \$relationWhereCount',
      'page: \$page',
      'limit: \$limit',
    ].join(', ');

    final countBlock = includeCount
        ? '''
    $_countField($countArguments) {
      total
    }'''
        : '';

    return '''
query Get$_listPascal(
    $vars
) {
  $_listField($queryArguments) {
    id
    data {
      ${fields.join('\n      ')}
    }
    $connectionSelection
    meta {
      created_at
      status
      updated_at
    }
  }$countBlock
}''';
  }

  String buildGetQuery({
    required List<String> fields,
    Map<String, String> connectionFields = const {},
    Map<String, String> aliasFields = const {},
  }) {
    final connectionSelection = connectionFields.isEmpty
        ? ''
        : formatApitoConnectionSubselections(connectionFields, aliasFields);

    return '''
query Get$_singularPascal(\$id: String!) {
  $_singularField(_id: \$id) {
    id
    data {
      ${fields.join('\n      ')}
    }
    $connectionSelection
    meta {
      created_at
      status
      updated_at
    }
  }
}''';
  }

  String buildCountQuery({
    bool includeRelationWhere = false,
    bool includeKey = false,
  }) {
    final queryVariables = [
      if (includeKey) r'$_keyCount: ${KEY_COUNT_TYPE}',
      r'$connection: ${CONNECTION}',
      r'$whereCount: ${WHERE_COUNT}',
      if (includeRelationWhere) r'$relationWhereCount: ${RELATION_WHERE}',
      r'$page: Int',
      r'$limit: Int',
    ].join('\n    ');

    final vars = queryVariables
        .replaceAll(r'${KEY_COUNT_TYPE}', apitoListCountKeyConditionType(model))
        .replaceAll(r'${CONNECTION}', apitoConnectionFilterConditionType(model))
        .replaceAll(r'${WHERE_COUNT}', apitoListCountWhereInputType(model))
        .replaceAll(r'${RELATION_WHERE}', apitoWhereRelationFilterConditionType(model));

    final countArguments = [
      if (includeKey) '_key: \$_keyCount',
      'connection: \$connection',
      'where: \$whereCount',
      if (includeRelationWhere) 'relation: \$relationWhereCount',
      'page: \$page',
      'limit: \$limit',
    ].join(', ');

    return '''
query Count$_listPascal(
    $vars
) {
  $_countField($countArguments) {
    total
  }
}''';
  }

  String buildCreateMutation({required List<String> fields}) =>
      buildApitoCreateMutation(model, fields);

  String buildUpdateMutation({
    required List<String> fields,
    bool includeRelations = true,
  }) {
    final updatePayload = apitoGraphQLComposedTypeName(model, 'Update_Payload');
    final relConn =
        apitoGraphQLComposedTypeName(model, 'Relation_Connect_Payload');
    final relDis =
        apitoGraphQLComposedTypeName(model, 'Relation_Disconnect_Payload');
    final relationVarDefs = includeRelations
        ? ',\n    \$connect: $relConn,\n    \$disconnect: $relDis'
        : '';
    final relationArgs =
        includeRelations ? ', connect: \$connect, disconnect: \$disconnect' : '';

    return '''
mutation Update$_singularPascal(
    \$id: String!,
    \$deltaUpdate: Boolean,
    \$payload: $updatePayload!$relationVarDefs
) {
  update$_singularPascal(_id: \$id, deltaUpdate: \$deltaUpdate, payload: \$payload$relationArgs, status: published) {
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

  String buildDeleteMutation() {
    return '''
mutation Delete$_singularPascal(\$ids: [String]!) {
  delete$_singularPascal(_ids: \$ids) {
    response
  }
}''';
  }

  String buildUpsertListMutation({required List<String> fields}) {
    final upsertPayload =
        apitoGraphQLComposedTypeName(model, 'List_Upsert_Payload');
    final listConnect =
        apitoGraphQLComposedTypeName(model, 'Relation_Connect_Payload');

    return '''
mutation Upsert$_listPascal(\$payloads: [$upsertPayload!]!, \$connect: $listConnect) {
  upsert$_listPascal(payloads: \$payloads, connect: \$connect, status: published) {
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
}
