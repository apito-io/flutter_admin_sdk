# flutter_admin_sdk example

Live demo against **secured GraphQL** at `http://localhost:5050/secured/graphql`.

## Setup

```bash
cd example
cp secrets.env.example secrets.env
# Set APITO_API_KEY and APITO_TENANT_ID
dart pub get
```

## Generate types

**Only** via [`build.yaml`](build.yaml) + `build_runner`:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Credentials are loaded from `secrets.env` (`options.secrets_file` in `build.yaml`). Live schema is fetched from `options.endpoint`.

## Run demo

```bash
dart run \
  --define=APITO_GRAPHQL_ENDPOINT=http://localhost:5050/secured/graphql \
  --define=APITO_API_KEY=your_key \
  --define=APITO_TENANT_ID=your_tenant \
  lib/main.dart
```

Or `./tool/run_example.sh` (runs `build_runner` if generated code is missing, then the demo).

## Requirements

- Apito on `localhost:5050`
- Published schema (`loanList`, etc.)
- `X-Apito-Tenant-ID` for SaaS tenant scope

`secrets.env` is gitignored.
