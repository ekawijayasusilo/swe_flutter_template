#!/usr/bin/env bash
# Configures Firebase for iOS for every flavor x build mode. macOS only:
# FlutterFire CLI skips the plist, Xcode build phase and firebase.json writes elsewhere.
#
# Usage (from repo root): bash scripts/flutterfire-ios-one-time-setup.sh
# Optional: FIREBASE_SERVICE_ACCOUNT=/path/to/key.json (CI); otherwise uses `firebase login`.
set -euo pipefail

auth=()
if [[ -n "${FIREBASE_SERVICE_ACCOUNT:-}" ]]; then
  auth=(--service-account="$FIREBASE_SERVICE_ACCOUNT")
fi

configure() {
  local flavor=$1 project=$2 bundle_id=$3
  # The CLI maps one Xcode build configuration per run.
  for mode in Debug Profile Release; do
    # ${auth[@]+...}: empty-array expansion is an error under `set -u` in macOS bash 3.2.
    flutterfire configure \
      --yes \
      --project="$project" \
      --platforms=ios \
      --out="lib/firebase_options_${flavor}.dart" \
      --ios-bundle-id="$bundle_id" \
      --ios-build-config="${mode}-${flavor}" \
      --ios-out="ios/flavors/${flavor}/GoogleService-Info.plist" \
      ${auth[@]+"${auth[@]}"}
  done
}

configure development swe-flutter-template-staging id.swe.app.dev
configure staging swe-flutter-template-staging id.swe.app.stg
configure production swe-flutter-template id.swe.app
