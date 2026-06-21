import '../runtime/naming.dart';
import 'schema_reader.dart';

class ProviderGenerator {
  const ProviderGenerator({this.clientProviderName = 'apitoClientProvider'});

  final String clientProviderName;

  String generateProvidersFile(ApitoSchemaModel model) {
    final className = apitoSingularGraphQLTypeName(model.name);
    final camel = apitoSingularResourceName(model.name);
    final fileBase = _fileBase(model.name);

    final buffer = StringBuffer();
    buffer.writeln('// AUTO-GENERATED — DO NOT EDIT');
    buffer.writeln("import 'package:flutter_admin_sdk/flutter_admin_sdk.dart';");
    buffer.writeln("import 'package:flutter_riverpod/flutter_riverpod.dart';");
    buffer.writeln("import 'package:riverpod_annotation/riverpod_annotation.dart';");
    buffer.writeln();
    buffer.writeln("import '../models/$fileBase.dart';");
    buffer.writeln("import '../models/${fileBase}.where.dart';");
    buffer.writeln("import '../models/${fileBase}.payloads.dart';");
    buffer.writeln("import '../apito_client_provider.dart';");
    buffer.writeln();
    buffer.writeln("part '${fileBase}_providers.g.dart';");
    buffer.writeln();

    buffer.writeln('@riverpod');
    buffer.writeln('class ${className}List extends _\$${className}List {');
    buffer.writeln('  @override');
    buffer.writeln('  Future<ApitoListResponseTyped<$className>> build({');
    buffer.writeln('    ${className}Where? where,');
    buffer.writeln('    int page = 1,');
    buffer.writeln('    int limit = 50,');
    buffer.writeln("    String? sortBy,");
    buffer.writeln('    bool descending = false,');
    buffer.writeln('  }) async {');
    buffer.writeln('    final client = ref.read($clientProviderName);');
    buffer.writeln("    var query = client");
    buffer.writeln("        .from('${model.name}')");
    buffer.writeln('        .select($className.queryFields)');
    buffer.writeln('        .where(where?.toJson() ?? {})');
    buffer.writeln('        .page(page).limit(limit);');
    buffer.writeln('    final effectiveSort = sortBy ?? $className.defaultSortField;');
    buffer.writeln('    if (effectiveSort != null && effectiveSort.isNotEmpty) {');
    buffer.writeln('      query = query.sort(effectiveSort, descending: descending);');
    buffer.writeln('    }');
    buffer.writeln('    final response = await query.list();');
    buffer.writeln('    return ApitoListResponseTyped(');
    buffer.writeln('      data: response.data');
    buffer.writeln('          .map((r) => $className.fromJson({...r.data, \'id\': r.id}))');
    buffer.writeln('          .toList(),');
    buffer.writeln('      total: response.total,');
    buffer.writeln('    );');
    buffer.writeln('  }');
    buffer.writeln('}');
    buffer.writeln();

    buffer.writeln('@riverpod');
    buffer.writeln('class ${className}Detail extends _\$${className}Detail {');
    buffer.writeln('  @override');
    buffer.writeln('  Future<$className> build(String id) async {');
    buffer.writeln('    final client = ref.read($clientProviderName);');
    buffer.writeln("    final record = await client.from('${model.name}').select($className.queryFields).get(id);");
    buffer.writeln('    return $className.fromJson({...record.data, \'id\': record.id});');
    buffer.writeln('  }');
    buffer.writeln('}');
    buffer.writeln();

    buffer.writeln('@riverpod');
    buffer.writeln('class Create$className extends _\$Create$className {');
    buffer.writeln('  @override');
    buffer.writeln('  FutureOr<void> build() {}');
    buffer.writeln();
    buffer.writeln('  Future<$className> execute({');
    buffer.writeln('    required ${className}CreatePayload payload,');
    buffer.writeln('    ${className}Connect? connect,');
    buffer.writeln('  }) async {');
    buffer.writeln('    final client = ref.read($clientProviderName);');
    buffer.writeln("    final result = await client.from('${model.name}')");
    buffer.writeln('        .select($className.queryFields)');
    buffer.writeln('        .insert(payload: payload.toJson())');
    buffer.writeln('        .connectWith(connect?.toJson() ?? {})');
    buffer.writeln('        .execute();');
    buffer.writeln('    if (ref.mounted) {');
    buffer.writeln('      ref.invalidate(${camel}ListProvider);');
    buffer.writeln('    }');
    buffer.writeln('    return $className.fromJson({...result.data, \'id\': result.id});');
    buffer.writeln('  }');
    buffer.writeln('}');
    buffer.writeln();

    buffer.writeln('@riverpod');
    buffer.writeln('class Update$className extends _\$Update$className {');
    buffer.writeln('  @override');
    buffer.writeln('  FutureOr<void> build() {}');
    buffer.writeln();
    buffer.writeln('  Future<$className> execute({');
    buffer.writeln('    required String id,');
    buffer.writeln('    required ${className}UpdatePayload payload,');
    buffer.writeln('    ${className}Connect? connect,');
    buffer.writeln('    ${className}Connect? disconnect,');
    buffer.writeln('    bool deltaUpdate = false,');
    buffer.writeln('  }) async {');
    buffer.writeln('    final client = ref.read($clientProviderName);');
    buffer.writeln("    final builder = client.from('${model.name}')");
    buffer.writeln('        .select($className.queryFields)');
    buffer.writeln('        .update(id: id, payload: payload.toJson(), deltaUpdate: deltaUpdate);');
    buffer.writeln('    final mutation = connect != null || disconnect != null');
    buffer.writeln('        ? builder.connectWith(connect?.toJson() ?? {}).disconnectFrom(disconnect?.toJson() ?? {})');
    buffer.writeln('        : builder;');
    buffer.writeln('    final result = await mutation.execute();');
    buffer.writeln('    if (ref.mounted) {');
    buffer.writeln('      ref.invalidate(${camel}ListProvider);');
    buffer.writeln('      ref.invalidate(${camel}DetailProvider(id));');
    buffer.writeln('    }');
    buffer.writeln('    return $className.fromJson({...result.data, \'id\': result.id});');
    buffer.writeln('  }');
    buffer.writeln('}');
    buffer.writeln();

    buffer.writeln('@riverpod');
    buffer.writeln('class Delete$className extends _\$Delete$className {');
    buffer.writeln('  @override');
    buffer.writeln('  FutureOr<void> build() {}');
    buffer.writeln();
    buffer.writeln('  Future<void> execute(String id) async {');
    buffer.writeln('    final client = ref.read($clientProviderName);');
    buffer.writeln("    await client.from('${model.name}').delete(id: id).execute();");
    buffer.writeln('    if (ref.mounted) {');
    buffer.writeln('      ref.invalidate(${camel}ListProvider);');
    buffer.writeln('      ref.invalidate(${camel}DetailProvider(id));');
    buffer.writeln('    }');
    buffer.writeln('  }');
    buffer.writeln('}');

    return buffer.toString();
  }

  String generateClientProviderStub() {
    return '''
// Wire this provider in your app (endpoint + API key from env/config).
import 'package:flutter_admin_sdk/flutter_admin_sdk.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'apito_client_provider.g.dart';

@Riverpod(keepAlive: true)
ApitoClient apitoClient(Ref ref) {
  throw UnimplementedError(
    'Override apitoClientProvider with your ApitoConfig endpoint and API key.',
  );
}
''';
  }

  String _fileBase(String modelName) => modelName.replaceAll('-', '_');
}
