#!/usr/bin/env bash
set -e

# 1) Locate the real Debug-iphonesimulator build of Hound.app (exclude Index.noindex)
APP_PATH=$(
  find "$HOME/Library/Developer/Xcode/DerivedData" \
    -type d \
    -not -path "*/Index.noindex/*" \
    -path "*/Build/Products/Debug-iphonesimulator/Hound.app" \
    -print -quit
)
if [[ ! -d "$APP_PATH" ]]; then
  echo "❌ Hound.app (Debug simulator, non-Index.noindex) not found under DerivedData."
  exit 1
fi
echo "Using app bundle: $APP_PATH"

# 2) Use fixed bundle ID
BUNDLE_ID="com.example.Pupotty"
echo "Bundle ID: $BUNDLE_ID"

# 3) Install & launch on every booted simulator
SIMS=$(xcrun simctl list devices booted | grep -oE '[A-F0-9-]{36}')
if [[ -z "$SIMS" ]]; then
  echo "⚠️ No simulators are currently booted."
  exit 0
fi

for UDID in $SIMS; do
  echo "→ Deploying to simulator $UDID…"
  xcrun simctl install "$UDID" "$APP_PATH"
  xcrun simctl launch  "$UDID" "$BUNDLE_ID" || echo "⚠️ Launch failed on $UDID"
done

echo "✅ Deployed to all booted simulators."
exit
