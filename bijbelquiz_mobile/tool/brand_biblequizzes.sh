#!/usr/bin/env bash
# Switch the iOS project to Bible Quizzes before a build (bundle id + name), or
# back with `--restore`. Android needs nothing: build.gradle.kts reads the
# APP_BRAND dart-define. Always build Bible Quizzes with:
#
#   tool/brand_biblequizzes.sh
#   flutter build ipa --dart-define=APP_BRAND=biblequizzes   (or appbundle)
#   tool/brand_biblequizzes.sh --restore
#
# The bundle id com.biblequizzes.app must exist in the Apple developer account
# (and the app in App Store Connect) before the first upload.
set -euo pipefail
cd "$(dirname "$0")/.."
PBX=ios/Runner.xcodeproj/project.pbxproj
PLIST=ios/Runner/Info.plist
if [[ "${1:-}" == "--restore" ]]; then
  git checkout -- "$PBX" "$PLIST"
  echo "iOS project back to BijbelQuiz."
  exit 0
fi
sed -i.bak 's/PRODUCT_BUNDLE_IDENTIFIER = com\.bijbelquiz\.app;/PRODUCT_BUNDLE_IDENTIFIER = com.biblequizzes.app;/g' "$PBX"
sed -i.bak 's#<string>Bijbelquiz</string>#<string>Bible Quizzes</string>#g' "$PLIST"
rm -f "$PBX.bak" "$PLIST.bak"
echo "iOS project switched to Bible Quizzes (com.biblequizzes.app)."
