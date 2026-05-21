#!/usr/bin/env bash
# Vercel build: install Flutter (cached in .flutter/) and compile web release.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

FLUTTER_DIR="$ROOT/.flutter"
if [ ! -x "$FLUTTER_DIR/bin/flutter" ]; then
  echo ">> Cloning Flutter (stable)…"
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$FLUTTER_DIR"
fi
export PATH="$FLUTTER_DIR/bin:$PATH"

flutter config --enable-web --no-analytics
flutter precache --web --no-android --no-ios --no-linux --no-macos --no-windows --no-fuchsia
flutter pub get

# Public URL for “copy link” in the app (Vercel sets VERCEL_URL per deployment).
PUBLIC_URL="${PUBLIC_WEB_URL:-}"
if [ -z "$PUBLIC_URL" ] && [ -n "${VERCEL_PROJECT_PRODUCTION_URL:-}" ]; then
  PUBLIC_URL="https://${VERCEL_PROJECT_PRODUCTION_URL}"
elif [ -z "$PUBLIC_URL" ] && [ -n "${VERCEL_URL:-}" ]; then
  PUBLIC_URL="https://${VERCEL_URL}"
fi
if [ -z "$PUBLIC_URL" ]; then
  PUBLIC_URL="https://localhost"
fi

DEFINES=(
  "--dart-define=SUPPORT_EMAIL=${SUPPORT_EMAIL:-kyle.farrugia.j94928@mcast.edu.mt}"
  "--dart-define=PUBLIC_WEB_URL=${PUBLIC_URL}"
)
if [ -n "${FEEDBACK_FORM_URL:-}" ]; then
  DEFINES+=("--dart-define=FEEDBACK_FORM_URL=${FEEDBACK_FORM_URL}")
fi

echo ">> Building web (PUBLIC_WEB_URL=$PUBLIC_URL)"
flutter build web --release --base-href "/" "${DEFINES[@]}"
