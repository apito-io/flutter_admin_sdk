## 2026-10-18 — pub.dev metadata, still unpublished

- **Changed:** Added an Apache-2.0 LICENSE and pubspec homepage, repository, issue tracker, documentation, and topics. README leads with REST and GraphQL.
- **Why:** The package had no LICENSE and no pub.dev discovery fields. It is not ready to publish.
- **Affected:** `LICENSE`, `pubspec.yaml`, `README.md`. `publish_to: none` remains. Dry-run fails on the `package:build` import. No publish.

## 2026-10-16 — Canonical Facebook token login query

- **Changed:** Kept one `loginUser` document with optional `access_token`; the Facebook method supplies the variable and existing methods stay compatible for published clients.
- **Why:** Store binaries cannot update alongside the engine. The engine ships the additive schema before a new SDK/app release uses the argument.
- **Affected:** `auth.dart`, SDK decision docs. Format passed; full `dart test` retains unrelated existing failures in `project_plans_test.dart` and `naming_test.dart`. No version bump. Ask before tag or `./command.sh save`.

## 2026-10-15 — Facebook access token on loginUser

- **Changed:** `LoginUserParams.accessToken`. The login query sends `access_token` when the method is `facebook_access_token`.
- **Why:** Kisti’s Facebook button has a user token, not an OAuth code.
- **Affected:** `auth.dart`, `admin_models.dart`. No pubspec version bump. Ask before tag or `./command.sh save`.

## 2026-09-13 — v0.6.14 oauthState + searchUsers username

- **Changed:** `oauthState`; `searchUsers` selects `username`; `ApitoUser.username`;
  CHANGELOG/CONTRACT list `registerUser` (public signup, not admin `createUser`).
- **Why:** JS 3.14.x parity that Flutter mobile actually needs. Skip partners/Casbin/React.
- **Affected:** `auth.dart`, `admin_models.dart`, `pubspec` **0.6.14**. Ask before tag/push.

## 2026-08-12 — v0.6.13 ApitoProjectPayment REST

- **Changed:** `verifyProjectPayment` / `getTenantSubscription` /
  `cancelTenantSubscription` + `ProjectTenantSubscription`;
  `projectPaymentApiBaseUrl`; CONTRACT monetization; bump **0.6.13**.
- **Why:** Apps must cancel via engine (Play first) — no bespoke HTTP or
  hardcoded manage URLs.
- **Affected:** `lib/src/runtime/project_payment.dart`, barrel, tests,
  CONTRACT/CHANGELOG. Tagged **v0.6.13**.

## 2026-08-09 — Tenant planTier + myTenant

- **Changed:** `planTier` on tenant catalog models/create/update GraphQL;
  `ApitoClient.myTenant()` for app-user token.
- **Why:** Protiva plan gating + domain rename; control-plane tier readable
  without system token in the app.
- **Affected:** `admin_models.dart`, `auth.dart`. Ask before bump/commit.

## 2026-08-07 — v0.6.10 listModelSystem connection + apt_ header

- **Changed:** `listModelSystem(connection:)`; apt_ apiKey stays
  `X-Apito-Key`; media raw-type detection. Tag **v0.6.10** pushed.
- **Why:** Parent-scoped system lists; engine stacks that reject Bearer for
  apt_ bootstrap keys.
- **Affected:** `client.dart`, `schema_reader.dart`, `query_builder.dart`.

## 2026-07-29 — v0.6.9 nested-snake connections + report keys

- **Changed:** Nested connection field helpers emit snake; reports read
  `food_list` / `transaction_category` (camel fallback); `ak_` →
  `X-Apito-Key`; `deleteModelSystem`; CHANGELOG/pubspec **0.6.9**.
- **Why:** Match engine nested-snake GraphQL for Rosna mobile.
- **Affected:** `naming.dart`, `client.dart`, report helpers. Ask before push.

---

## 2026-07-28 — nested GraphQL snake (no mapping)

- **Changed:** Adopt snake nested relation keys; drop camel↔snake alias/connect maps; Refine resources use stored model ids where applicable.
- **Why:** Engine nested GraphQL is snake; only roots stay camel.
- **Affected:** connectionFields, connect forms, resource config, SDK naming helpers.

---

# flutter_admin_sdk — AI Changelog

Not git history — the *reasoning* behind changes. Newest on top.
Format per entry: date, **Changed**, **Why**, **Affected**.

---
## 2026-07-27 — v0.6.8 canonicalize long model ids

- **Changed:** canonicalizeModelName skips run-on for already-canonical ids.
- **Why:** Parity with open-core 1.8.5 / JS 3.11.6.
- **Affected:** `lib/src/runtime/naming.dart`, tests. Version **0.6.8**.

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
