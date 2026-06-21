import 'dart:convert';
import 'dart:io';

import 'package:flutter_admin_sdk/src/runtime/document_builder.dart';
import 'package:flutter_admin_sdk/src/runtime/naming.dart';
import 'package:test/test.dart';

void main() {
  final fixtureFile =
      File('test/fixtures/naming_vectors.json').readAsStringSync();
  final namingVectors =
      (jsonDecode(fixtureFile) as List).cast<Map<String, dynamic>>();

  group('naming_vectors.json parity', () {
    for (final row in namingVectors) {
      final input = row['input'] as String;
      test('resource $input', () {
        expect(apitoSingularResourceName(input), row['singularResourceName']);
        expect(apitoMultipleResourceName(input), row['multipleResourceName']);
        expect(apitoModelName(input), row['singularResourceName']);
        expect(apitoSingularGraphQLTypeName(input), row['graphqlTypeName']);
        expect(apitoListGraphQLTypeName(input), row['graphqlTypeNamePlural']);
      });
    }
  });

  group('Go SingularResourceName parity (no English singularize)', () {
    test('singular vs plural legacy camel ids', () {
      expect(apitoSingularResourceName('food'), 'food');
      expect(apitoMultipleResourceName('food'), 'foodList');
      expect(apitoSingularResourceName('foods'), 'foods');
      expect(apitoMultipleResourceName('foods'), 'foodsList');
    });
  });

  group('canonicalizeModelName', () {
    test('normalizes compound names', () {
      expect(canonicalizeModelName('foodOrder'), 'food_order');
      expect(canonicalizeModelName('food_orders'), 'food_order');
    });
    test('rejects run-on', () {
      expect(() => canonicalizeModelName('foodorder'), throwsArgumentError);
    });
  });

  group('mutation connect / disconnect field names', () {
    test('has_one from camel relation id', () {
      expect(apitoMutationConnectHasOneIdField('foodCategory'), 'food_category_id');
      expect(apitoMutationConnectHasOneIdField('food_category'), 'food_category_id');
    });
    test('has_many', () {
      expect(apitoMutationConnectHasManyIdsField('foodOrder'), 'food_order_ids');
    });
    test('apitoStoredSnakeModelId matches filter snake segment', () {
      expect(apitoStoredSnakeModelId('bankAccount'), 'bank_account');
    });
  });

  group('filter / connection types (snake model id)', () {
    test('bank_account-style resource', () {
      expect(
        apitoConnectionFilterConditionType('bank_account'),
        'BANK_ACCOUNT_CONNECTION_FILTER_CONDITION',
      );
      expect(
        apitoWhereRelationFilterConditionType('bank_account'),
        'BANK_ACCOUNT_WHERE_RELATION_FILTER_CONDITION',
      );
      expect(
        apitoWhereInputType('bank_account'),
        'BANKACCOUNTLIST_INPUT_WHERE_PAYLOAD',
      );
      expect(
        apitoSortInputType('bank_account'),
        'BANKACCOUNTLIST_INPUT_SORT_PAYLOAD',
      );
      expect(
        apitoListKeyConditionType('bank_account'),
        'BANKACCOUNTLIST_KEY_CONDITION',
      );
      expect(
        apitoListCountKeyConditionType('bank_account'),
        'BANK_ACCOUNT_LIST_COUNT_KEY_CONDITION',
      );
      expect(
        apitoListCountWhereInputType('bank_account'),
        'BANK_ACCOUNT_LIST_COUNT_INPUT_WHERE_PAYLOAD',
      );
      expect(
        apitoListCountSortInputType('bank_account'),
        'BANK_ACCOUNT_LIST_COUNT_INPUT_SORT_PAYLOAD',
      );
    });

    test('food_order list vs list-count where types', () {
      expect(
        apitoWhereInputType('food_order'),
        'FOODORDERLIST_INPUT_WHERE_PAYLOAD',
      );
      expect(
        apitoListCountWhereInputType('food_order'),
        'FOOD_ORDER_LIST_COUNT_INPUT_WHERE_PAYLOAD',
      );
      expect(
        apitoListCountSortInputType('food_order'),
        'FOOD_ORDER_LIST_COUNT_INPUT_SORT_PAYLOAD',
      );
    });
  });

  group('formatApitoConnectionSubselections', () {
    test('normalizes legacy snake alias target to camelCase field', () {
      final s = formatApitoConnectionSubselections(
        {'foodCategory': 'id data { name }'},
        {'foodCategory': 'food_category'},
      );
      expect(s, contains('foodCategory {'));
      expect(s, isNot(contains('food_category')));
    });

    test('collapses redundant alias when response key matches schema field', () {
      final s = formatApitoConnectionSubselections(
        {'foodCategory': 'id'},
        {'foodCategory': 'foodCategory'},
      );
      expect(s.trim(), 'foodCategory { id }');
    });

    test('keeps distinct response key vs schema field', () {
      final s = formatApitoConnectionSubselections(
        {'cat': 'id'},
        {'cat': 'foodCategory'},
      );
      expect(s.trim(), 'cat: foodCategory { id }');
    });

    test('normalizes connectionFields key without alias map', () {
      final s = formatApitoConnectionSubselections({'food_category': 'id'});
      expect(s.trim(), 'foodCategory { id }');
    });

    test('has_many connection field is model List not singular', () {
      expect(apitoConnectionFieldNameForRelation('food', 'has_many'), 'foodList');
      expect(apitoMultipleResourceName('food'), 'foodList');
    });
  });

  group('buildApitoCreateMutation', () {
    test('uses Food_Order_Create_Payload for food_order model', () {
      final doc = buildApitoCreateMutation('food_order', ['name']);
      expect(doc, contains('mutation CreateFoodOrder('));
      expect(doc, contains('Food_Order_Create_Payload!'));
      expect(doc, contains('Food_Order_Relation_Connect_Payload'));
      expect(doc, contains('createFoodOrder('));
    });
  });

  group('DocumentBuilder', () {
    test('buildListQuery uses correct root fields', () {
      final doc = DocumentBuilder('loan').buildListQuery(fields: ['loan_id']);
      expect(doc, contains('loanList('));
      expect(doc, contains('loanListCount('));
      expect(doc, contains('LOANLIST_INPUT_WHERE_PAYLOAD'));
    });

    test('buildGetQuery uses singular field', () {
      final doc = DocumentBuilder('loan').buildGetQuery(fields: ['loan_id']);
      expect(doc, contains('loan(_id: \$id)'));
    });
  });
}
