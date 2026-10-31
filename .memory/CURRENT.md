# flutter_admin_sdk — Current

- **Realtime 0.6.16 (2026-10-30, uncommitted):** `graphql-transport-ws` on one socket. `subscribe`, `modelChanges`, `broadcast`. Web token auth uses `POST .../subscription-ticket` and subprotocol `apito-ticket.<ticket>`. Generated `{Model}Changed` and `watch*List` refetch on `resyncRequired`. No replay. Ask before tag or `./command.sh save`.

- **Discovery metadata (2026-10-18, uncommitted):** Apache `LICENSE`, pubspec homepage, repository, topics, and a README opening. `publish_to: none` stays. `dart pub publish --dry-run` failed because `lib/` imports `package:build` from dev_dependencies. Leave `.memory` out of the public diff. Ask before `./command.sh save`.

- **Facebook token (2026-10-16, uncommitted):** `facebook_access_token` uses the canonical `loginUser` query's optional `access_token` argument. Published Android/iOS binaries omit it and remain valid after the engine deploy. No version bump. Ask before tag or `./command.sh save`.
- **0.6.14 (2026-09-13, untagged until you confirm):** `oauthState`,
  `searchUsers` selects `username`, CHANGELOG/CONTRACT document `registerUser`.
- `udbhabon/platform/flutter_admin_sdk` is a symlink to this repo.
- Prior: **0.6.13** ApitoProjectPayment REST. No partner GraphQL.

## Last Updated

2026-10-30
