import 'dart:convert';

import 'package:flutter_admin_sdk/src/codegen/model_generator.dart';
import 'package:flutter_admin_sdk/src/codegen/schema_reader.dart';
import 'package:test/test.dart';

void main() {
  test('parseIntrospection extracts list relation filter keys', () {
    final decoded = jsonDecode('''
    {
      "data": {
        "__schema": {
          "queryType": { "name": "Query", "fields": [
            { "name": "userProfileList" }
          ]},
          "types": [
            {
              "kind": "INPUT_OBJECT",
              "name": "User_Profile_Create_Payload",
              "inputFields": [
                { "name": "display_name", "type": { "kind": "SCALAR", "name": "String" } }
              ]
            },
            {
              "kind": "INPUT_OBJECT",
              "name": "USER_PROFILE_WHERE_RELATION_FILTER_CONDITION",
              "inputFields": [
                { "name": "owner", "type": { "kind": "INPUT_OBJECT", "name": "X" } }
              ]
            },
            {
              "kind": "INPUT_OBJECT",
              "name": "User_Profile_Relation_Connect_Payload",
              "inputFields": [
                { "name": "owner_id", "type": { "kind": "INPUT_OBJECT", "name": "Y" } }
              ]
            }
          ]
        }
      }
    }
    ''') as Map<String, dynamic>;

    final schema = SchemaReader().parseIntrospection(decoded);
    final model = schema.modelNamed('user_profile');
    expect(model, isNotNull);
    expect(model!.listRelationFilterKeys, ['owner']);
    expect(model.relationConnectKeys, ['owner_id']);

    final dart = const ModelGenerator().generateModelFile(model);
    expect(dart, contains('class UserProfileRelationKeys'));
    expect(dart, contains("static const owner = 'owner';"));
    expect(dart, contains("static const ownerConnect = 'owner_id';"));

    final payloads = const ModelGenerator().generatePayloadFile(model!);
    expect(payloads, contains('factory UserProfileConnect.owner(String documentId)'));
    expect(payloads, contains('UserProfileRelationKeys.ownerConnect: documentId'));
  });
}
