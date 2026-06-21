import 'dart:io';

import 'package:build/build.dart';
import 'package:path/path.dart' as p;

import 'model_generator.dart';
import 'operation_generator.dart';
import 'provider_generator.dart';
import 'schema_reader.dart';
import 'schema_sdl.dart';
import 'where_generator.dart';

/// Orchestrates full codegen output for an [ApitoSchema].
class ApitoCodegen {
  ApitoCodegen({
    this.generateProviders = true,
    this.generateWhere = true,
    this.generateOperations = true,
    this.clientProviderName = 'apitoClientProvider',
  });

  final bool generateProviders;
  final bool generateWhere;
  final bool generateOperations;
  final String clientProviderName;

  Future<void> writeAll({
    required ApitoSchema schema,
    required String outputDir,
    String? introspectionJson,
  }) async {
    final modelsDir = Directory(p.join(outputDir, 'models'));
    final providersDir = Directory(p.join(outputDir, 'providers'));
    final operationsDir = Directory(p.join(outputDir, 'operations'));

    await modelsDir.create(recursive: true);
    if (generateProviders) await providersDir.create(recursive: true);
    if (generateOperations) await operationsDir.create(recursive: true);

    final modelGen = const ModelGenerator();
    final whereGen = const WhereGenerator();
    final opGen = const OperationGenerator();
    final providerGen = ProviderGenerator(
      clientProviderName: clientProviderName,
    );

    final exports = <String>[];

    for (final model in schema.models) {
      final base = model.name;
      final modelPath = p.join(modelsDir.path, '$base.dart');
      await File(modelPath).writeAsString(modelGen.generateModelFile(model));
      exports.add("export 'models/$base.dart';");

      if (generateWhere) {
        final wherePath = p.join(modelsDir.path, '$base.where.dart');
        await File(wherePath)
            .writeAsString(whereGen.generateWhereFile(model));
        exports.add("export 'models/$base.where.dart';");
      }

      final payloadPath = p.join(modelsDir.path, '$base.payloads.dart');
      await File(payloadPath)
          .writeAsString(modelGen.generatePayloadFile(model));
      exports.add("export 'models/$base.payloads.dart';");

      if (generateOperations) {
        final opPath = p.join(operationsDir.path, '$base.graphql');
        await File(opPath).writeAsString(opGen.generateGraphqlFile(model));
      }

      if (generateProviders) {
        final providerPath =
            p.join(providersDir.path, '${base}_providers.dart');
        await File(providerPath).writeAsString(
          providerGen.generateProvidersFile(model),
        );
        exports.add("export 'providers/${base}_providers.dart';");
      }
    }

    if (generateProviders) {
      final clientProviderPath =
          p.join(outputDir, 'apito_client_provider.dart');
      if (!File(clientProviderPath).existsSync()) {
        await File(clientProviderPath)
            .writeAsString(providerGen.generateClientProviderStub());
        exports.add("export 'apito_client_provider.dart';");
      }
    }

    final barrel = StringBuffer()
      ..writeln('// AUTO-GENERATED — DO NOT EDIT')
      ..writeln('library apito_generated;')
      ..writeln()
      ..writeln(exports.map((e) => e).join('\n'));

    await File(p.join(outputDir, 'apito_generated.dart'))
        .writeAsString(barrel.toString());

    if (introspectionJson != null && introspectionJson.isNotEmpty) {
      await File(p.join(outputDir, 'schema.graphql'))
          .writeAsString(introspectionJsonToSdl(introspectionJson));
    }
  }
}

/// build_runner builder — configure via [build.yaml] in your app.
///
/// Options:
/// - `endpoint` — secured GraphQL URL (fetches live introspection at build time)
/// - `api_key_env` — env var for X-Apito-Key (default `APITO_API_KEY`)
/// - `tenant_id_env` — env var for X-Apito-Tenant-ID (default `APITO_TENANT_ID`)
/// - `schema_file` — fallback/cached introspection JSON (default `apito_schema.json`)
/// - `output` — generated Dart root (default `lib/generated`)
/// - `models` — comma string or list to limit models
/// - `generate_providers`, `generate_where`, `generate_operations`
class ApitoGeneratorBuilder implements Builder {
  ApitoGeneratorBuilder(this.options);

  final Map<String, dynamic> options;

  @override
  Map<String, List<String>> get buildExtensions => const {
        'apito_schema.json': ['lib/generated/apito_generated.dart'],
      };

