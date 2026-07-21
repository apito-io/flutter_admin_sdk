# flutter_admin_sdk — AI Changelog

Not git history — the *reasoning* behind changes. Newest on top.
Format per entry: date, **Changed**, **Why**, **Affected**.

---
## 2026-07-21
- **Changed:** Standardized project scope on `X-Apito-Project-Id`; explicit
  project methods now override configured project scope per request.
- **Why:** Keep GraphQL variables and `apt_` authorization scope aligned.
- **Affected:** runtime client/auth, header tests, README/changelog.

## 2026-07-14
- **Changed:** v0.6.6 — `getTenant(projectId, tenantId, {status})`; CONTRACT/CHANGELOG/SYNC_SUMMARY + tests.
- **Why:** Close getTenant parity with JS/Go; Kisti/Rosna consumers replace searchTenants exact-id loops.
- **Affected:** `lib/src/runtime/auth.dart`, `pubspec.yaml`, `CHANGELOG.md`, `CONTRACT.md`, `SYNC_SUMMARY.md`, `test/tenant_catalog_test.dart`

## 2026-07-13
- **Changed:** Documented full tenant catalog surface; `searchTenants` validation (`projectId` required); v0.6.4. `/sync-sdk-all apply flutter`.
- **Why:** `searchTenants` shipped in tenant-parity session but CONTRACT/CHANGELOG lagged; Kisti `BillingTenantService` depends on it.
- **Affected:** `auth.dart`, `pubspec.yaml`, `CHANGELOG.md`, `CONTRACT.md`, `README.md`, `SYNC_SUMMARY.md`, `test/tenant_catalog_test.dart`

## 2026-07-09
- **Changed:** `buildWhereJson` — `between` and `nbetween` in `_operatorKeys`; test in `filter_test.dart`. Reports module (`food_order_report_summary`, `ledger_report_summary`, date range helpers).
- **Why:** Rosna Order Report hung on Apito error `date: between requires two values` — SDK was rewriting `between: [start,end]` to `between: {eq: [start,end]}`.
- **Affected:** `lib/src/runtime/filter.dart`, `lib/src/reports/*`, `lib/reports.dart`, `test/filter_test.dart`, `test/reports_test.dart`

## 2026-07-06
- **Changed:** Bootstrapped knowledge system for this repo.
- **Why:** Cross-LLM durable knowledge + working memory.
- **Affected:** this repo only.

Last Updated: 2026-07-21
