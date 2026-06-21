import 'client.dart';
import 'document_builder.dart';
import 'naming.dart';
import 'types.dart';

enum MutationMode { create, update, delete, upsertList }

/// Chainable mutation builder for create/update/delete/upsert operations.
class MutationBuilder {
  MutationBuilder({
    required this.client,
    required this.model,
    required this.fields,
    required this.mode,
    this.recordId,
    this.payload = const {},
    this.payloads = const [],
    this.connectPayload = const {},
    this.disconnectPayload = const {},
    this.deltaUpdate = false,
    this.includeRelations = true,
  });

  final ApitoClient client;
  final String model;
  final List<String> fields;
  final MutationMode mode;
  final String? recordId;
  final Map<String, dynamic> payload;
  final List<Map<String, dynamic>> payloads;
  final Map<String, dynamic> connectPayload;
  final Map<String, dynamic> disconnectPayload;
  final bool deltaUpdate;
  final bool includeRelations;

  DocumentBuilder get _docs => DocumentBuilder(model);

  MutationBuilder _copy({
    Map<String, dynamic>? connectPayload,
    Map<String, dynamic>? disconnectPayload,
    Map<String, dynamic>? payload,
  }) {
    return MutationBuilder(
      client: client,
      model: model,
      fields: fields,
      mode: mode,
      recordId: recordId,
      payload: payload ?? this.payload,
      payloads: payloads,
      connectPayload: connectPayload ?? this.connectPayload,
      disconnectPayload: disconnectPayload ?? this.disconnectPayload,
      deltaUpdate: deltaUpdate,
      includeRelations: includeRelations,
    );
  }

  MutationBuilder connect(Map<String, dynamic> relationConnect) =>
      connectWith(relationConnect);

  MutationBuilder connectWith(Map<String, dynamic> relationConnect) =>
      _copy(connectPayload: Map<String, dynamic>.from(relationConnect));

  MutationBuilder disconnect(Map<String, dynamic> relationDisconnect) =>
      disconnectFrom(relationDisconnect);

  MutationBuilder disconnectFrom(Map<String, dynamic> relationDisconnect) =>
      _copy(disconnectPayload: Map<String, dynamic>.from(relationDisconnect));

  Future<ApitoRecord> execute() async {
    _assertSnakeCasePayloadKeys();
    switch (mode) {
      case MutationMode.create:
        return _executeCreate();
      case MutationMode.update:
        return _executeUpdate();
      case MutationMode.delete:
        await _executeDelete();
        return ApitoRecord(id: recordId ?? '', data: const {});
      case MutationMode.upsertList:
        final results = await _executeUpsertList();
        if (results.isEmpty) {
          return const ApitoRecord(id: '', data: {});
        }
        return results.first;
    }
  }

  Future<List<ApitoRecord>> executeMany() async {
    _assertSnakeCasePayloadKeys();
    if (mode != MutationMode.upsertList) {
      return [await execute()];
    }
    return _executeUpsertList();
  }

  Future<ApitoRecord> _executeCreate() async {
    final name = apitoSingularGraphQLTypeName(model);
    final mutationField = 'create$name';
    final document = _docs.buildCreateMutation(fields: fields);
    final data = await client.execute(document, variables: {
      'payload': payload,
      if (connectPayload.isNotEmpty) 'connect': connectPayload,
    });
    final row = data[mutationField] as Map<String, dynamic>? ?? {};
    return ApitoRecord.fromGraphql(row);
  }

  Future<ApitoRecord> _executeUpdate() async {
    final name = apitoSingularGraphQLTypeName(model);
    final mutationField = 'update$name';
    final document = _docs.buildUpdateMutation(
      fields: fields,
      includeRelations: includeRelations,
    );
    final variables = <String, dynamic>{
      'id': recordId,
      'deltaUpdate': deltaUpdate,
      'payload': payload,
    };
    if (includeRelations) {
      if (connectPayload.isNotEmpty) variables['connect'] = connectPayload;
      if (disconnectPayload.isNotEmpty) {
        variables['disconnect'] = disconnectPayload;
      }
    }
    final data = await client.execute(document, variables: variables);
    final row = data[mutationField] as Map<String, dynamic>? ?? {};
    return ApitoRecord.fromGraphql(row);
  }

  Future<void> _executeDelete() async {
    final name = apitoSingularGraphQLTypeName(model);
    final mutationField = 'delete$name';
    final document = _docs.buildDeleteMutation();
    await client.execute(document, variables: {
      'ids': [recordId],
    });
  }

  Future<List<ApitoRecord>> _executeUpsertList() async {
    final listPascal = apitoListGraphQLTypeName(model);
    final mutationField = 'upsert$listPascal';
    final document = _docs.buildUpsertListMutation(fields: fields);
    final data = await client.execute(document, variables: {
      'payloads': payloads,
      if (connectPayload.isNotEmpty) 'connect': connectPayload,
    });
    final rows = data[mutationField] as List<dynamic>? ?? [];
    return rows
        .map((r) => ApitoRecord.fromGraphql(r as Map<String, dynamic>))
        .toList();
  }

  void _assertSnakeCasePayloadKeys() {
    assert(() {
      void checkMap(Map<String, dynamic> map, String label) {
        for (final key in map.keys) {
          if (RegExp(r'[A-Z]').hasMatch(key)) {
            throw AssertionError(
              'Apito mutation $label key "$key" looks camelCase. '
              'Use generated *Payload.toJson() (snake_case).',
            );
          }
          final value = map[key];
          if (value is Map<String, dynamic>) {
            checkMap(value, label);
          } else if (value is List) {
            for (final item in value) {
              if (item is Map<String, dynamic>) {
                checkMap(item, label);
              }
            }
          }
        }
      }

      if (payload.isNotEmpty) checkMap(payload, 'payload');
      for (final p in payloads) {
        checkMap(p, 'payloads[]');
      }
      return true;
    }());
  }
}
