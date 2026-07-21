# Changelog

All notable changes to `flutter_admin_sdk` are documented here.

## [Unreleased]

## [0.6.7] - 2026-07-21

### Changed

- **Canonical project scope** — project headers now use `X-Apito-Project-Id`. Runtime calls that accept `projectId` pass the same value as a per-request header override, alongside explicit tenant context where applicable.
- **Unified `apt_` access tokens (hard cut)** — `buildHeaders` sends `apt_` tokens as `Authorization: Bearer` + `X-Use-Cookies: false` only; dropped the compatibility `X-Apito-Key` dual header. Legacy `cli-`/`sdk-`/`mcp-` prefixed keys now throw `ArgumentError('TOKEN_FORMAT_RETIRED…')` instead of being sent to the engine.

## [0.6.6] - 2026-07-14

### Added

- **`getTenant(projectId, tenantId, {status})`** — load one SaaS catalog tenant by exact id via `searchTenants` (default `status`: `active`). Returns `null` when no exact id match. Parity with `js-admin-sdk` and `go-admin-sdk`.

## [0.6.5] - 2026-07-13

### Changed

- **`deleteTenant`** — soft delete only (`status=deleted`); content and mirror remain until Console hard delete.
- **`searchTenants`** — optional `status` named parameter (`active`, `deleted`, `all`).

## [0.6.4] - 2026-07-13

### Added

- **`searchTenants(projectId, {limit, offset, q, status})`** — paginated SaaS catalog search with `SearchTenantsResponse` (`tenants`, `count`). Optional `status`: `active` (default), `deleted`, or `all`. Parity with engine system GraphQL and `js-admin-sdk` / `go-admin-sdk`.
- **Tenant catalog lifecycle** — `getTenants`, `createTenant`, `updateTenant`, `deleteTenant` (soft delete) are **system GraphQL only**; do not use secured model CRUD (`tenantList` / generated `createTenant`) for catalog provisioning after tenant user-parity.

## [0.6.3] - 2026-07-11

### Added

- **`searchUsers` optional `q`** — named parameter filters email, username, phone, or id (case-insensitive contains). Parity with engine GraphQL and `js-admin-sdk`.

## [0.6.2] - 2026-07-09

### Added

- **Reports module** (`lib/reports.dart`) — `food_order_report_summary`, `ledger_report_summary`, `report_date_range`, `food_name_lookup` for Rosna/mobile report UIs.

### Fixed

- **`buildWhereJson`** — `between` and `nbetween` operators pass through unchanged (fixes Apito `date: between requires two values` when filtering report date ranges).

## [0.6.1] - 2026-07-05

### Added

- **List `relation` filters** — `QueryBuilder.relationEq`, `.filters(List<CrudFilter>)`, `RelationCrudFilter`, and `buildListRelationFilter` emit the secured GraphQL `relation` arg (`{ owner: { _id: { eq } } }`).
- **Parent connection scope** — `withParentConnectionScope` for embedded show-page lists; `connectFilter` deprecated.
- **Schema relation keys codegen** — `{Model}RelationKeys` constants and `{Model}Connect.*` factories from introspection (`known_as` + connect payload keys).
- **Riverpod list providers** — optional `relationFilters` on generated list providers.

### Changed

- **List/count GraphQL variables** — use `relation` (not legacy `relationWhere`); optional `connection` only for parent-document scope.
- **Sort payload** — lowercase `asc` / `desc` (Apito engine convention).
- **Cloudflare Workers v1 (`cloudflare_full`)** — document `generateTenantToken` / tenant catalog and Google `loginUser` limitations on Workers; password `loginUser` unchanged.

## [0.6.0] - 2026-06-21

### Added

- **Riverpod provider codegen** — `generate_providers: true` emits list/detail/create/update/delete providers with schema-aware default sort.
- **Media field sub-selection** — `queryFields` excludes media types; secured list/get queries use safe selections.

### Changed

- **Mutation providers** — upsert mutations call `.select(queryFields)` and guard `ref.invalidate` with `ref.mounted`.
- **Model codegen** — `defaultSortField` derived from schema for stable list ordering.

## [0.5.0] - 2026-06-11

### Added

- **`tenantId` on user CRUD** — optional `tenantId` on `searchUsers`, `CreateUserParams`, and `UpdateUserParams`; sent as GraphQL `tenant_id` on pro SaaS engines (parity with `js-admin-sdk` v3.7.0 and `go-admin-sdk` v2.6.0). Omit on general projects.

### Changed

- **`updateUser` validation** — `tenantId` must be non-empty after trim when it is the only field being updated.
- **Docs** — README, CONTRACT, SYNC_SUMMARY note tenant-aware user ops.

## [0.4.3] - 2026-06-15

### Changed

- **`loginUser` Google auth (engine behavior)** — Verified Google email may auto-link to an existing project user instead of creating a duplicate. New engine errors: `google email not verified`, `google account already linked to another user`, `multiple users matched this email`. No SDK API changes.
- **`createUser` / `updateUser` uniqueness (engine behavior)** — Open-core projects reject duplicate email and phone project-wide. Stable errors: `email already exists for this project`, `phone already exists for this project`.

## [0.4.0] - 2026-06-08

### Added

- **`loginUser` `tenantId`** — optional `tenantId` on `LoginUserParams`; passed as GraphQL `tenant_id` on system `loginUser`. Required by engine for SaaS projects with per-tenant separate databases.

### Changed

- **Docs** — README login example shows `tenantId` for per-tenant DB SaaS.

## [0.3.0] - 2026-06-05

### Added

- **`loginUser` `google_id_token`** — native mobile Google sign-in via `idToken` on `LoginUserParams`.

### Changed

- **Project files REST** — default `restBaseUrl` resolves to `/secured`; paths `/secured/files/upload|list|delete`.

## [0.2.0] - 2026-06-05

- Package rename `flutter_apito_sdk` → `flutter_admin_sdk`
- Storage REST + auth/admin GraphQL surface aligned with JS/Go admin SDKs
- Naming vectors + codegen SDL parity
