import 'dart:io';

import 'package:flutter_admin_sdk/src/codegen/model_generator.dart';
import 'package:flutter_admin_sdk/src/codegen/schema_reader.dart';
import 'package:test/test.dart';

void main() {
  test('parse live introspection snapshot discovers list models', () {
    final file = File('test/fixtures/sample_introspection.json');
    if (!file.existsSync()) {
      // Skip when fixture not present (CI uses bundled minimal fixture).
      return;
    }
    final schema = SchemaReader().parseJsonFile(file.readAsStringSync());
    expect(schema.models, isNotEmpty);
    expect(schema.modelNamed('loan'), isNotNull);
  });

  test('parse simple JSON schema', () {
    const json = '''
    {
      "models": [
        {
          "name": "loan",
          "fields": [
            {"name": "loan_id", "type": "string", "required": true},
            {"name": "total_amount", "type": "double"}
          ]
        }
      ]
    }
    ''';
    final schema = SchemaReader().parseJsonFile(json);
    expect(schema.models.length, 1);
    expect(schema.models.first.fields.length, 2);
  });

  test('parseSdl extracts List types', () {
    const sdl = '''
    type LoanList {
      id: String
      data: LoanData
    }
    type LoanData {
      loan_id: String
      total_amount: Float
    }
    ''';
    final schema = parseSdl(sdl);
    expect(schema.models.length, 1);
    expect(schema.models.first.name, 'loan');
  });

  test('ModelGenerator emits valid Dart', () {
    const json = '''
    {
      "models": [{
        "name": "customer",
        "fields": [
          {"name": "customer_id", "type": "string", "required": true},
          {"name": "name", "type": "string", "required": true},
          {"name": "phone", "type": "string"}
        ]
      }]
    }
    ''';
    final schema = SchemaReader().parseJsonFile(json);
    final out = const ModelGenerator().generateModelFile(schema.models.first);
    expect(out, contains('class Customer implements ApitoModel'));
    expect(out, isNot(contains('this.phone?')));
  });
}
