# flutter_admin_sdk — Decisions

Format: Decision / Reason / Alternatives / Status. Newest on top.

---

### loginUser schema evolution stays compatible with published apps

**Decision:** Keep one canonical `loginUser` query. `access_token` is an optional argument, just like `id_token`; published apps omit it, while a new Facebook build supplies it with `authMethod: facebook_access_token`.

**Reason:** Store binaries cannot be updated when the engine ships, so the engine change must be additive. Existing binaries remain valid against the new schema. The engine ships before an SDK/app release that sends the new argument.

**Alternatives:** Fork the query by auth method or overload an unrelated argument. Rejected as brittle and semantically unclear.

**Status:** Accepted, 2026-10-16.

---
_TODO: distilled from completed plans in `archive/plans/`._

Last Updated: 2026-07-06
