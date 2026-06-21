import 'package:flutter_admin_sdk/src/runtime/document_builder.dart';
import 'package:flutter_admin_sdk/src/runtime/naming.dart';
import 'package:test/test.dart';

void main() {
  group('QueryBuilder documents', () {
    test('list query variable types match Apito naming', () {
      final doc = DocumentBuilder('food_order').buildListQuery(
        fields: ['order_no'],
      );
      expect(doc, contains('foodOrderList('));
      expect(doc, contains('foodOrderListCount('));
      expect(doc, contains('FOODORDERLIST_INPUT_WHERE_PAYLOAD'));
      expect(doc, contains('FOOD_ORDER_LIST_COUNT_INPUT_WHERE_PAYLOAD'));
    });

    test('update mutation uses composed payload types', () {
      final doc = DocumentBuilder('loan').buildUpdateMutation(
        fields: ['loan_status'],
      );
      expect(doc, contains('Loan_Update_Payload!'));
      expect(doc, contains('updateLoan('));
    });

    test('delete mutation', () {
      final doc = DocumentBuilder('customer').buildDeleteMutation();
      expect(doc, contains('deleteCustomer('));
      expect(doc, contains('mutation DeleteCustomer'));
    });
  });
}
