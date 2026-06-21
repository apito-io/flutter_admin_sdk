/// Apito connection for the SDK example.
///
/// Values are loaded from [secrets.env] via `tool/run_example.sh`, or from
/// `--dart-define` / environment when running manually.
library;

class ExampleApitoConfig {
  ExampleApitoConfig._();

  static const endpoint = String.fromEnvironment(
    'APITO_GRAPHQL_ENDPOINT',
    defaultValue: 'http://localhost:5050/secured/graphql',
  );

  static const apiKey = String.fromEnvironment(
    'APITO_API_KEY',
    defaultValue: '',
  );

  static const tenantId = String.fromEnvironment(
    'APITO_TENANT_ID',
    defaultValue: '01KSWVZA49Q1C39J5DKDW7P67T',
  );

  static bool get isConfigured => apiKey.isNotEmpty;

  static void ensureConfigured() {
    if (!isConfigured) {
      throw StateError(
        'APITO_API_KEY is empty. Run: ./tool/run_example.sh\n'
        'Or: cp secrets.env.example secrets.env && edit secrets.env',
      );
    }
  }
}
