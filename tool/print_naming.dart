import 'dart:convert';
import 'dart:io';

import 'package:flutter_admin_sdk/src/runtime/naming.dart';

void main() {
  final inputs = [
    'food_order',
    'bankAccounts',
    'foods',
    'foodCategories',
    'food_orders',
    'bank_account',
    'products',
    'addons',
    'ledgers',
    'children',
    'people',
    'status',
    'data',
    'foodOrders',
    'foodCategoryList',
    'bankAccountListCount',
    'tag_Update_Payload',
  ];
  final out = <Map<String, String>>[];
  for (final i in inputs) {
    out.add({
      'input': i,
      'singularResourceName': apitoSingularResourceName(i),
      'multipleResourceName': apitoMultipleResourceName(i),
      'graphqlTypeName': apitoSingularGraphQLTypeName(i),
      'graphqlTypeNamePlural': apitoListGraphQLTypeName(i),
    });
  }
  stdout.writeln(const JsonEncoder.withIndent('  ').convert(out));
}
