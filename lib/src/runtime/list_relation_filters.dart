import 'crud_filter.dart';

/// GraphQL `relation` arg on `*List` / `*ListCount`.
typedef ApitoListRelationFilter = Map<String, Map<String, dynamic>>;

bool isRelationCrudFilter(CrudFilter filter) => filter is RelationCrudFilter;

/// List filter: scope rows by related document id.
///
/// [relationGraphQLName] must match the secured GraphQL list `relation` arg key —
/// the same name as the output relation field (`known_as` when set, otherwise the
/// public target model name). Example: `owner`, not `users`.
///
/// Shape: `relation: { owner: { _id: { eq } } }`.
RelationCrudFilter relationEqFilter(String relation, String id) {
  return RelationCrudFilter(
    relation: relation.trim(),
    value: id.trim(),
  );
}

ApitoListRelationFilter buildListRelationFilter(
  String relationGraphQLName,
  String parentId,
) {
  return {
    relationGraphQLName: {
      '_id': {'eq': parentId},
    },
  };
}

ApitoListRelationFilter mergeListRelationFilters(
  ApitoListRelationFilter a, [
  ApitoListRelationFilter? b,
  ApitoListRelationFilter? c,
  ApitoListRelationFilter? d,
]) {
  return {
    ...a,
    if (b != null) ...b,
    if (c != null) ...c,
    if (d != null) ...d,
  };
}

/// Split mixed filters into field `where` filters and GraphQL list `relation`.
({List<CrudFilter> filters, ApitoListRelationFilter? relation})
    transformRelationFilters(List<CrudFilter>? filters) {
  if (filters == null || filters.isEmpty) {
    return (filters: const [], relation: null);
  }

  final kept = <CrudFilter>[];
  var relation = <String, Map<String, dynamic>>{};

  for (final filter in filters) {
    if (filter is RelationCrudFilter && filter.value.isNotEmpty) {
      relation = mergeListRelationFilters(
        relation,
        buildListRelationFilter(filter.relation, filter.value),
      );
      continue;
    }
    kept.add(filter);
  }

  return (
    filters: kept,
    relation: relation.isEmpty ? null : relation,
  );
}
