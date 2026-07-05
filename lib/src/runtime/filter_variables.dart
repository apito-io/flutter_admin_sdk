import 'crud_filter.dart';
import 'list_relation_filters.dart';

export 'list_connection_filters.dart' show buildListConnectionScope;
export 'list_relation_filters.dart'
    show
        ApitoListRelationFilter,
        buildListRelationFilter,
        isRelationCrudFilter,
        mergeListRelationFilters,
        relationEqFilter,
        transformRelationFilters;

class ApitoFilterVariables {
  const ApitoFilterVariables({
    this.where,
    this.whereCount,
    this.sort,
    this.page,
    this.limit,
    this.relation,
    this.connection,
  });

  final Map<String, dynamic>? where;
  final Map<String, dynamic>? whereCount;
  final Map<String, dynamic>? sort;
  final int? page;
  final int? limit;
  final ApitoListRelationFilter? relation;
  final ApitoListConnection? connection;
}

class BuildFilterVariablesOptions {
  const BuildFilterVariablesOptions({
    required this.resource,
    this.filters = const [],
    this.sorters = const [],
    this.pagination = const ListPagePagination(),
    this.forCount = false,
  });

  final String resource;
  final List<CrudFilter> filters;
  final List<CrudSort> sorters;
  final ListPagePagination pagination;
  final bool forCount;
}

class BuildListQueryVariablesOptions {
  const BuildListQueryVariablesOptions({
    required this.resource,
    this.filters = const [],
    this.sorters = const [],
    this.pagination = const ListPagePagination(),
    this.supportsRelation = true,
  });

  final String resource;
  final List<CrudFilter> filters;
  final List<CrudSort> sorters;
  final ListPagePagination pagination;
  final bool supportsRelation;
}

String _mapOperator(String op) {
  const map = {
    'eq': 'eq',
    'ne': 'ne',
    'lt': 'lt',
    'gt': 'gt',
    'lte': 'lte',
    'gte': 'gte',
    'in': 'in',
    'nin': 'nin',
    'contains': 'contains',
    'ncontains': 'ncontains',
    'containss': 'containss',
    'ncontainss': 'ncontainss',
    'null': 'null',
    'nnull': 'nnull',
    'between': 'between',
    'nbetween': 'nbetween',
    'startswith': 'startswith',
    'endswith': 'endswith',
  };
  return map[op] ?? op;
}

Map<String, dynamic>? _buildWhereFromFilters(List<CrudFilter> filters) {
  if (filters.isEmpty) return null;
  final and = <Map<String, dynamic>>[];
  for (final filter in filters) {
    if (filter is! FieldCrudFilter || filter.field.isEmpty) continue;
    final op = _mapOperator(filter.operator);
    and.add({filter.field: {op: filter.value}});
  }
  if (and.isEmpty) return null;
  return Map<String, dynamic>.fromEntries(
    and.expand((m) => m.entries),
  );
}

Map<String, dynamic>? _buildSortFromSorters(List<CrudSort> sorters) {
  if (sorters.isEmpty) return null;
  final sort = <String, dynamic>{};
  for (final s in sorters) {
    sort[s.field] = s.order == 'desc' ? 'desc' : 'asc';
  }
  return sort;
}

ApitoFilterVariables buildApitoFilterVariables(
  BuildFilterVariablesOptions options,
) {
  final where = _buildWhereFromFilters(options.filters);
  final sort = _buildSortFromSorters(options.sorters);
  final pageSize = options.pagination.pageSize;
  final current = options.pagination.current;

  return ApitoFilterVariables(
    where: where,
    whereCount: options.forCount ? where : null,
    sort: sort,
    page: options.forCount ? null : current,
    limit: options.forCount ? null : pageSize,
  );
}

Map<String, dynamic> buildListQueryVariables(
  BuildListQueryVariablesOptions options,
) {
  final split = transformRelationFilters(options.filters);
  final base = buildApitoFilterVariables(
    BuildFilterVariablesOptions(
      resource: options.resource,
      filters: split.filters,
      sorters: options.sorters,
      pagination: options.pagination,
    ),
  );
  final count = buildApitoFilterVariables(
    BuildFilterVariablesOptions(
      resource: options.resource,
      filters: split.filters,
      sorters: options.sorters,
      pagination: options.pagination,
      forCount: true,
    ),
  );

  final vars = <String, dynamic>{
    if (base.where != null) 'where': base.where,
    if (count.where != null) 'whereCount': count.where,
    if (base.sort != null) 'sort': base.sort,
    'page': base.page ?? 1,
    'limit': base.limit ?? 10,
  };

  if (options.supportsRelation && split.relation != null) {
    vars['relation'] = split.relation;
  }

  return vars;
}
