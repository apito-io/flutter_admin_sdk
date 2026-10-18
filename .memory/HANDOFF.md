# Handoff — flutter_admin_sdk 2026-10-16

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
