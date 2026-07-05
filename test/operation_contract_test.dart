import 'package:flutter_admin_sdk/src/codegen/operation_generator.dart';
import 'package:flutter_admin_sdk/src/codegen/schema_reader.dart';
import 'package:flutter_admin_sdk/src/runtime/document_builder.dart';
import 'package:test/test.dart';

void main() {
  group('operation doc contract (5 ops per model)', () {
    test('loan operations match canonical shape', () {
      const fields = ['loan_id', 'loan_status', 'total_amount'];
      final doc = const OperationGenerator().generateGraphqlFile(
        const ApitoSchemaModel(
          name: 'loan',
          fields: [
            ApitoSchemaField(name: 'loan_id', graphqlType: 'String'),
            ApitoSchemaField(name: 'loan_status', graphqlType: 'String'),
            ApitoSchemaField(name: 'total_amount', graphqlType: 'Float'),
          ],
        ),
      );

      expect(doc, contains('# AUTO-GENERATED'));
      expect(doc, contains('query GetLoanList('));
      expect(doc, contains('query GetLoan('));
      expect(doc, contains('mutation CreateLoan('));
      expect(doc, contains('mutation UpdateLoan('));
      expect(doc, contains('mutation DeleteLoan('));
      expect(doc, contains('LOANLIST_INPUT_WHERE_PAYLOAD'));
      expect(doc, contains('LOAN_WHERE_RELATION_FILTER_CONDITION'));
      expect(doc, contains('Loan_Create_Payload'));
      expect(doc, contains('loanList('));
      expect(doc, contains('relation: \$relation'));
      expect(doc, contains('loanListCount('));
      expect(doc, contains('loan(_id: \$id)'));
    });

    test('DocumentBuilder list query matches OperationGenerator list section', () {
      const fields = ['loan_id'];
      final fromBuilder = DocumentBuilder('loan').buildListQuery(fields: fields);
      final fromOpGen = const OperationGenerator().generateGraphqlFile(
        const ApitoSchemaModel(
          name: 'loan',
          fields: [ApitoSchemaField(name: 'loan_id', graphqlType: 'String')],
        ),
      );
      expect(fromOpGen, contains(fromBuilder.trim()));
    });
  });
}
