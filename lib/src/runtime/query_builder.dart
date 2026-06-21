import 'client.dart';
import 'document_builder.dart';
import 'filter.dart';
import 'mutation_builder.dart';
import 'naming.dart';
import 'types.dart';

/// Immutable chainable query builder for Apito list/get/count operations.
class QueryBuilder {
  const QueryBuilder({
    required this.client,
    required this.model,
    this.fields = const ['id'],
    this.whereFilters = const {},
    this.relationWhere = const {},
    this.connection = const {},
    this.connectionFields = const {},
    this.aliasFields = const {},
    this.pageNumber = 1,
    this.pageLimit = 50,
    this.sortBy,
    this.descending = false,
    this.key,
  });

  final ApitoClient client;
  final String model;
  final List<String> fields;
  final Map<String, dynamic> whereFilters;
  final Map<String, dynamic> relationWhere;
  final Map<String, dynamic> connection;
  final Map<String, String> connectionFields;
  final Map<String, String> aliasFields;
  final int pageNumber;
  final int pageLimit;
  final String? sortBy;
  final bool descending;
  final dynamic key;

  DocumentBuilder get _docs => DocumentBuilder(model);

  QueryBuilder _copy({
    List<String>? fields,
    Map<String, dynamic>? whereFilters,
    Map<String, dynamic>? relationWhere,
    Map<String, dynamic>? connection,
    Map<String, String>? connectionFields,
    Map<String, String>? aliasFields,
    int? pageNumber,
    int? pageLimit,
    String? sortBy,
    bool? descending,
    dynamic key,
    bool clearSort = false,
  }) {
    return QueryBuilder(
      client: client,
      model: model,
      fields: fields ?? this.fields,
      whereFilters: whereFilters ?? this.whereFilters,
      relationWhere: relationWhere ?? this.relationWhere,
      connection: connection ?? this.connection,
      connectionFields: connectionFields ?? this.connectionFields,
      aliasFields: aliasFields ?? this.aliasFields,
      pageNumber: pageNumber ?? this.pageNumber,
      pageLimit: pageLimit ?? this.pageLimit,
      sortBy: clearSort ? null : (sortBy ?? this.sortBy),
      descending: descending ?? this.descending,
      key: key ?? this.key,
    );
  }

  QueryBuilder select(List<String> fieldNames) =>
      _copy(fields: List<String>.from(fieldNames));

  QueryBuilder where(Map<String, dynamic> conditions) =>
      _copy(whereFilters: buildWhereJson(conditions));

  QueryBuilder relation(Map<String, dynamic> conditions) =>
      _copy(relationWhere: Map<String, dynamic>.from(conditions));

  QueryBuilder connectFilter(Map<String, dynamic> connectionFilter) =>
      _copy(connection: Map<String, dynamic>.from(connectionFilter));

  QueryBuilder withConnections(
    Map<String, String> selections, {
    Map<String, String>? aliases,
  }) =>
      _copy(
        connectionFields: Map<String, String>.from(selections),
        aliasFields: aliases != null
            ? Map<String, String>.from(aliases)
            : aliasFields,
      );

  QueryBuilder page(int page) => _copy(pageNumber: page);

  QueryBuilder limit(int limit) => _copy(pageLimit: limit);

  QueryBuilder sort(String field, {bool descending = false}) =>
      _copy(sortBy: field, descending: descending);

  QueryBuilder keyCondition(dynamic keyCondition) =>
      _copy(key: keyCondition);

  MutationBuilder insert({required Map<String, dynamic> payload}) {
    return MutationBuilder(
      client: client,
      model: model,
      fields: fields,
      mode: MutationMode.create,
      payload: payload,
    );
  }

  MutationBuilder update({
    required String id,
    required Map<String, dynamic> payload,
    bool deltaUpdate = false,
  }) {
    return MutationBuilder(
      client: client,
      model: model,
      fields: fields,
      mode: MutationMode.update,
      recordId: id,
      payload: payload,
      deltaUpdate: deltaUpdate,
    );
  }

  MutationBuilder delete({required String id}) {
    return MutationBuilder(
      client: client,
      model: model,
      fields: fields,
      mode: MutationMode.delete,
      recordId: id,
    );
  }

  MutationBuilder upsert({required List<Map<String, dynamic>> payloads}) {
    return MutationBuilder(
      client: client,
      model: model,
      fields: fields,
      mode: MutationMode.upsertList,
      payloads: payloads,
    );
  }

  Map<String, dynamic> _listVariables({Map<String, dynamic>? whereOverride}) {
    final whereJson = whereOverride ?? whereFilters;
    final hasKey = key != null;
    final hasRelation = relationWhere.isNotEmpty;

    return {
      if (hasKey) '_key': key,
      'connection': connection,
      'where': whereJson,
      if (hasRelation) 'relationWhere': relationWhere,
      'whereCount': whereJson,
      if (hasKey) '_keyCount': key,
      if (hasRelation) 'relationWhereCount': relationWhere,
      'sort': _sortPayload(),
      'page': pageNumber,
      'limit': pageLimit,
    };
  }

  Map<String, dynamic>? _sortPayload() {
    if (sortBy == null || sortBy!.isEmpty) return null;
    return {sortBy!: descending ? 'DESC' : 'ASC'};
  }

  Future<ApitoListResponse> list() async {
    final listField = apitoMultipleResourceName(model);
    final countField = '${listField}Count';
    final document = _docs.buildListQuery(
      fields: fields,
      connectionFields: connectionFields,
      aliasFields: aliasFields,
      includeRelationWhere: relationWhere.isNotEmpty,
      includeKey: key != null,
    );

    final data = await client.execute(document, variables: _listVariables());
    final rows = data[listField] as List<dynamic>? ?? [];
    final countBlock = data[countField] as Map<String, dynamic>? ?? {};
    return ApitoListResponse(
      data: rows
          .map((r) => ApitoRecord.fromGraphql(r as Map<String, dynamic>))
          .toList(),
      total: countBlock['total'] as int? ?? rows.length,
    );
  }

  Future<ApitoRecord> get(String id) async {
    final singularField = apitoSingularResourceName(model);
    final document = _docs.buildGetQuery(
      fields: fields,
      connectionFields: connectionFields,
      aliasFields: aliasFields,
    );
    final data = await client.execute(document, variables: {'id': id});
    final row = data[singularField] as Map<String, dynamic>? ?? {};
    return ApitoRecord.fromGraphql(row);
  }

  Future<int> count() async {
    final countField = '${apitoMultipleResourceName(model)}Count';
    final document = _docs.buildCountQuery(
      includeRelationWhere: relationWhere.isNotEmpty,
      includeKey: key != null,
    );
    final data = await client.execute(
      document,
      variables: _listVariables(),
    );
    final countBlock = data[countField] as Map<String, dynamic>? ?? {};
    return countBlock['total'] as int? ?? 0;
  }
}
