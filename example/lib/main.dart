import 'dart:io';

import 'package:flutter_admin_sdk/flutter_admin_sdk.dart';

import 'apito_config.dart';
import 'demo_generated.dart' show runGeneratedDemo;

/// Runnable demo: secured GraphQL list + optional generated types.
///
/// Run from example/: `./tool/run_example.sh`
Future<void> main(List<String> args) async {
  ExampleApitoConfig.ensureConfigured();

  final client = ApitoClient(
    config: ApitoConfig(
      endpoint: ExampleApitoConfig.endpoint,
      apiKey: ExampleApitoConfig.apiKey,
      tenantId: ExampleApitoConfig.tenantId,
    ),
  );

  try {
    if (args.contains('--codegen-only')) {
      print('Run: dart run build_runner build (see example/build.yaml)');
      return;
    }

    print('Endpoint: ${ExampleApitoConfig.endpoint}');
    print('Tenant:   ${ExampleApitoConfig.tenantId}');
    print('');

    // Runtime chainable API (no build_runner required)
    final loans = await client
        .from('loan')
        .select(['loan_id', 'customer_name', 'total_amount', 'loan_status'])
        .where({'tenant_id': Eq(ExampleApitoConfig.tenantId)})
        .page(1)
        .limit(5)
        .list();

    print('loanList: ${loans.total} total, ${loans.data.length} on page 1');
    for (final row in loans.data) {
      final d = row.data;
      print(
        '  - ${row.id} | ${d['loan_id']} | ${d['customer_name']} | '
        '${d['total_amount']} | ${d['loan_status']}',
      );
    }

    final count = await client
        .from('loan')
        .where({'tenant_id': Eq(ExampleApitoConfig.tenantId)})
        .count();
    print('\nloanListCount: $count');

    await runGeneratedDemo(client, tenantId: ExampleApitoConfig.tenantId);
  } on ApitoError catch (e) {
    stderr.writeln('ApitoError: $e');
    exitCode = 1;
  } finally {
    client.close();
  }
}