  @override
  Future<void> build(BuildStep buildStep) async {
    final schema = await _resolveSchema(buildStep);
    if (schema.models.isEmpty) {
      log.warning('Apito codegen: no models resolved — check endpoint/env or schema_file.');
      return;
    }

    final output = options['output'] as String? ?? 'lib/generated';
    final codegen = ApitoCodegen(
      generateProviders: options['generate_providers'] as bool? ?? true,
      generateWhere: options['generate_where'] as bool? ?? true,
      generateOperations: options['generate_operations'] as bool? ?? true,
      clientProviderName:
          options['client_provider_name'] as String? ?? 'apitoClientProvider',
    );

    final outputDir = p.join(Directory.current.path, output);
    final schemaAsset = options['schema_file'] as String? ?? 'apito_schema.json';
    String? introspectionJson;
    final introPath = _resolveFilePath(
      options['introspection_file'] as String? ?? 'apito_introspection.json',
    );
    if (introPath != null) {
      introspectionJson = File(introPath).readAsStringSync();
    } else {
      final inputId = AssetId(buildStep.inputId.package, schemaAsset);
      if (await buildStep.canRead(inputId)) {
        introspectionJson = await buildStep.readAsString(inputId);
      }
    }
    await codegen.writeAll(
      schema: schema,
      outputDir: outputDir,
      introspectionJson: introspectionJson,
    );

    // build_runner allows only the primary output in [buildExtensions];
    // other generated files are written to source via [writeAll] above.
    final barrelPath = p.join(outputDir, 'apito_generated.dart');
    final barrel = await File(barrelPath).readAsString();
    await buildStep.writeAsString(
      AssetId(buildStep.inputId.package, p.join(output, 'apito_generated.dart')),
      barrel,
    );
  }

  Map<String, String> _environment() {
    final env = Map<String, String>.from(Platform.environment);
    final secretsFile = options['secrets_file'] as String?;
    if (secretsFile != null && secretsFile.isNotEmpty) {
      env.addAll(_parseEnvFile(secretsFile));
    }
    return env;
  }

  String? _resolveFilePath(String relativePath) {
    if (p.isAbsolute(relativePath) && File(relativePath).existsSync()) {
      return relativePath;
    }
    var dir = Directory.current;
    for (var i = 0; i < 8; i++) {
      final candidate = File(p.join(dir.path, relativePath));
      if (candidate.existsSync()) return candidate.path;
      final parent = dir.parent;
      if (parent.path == dir.path) break;
      dir = parent;
    }
    return null;
  }

  Map<String, String> _parseEnvFile(String path) {
    final resolved = _resolveFilePath(path);
    if (resolved == null) return {};
    final file = File(resolved);
    final out = <String, String>{};
    for (final line in file.readAsLinesSync()) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
      final eq = trimmed.indexOf('=');
      if (eq <= 0) continue;
      final key = trimmed.substring(0, eq).trim();
      var value = trimmed.substring(eq + 1).trim();
      if ((value.startsWith('"') && value.endsWith('"')) ||
          (value.startsWith("'") && value.endsWith("'"))) {
        value = value.substring(1, value.length - 1);
      }
      out[key] = value;
    }
    return out;
  }

  Future<ApitoSchema> _resolveSchema(BuildStep buildStep) async {
    final reader = SchemaReader();
    final modelFilter = _modelFilter();
    final endpoint = options['endpoint'] as String?;
    final env = _environment();

    if (endpoint != null && endpoint.trim().isNotEmpty) {
      final apiKeyEnv = options['api_key_env'] as String? ?? 'APITO_API_KEY';
      final tenantIdEnv =
          options['tenant_id_env'] as String? ?? 'APITO_TENANT_ID';
      final apiKey = env[apiKeyEnv] ?? '';
      final tenantId = env[tenantIdEnv];

      if (apiKey.isEmpty) {
        throw StateError(
          'Apito codegen: options.endpoint is set but $apiKeyEnv is empty. '
          'Set $apiKeyEnv in the environment or options.secrets_file (e.g. secrets.env).',
        );
      }

      log.info('Fetching Apito schema from $endpoint');
      return reader.fetchFromEndpoint(
        endpoint: endpoint.trim(),
        apiKey: apiKey,
        tenantId: tenantId,
        modelFilter: modelFilter,
      );
    }

    final schemaAsset = options['schema_file'] as String? ?? 'apito_schema.json';
    final inputId = AssetId(buildStep.inputId.package, schemaAsset);

    if (!await buildStep.canRead(inputId)) {
      throw StateError(
        'Apito codegen: neither options.endpoint nor $schemaAsset is available. '
        'Set endpoint + APITO_API_KEY in build.yaml, or add $schemaAsset.',
      );
    }

    log.info('Reading Apito schema from $schemaAsset');
    final schemaJson = await buildStep.readAsString(inputId);
    return reader.parseJsonFile(schemaJson, modelFilter: modelFilter);
  }

  List<String>? _modelFilter() {
    final raw = options['models'];
    if (raw == null) return null;
    if (raw is String) {
      return raw
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    if (raw is List) return raw.map((e) => e.toString()).toList();
    return null;
  }
}

Builder apitoGeneratorBuilder(BuilderOptions options) =>
    ApitoGeneratorBuilder(options.config);
