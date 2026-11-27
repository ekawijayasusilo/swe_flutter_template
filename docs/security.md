# Security

How this repo is checked, what to do when a check fails, and the one-time setup that keeps the
Firebase keys safe. For an overview of the checks, see the [README](../README.md#security-).
To report a vulnerability, see [SECURITY.md](../SECURITY.md).

- [Firebase API keys](#firebase-api-keys)
- [Handling findings](#handling-findings)
- [Maintaining the checks](#maintaining-the-checks)
- [Known limits](#known-limits)

## Firebase API keys

The `google_api_key` secret-scanning alerts on this repo are **Firebase client API keys**. They sit in:

- `lib/firebase_options_*.dart`
- `android/app/src/*/google-services.json`
- `ios/flavors/*/GoogleService-Info.plist`
- `web/firebase-messaging-sw-*.js`

These keys are public by design: they ship inside every app binary and web bundle, so they can't
be kept secret. They're protected by **API key restrictions**, **Security Rules** and, later,
**App Check**. The same applies to the public VAPID keys in `lib/web_push_config.dart`: no action
needed.

> **Warning:** an unrestricted key can call any API enabled on the project. Firebase can enable the
> Gemini / Generative Language API automatically, so an unrestricted key could run up costs on
> your bill.

### Restriction checklist

In the [Google Cloud console](https://console.cloud.google.com/apis/credentials) → **APIs &
Services** → **Credentials**, for each project:

| Project | Flavors | Android key | iOS key | Browser key |
|---|---|---|---|---|
| `swe-flutter-template` | production | `id.swe.app` + SHA-1 of the release signing key (Play App Signing) | `id.swe.app` | Production web origin(s) |
| `swe-flutter-template-staging` | development, staging | `id.swe.app.dev` and `id.swe.app.stg` + SHA-1 of each developer's debug key and the CI key | `id.swe.app.dev`, `id.swe.app.stg` | `localhost` and the staging web origin(s) |

For **every** key:

- [ ] **Application restriction** set as in the table (Android apps, iOS apps or HTTP referrers).
- [ ] **API restriction** set to *Restrict key*, allowing only the
  [APIs Firebase needs](https://firebase.google.com/docs/projects/api-keys#faq-required-apis-for-restricted-firebase-api-key) for the
  products this app uses: Analytics, Authentication, Cloud Messaging, Crashlytics, Performance
  Monitoring and Remote Config.
- [ ] Gemini / Generative Language API is **not** in the allowed list.

A repo generated from this template has its own Firebase projects and keys: run this checklist
there too.

### Closing the alerts

Only after the checklist is done for the key in the alert:

```bash
REPO=owner/repo
gh api "repos/$REPO/secret-scanning/alerts?state=open" --jq '.[] | "\(.number) \(.secret_type) \(.locations_url)"'
gh api -X PATCH "repos/$REPO/secret-scanning/alerts/<number>" \
  -f state=resolved -f resolution=wont_fix \
  -f resolution_comment="Firebase client API key, public by design. Restricted to <app IDs / referrers> and Firebase APIs only (no Generative Language API)."
```

### App Check (deferred)

App Check proves requests come from your real app, so a copied key alone can't call your backend.
It needs a provider per platform (Play Integrity on Android, App Attest on iOS, reCAPTCHA
Enterprise on web), debug providers for the development and staging flavors, and enforcement
turned on per Firebase product. It will be added in its own change.

## Handling findings

| Check | Blocks merge | What to do |
|---|---|---|
| `dependency-review` | Yes (high/critical) | Upgrade the dependency to a fixed version, or don't add it |
| `actions-lock` | Yes | `gh actions-lock` (or `gh actions-lock --relock`), then commit `.github/workflows/actions.lock` |
| `betterleaks` | Yes | **Rotate the secret first**: it's already public once pushed. Then remove it from the branch. For a false positive, add `betterleaks:allow <reason>` on that line |
| CodeQL | Yes (high/critical security alerts, or errors) | Fix the code or workflow. If it's a false positive, dismiss the alert with a written reason |
| zizmor | No | Fix, or suppress on that line with `# zizmor: ignore[<audit>] <reason>` |
| Native deps (`native_deps`) | No | Bump the FlutterFire packages (they pin the Firebase Android BoM and iOS SDK). For other plugins, bump the plugin |
| Scorecard | No | Review the check that dropped. Some are accepted (see [Known limits](#known-limits)) |
| GitHub secret scanning | Push protection blocks known token formats | Rotate, then remove. Firebase keys: see [above](#firebase-api-keys) |

Report-only results are under **Security** → **Code scanning** (tools `zizmor`, `osv-scanner-ios`,
`Scorecard`) and **Dependabot** (Maven dependencies from the Android graph).

## Maintaining the checks

- **Workflow lockfile.** Every action in `.github/workflows/*` is locked in `actions.lock`. After
  changing any `uses:`, run `gh actions-lock` and commit the lockfile; never edit it by hand. Install
  the CLI with `gh extension install github/gh-actions-lock`. Renovate relocks in its own PRs. If a
  Dependabot security PR fails `actions-lock`, run `gh actions-lock --relock` on its branch.
- **Reusable workflows** (very_good_workflows) aren't covered by the lockfile, so they're pinned by
  commit SHA with a `# vX.Y.Z` comment. Renovate updates both.
- **Betterleaks exceptions** live in [`.betterleaks.toml`](../.betterleaks.toml). Each one matches
  rule, path and value shape. Don't widen them without review: a broad exception hides real
  secrets.
- **Pinned CLI versions** (Betterleaks, OSV-Scanner) are env vars in their workflows, bumped by a
  Renovate regex manager. Both are checked against the release checksums before running.
- **Workflow permissions.** Every workflow starts with `permissions: {}` and grants per job.
  Checkouts use `persist-credentials: false`.

## Known limits

- **No Dart SAST.** CodeQL doesn't support Dart. CodeQL covers workflows and the web JavaScript only.
- **Pub advisory coverage is thin**, and OSV has few Swift advisories, so a clean iOS scan isn't
  proof of safety.
- **Secret scanning detects after exposure** on a public repo. Prevention relies on push protection
  (provider formats only, not Google API keys) and the optional pre-commit hook.
- **Actions inside very_good_workflows float** (`@v7`, `@main`). Mitigated by read-only tokens and
  passing them no secrets.
- **Scorecard `Pinned-Dependencies` scores low**: `actions.lock` pins by lockfile, which Scorecard
  doesn't recognise. Accepted.
- **The Scorecard action runs a Docker image by tag** (`ghcr.io/ossf/scorecard-action:vX`), which the
  lockfile doesn't pin.
- **CLI checksums come from the same release** as the binary. They catch corrupted or swapped
  files, not a compromised release.
- **Renovate's lockfile support is new.** If it ever misses a relock, the `actions-lock` check fails
  the PR rather than merging an unlocked action.
- **Betterleaks v2** changes its CLI and config. The migration is a follow-up.
