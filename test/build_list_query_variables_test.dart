import 'package:flutter_admin_sdk/flutter_admin_sdk.dart';
import 'package:test/test.dart';

void main() {
  group('buildListQueryVariables', () {
    test('merges relation, where, sort, and pagination', () {
      final vars = buildListQueryVariables(
        const BuildListQueryVariablesOptions(
          resource: 'student',
          filters: [
            RelationCrudFilter(relation: 'class', value: '01CLASS'),
            FieldCrudFilter(field: 'section_code', operator: 'eq', value: 'A'),
          ],
          sorters: [CrudSort(field: 'roll_no', order: 'asc')],
          pagination: ListPagePagination(current: 2, pageSize: 25),
        ),
      );

      expect(vars, {
        'relation': {
          'class': {
            '_id': {'eq': '01CLASS'},
          },
        },
        'where': {
          'section_code': {'eq': 'A'},
        },
        'whereCount': {
          'section_code': {'eq': 'A'},
        },
        'sort': {'roll_no': 'asc'},
        'page': 2,
        'limit': 25,
      });
    });

    test('omits relation when supportsRelation is false', () {
      final vars = buildListQueryVariables(
        BuildListQueryVariablesOptions(
          resource: 'student',
          filters: [relationEqFilter('class', '01CLASS')],
          supportsRelation: false,
        ),
      );

      expect(vars.containsKey('relation'), isFalse);
      expect(vars['page'], 1);
      expect(vars['limit'], 10);
    });
  });
}
