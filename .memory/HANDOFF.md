# flutter_admin_sdk — Handoff

## Branch
- (check submodule `git branch` before push)

## Done
- **2026-07-21:** Canonical project header and explicit project-method request
  overrides; focused header tests plus full Dart test/analyze.
- **v0.6.6 (2026-07-14):** `getTenant(projectId, tenantId, {status})`; CONTRACT/CHANGELOG/SYNC_SUMMARY + tests
- Earlier v0.6.4/5: tenant catalog docs + `searchTenants` validation
- `lib/src/reports/` — food/ledger report summaries; `buildWhereJson` `between`/`nbetween` fix

## Broken / watch
- Any client using `.where({... 'between': [...]})` before the between fix sent invalid GraphQL — verify consumers after SDK bump
- getTenant consumers must not put system keys on device (Rosna uses Worker BFF)

## Next
- Version sync / tag if release workflow requires (`apito-release-sync`)
- Rosna/Kisti adopt getTenant paths (kisti billing already; rosna via Worker)

## Do not touch
- Don't break open-core vs pro field naming contracts without schema-hook pattern

## Last Updated
2026-07-21
