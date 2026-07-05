/// Refine-style list filters for Apito secured GraphQL.
library;

/// Field or relation filter for list queries.
sealed class CrudFilter {
  const CrudFilter();
}

/// Scalar / embedded field filter → GraphQL `where`.
class FieldCrudFilter extends CrudFilter {
  const FieldCrudFilter({
    required this.field,
    required this.operator,
    this.value,
  });

  final String field;
  final String operator;
  final Object? value;
}

/// Relation scope filter → GraphQL `relation` (not `connection`).
class RelationCrudFilter extends CrudFilter {
  const RelationCrudFilter({
    required this.relation,
    required this.value,
    this.operator = 'eq',
  });

  final String relation;
  final String value;
  final String operator;
}

/// Parent-document scoped list `connection` payload (special-case API only).
class ApitoListConnection {
  const ApitoListConnection({
    required this.id,
    this.connectionType = 'forward',
    this.relationType = 'has_many',
    this.model,
    this.toModel,
    this.knownAs,
  });

  final String id;
  final String connectionType;
  final String relationType;
  final String? model;
  final String? toModel;
  final String? knownAs;

  Map<String, dynamic> toJson() => {
        '_id': id,
        'connection_type': connectionType,
        'relation_type': relationType,
        if (model != null) 'model': model,
        if (toModel != null) 'to_model': toModel,
        if (knownAs != null) 'known_as': knownAs,
      };
}

class CrudSort {
  const CrudSort({required this.field, required this.order});

  final String field;
  final String order;
}

class ListPagePagination {
  const ListPagePagination({this.current = 1, this.pageSize = 10});

  final int current;
  final int pageSize;
}
