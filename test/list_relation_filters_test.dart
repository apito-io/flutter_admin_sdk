import 'package:flutter_admin_sdk/flutter_admin_sdk.dart';
import 'package:test/test.dart';

void main() {
  group('list relation filters', () {
    test('relationEqFilter builds explicit relation crud filter', () {
      final filter = relationEqFilter('class', '01CLASS');
      expect(filter.relation, 'class');
      expect(filter.operator, 'eq');
      expect(filter.value, '01CLASS');
      expect(isRelationCrudFilter(filter), isTrue);
    });

    test('buildListRelationFilter maps to GraphQL relation shape', () {
      expect(
        buildListRelationFilter('class', '01CLASS'),
        {
          'class': {
            '_id': {'eq': '01CLASS'},
          },
        },
      );
    });

    test('transformRelationFilters splits relation and where field filters', () {
      final result = transformRelationFilters([
        relationEqFilter('class', '01CLASS'),
        const FieldCrudFilter(field: 'section_code', operator: 'eq', value: 'A'),
      ]);

      expect(result.filters, [
        const FieldCrudFilter(field: 'section_code', operator: 'eq', value: 'A'),
      ]);
      expect(result.relation, {
        'class': {
          '_id': {'eq': '01CLASS'},
        },
      });
    });

    test('merges multiple relation filters', () {
      final result = transformRelationFilters([
        relationEqFilter('class', '01CLASS'),
        relationEqFilter('exam', '01EXAM'),
      ]);

      expect(result.filters, isEmpty);
      expect(result.relation, {
        'class': {
          '_id': {'eq': '01CLASS'},
        },
        'exam': {
          '_id': {'eq': '01EXAM'},
        },
      });
    });
  });

  group('list connection scope', () {
    test('buildListConnectionScope is explicit parent-document scope only', () {
      expect(
        buildListConnectionScope('01CLASS').toJson(),
        {
          '_id': '01CLASS',
          'connection_type': 'forward',
          'relation_type': 'has_many',
        },
      );
    });
  });
}
