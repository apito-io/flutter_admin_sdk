# flutter_admin_sdk — Handoff

## Branch
- (check submodule `git branch` before push)

## Done
- `lib/src/reports/` — `food_order_report_summary`, `ledger_report_summary`, `report_date_range`, `food_name_lookup`; exported via `lib/reports.dart`; tests in `test/reports_test.dart`
- **`buildWhereJson` fix:** `between` and `nbetween` added to `_operatorKeys` so `.where({'date': {'between': [a,b]}})` passes through correctly
- Unit test in `test/filter_test.dart` for `between` passthrough

## Broken / watch
- Any client using `.where({... 'between': [...]})` before this fix sent invalid GraphQL — verify consumers after SDK bump

## Next
- Bump/version sync if monorepo release workflow requires it (`apito-release-sync` skill)
- Rosna app to adopt codegen where filters are hand-built

## Do not touch
- Don't break open-core vs pro field naming contracts without schema-hook pattern

## Last Updated
2026-07-09
