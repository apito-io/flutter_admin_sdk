import 'crud_filter.dart';

/// Parent-document scoped list `connection` payload (special-case API only).
///
/// Do **not** use for relation eq filtering — use [relationEqFilter] instead.
ApitoListConnection buildListConnectionScope(String parentId) {
  return ApitoListConnection(id: parentId.trim());
}
