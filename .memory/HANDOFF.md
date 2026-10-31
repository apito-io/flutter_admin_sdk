# Handoff — flutter_admin_sdk 2026-10-30

- **Done:** Native subscription client, watch helpers, codegen subscription document. Pubspec **0.6.16**. `CONTRACT.md` section 5 states the JS/Go parity shape without implementing those clients.
- **Verified:** `dart test test/subscription_client_test.dart test/operation_contract_test.dart test/client_headers_test.dart` passed.
- **Not done:** No tag. Engine on 5050 does not have the ticket route until restart.
- **Do not:** Put the credential in the socket URL. `./command.sh save` until asked.

# Handoff — flutter_admin_sdk 2026-10-18

- **Done:** LICENSE, pubspec discovery fields, README opening. `publish_to: none` was not removed.
- **Broken:** Dry-run cannot publish: `package:build` is imported from `lib/` and listed only under dev_dependencies.
- **Do not:** Publish or remove `publish_to: none`. Leave `.memory` out of the public diff. `./command.sh save` until asked.

- **Done:** `loginUser` keeps one canonical query with optional `access_token`; Facebook supplies it only through `facebook_access_token`. Published clients keep their old query.
- **Verified:** `dart format --output=none --set-exit-if-changed lib/src/runtime/auth.dart` passed. Full `dart test` still has unrelated existing failures in `project_plans_test.dart` and `naming_test.dart`.
- **Not done:** Version bump and tag.
- **Do not:** `./command.sh save` until asked.

- **Done:** `loginUser` query includes `$access_token` for `facebook_access_token`.
- **Not done:** Version bump and tag.
- **Do not:** `./command.sh save` until asked.

# Handoff — flutter_admin_sdk 2026-09-13

## Done (uncommitted / untagged)

- **0.6.14:** `oauthState(projectId, provider)`; `searchUsers` `username`;
  `registerUser` documented (API existed since 0.6.11).
- Platform-app already uses `registerUser` + `loginUser`.
- Do not port `searchPartners` / Casbin / JS React UI.

## Do not

- Tag/push **v0.6.14** until you confirm.
- Port partner GraphQL unless an app UI lists partners.

## Last Updated

2026-09-13
