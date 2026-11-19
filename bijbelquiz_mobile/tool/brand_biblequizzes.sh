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
ENTITLEMENTS=ios/Runner/Runner.entitlements
if [[ "${1:-}" == "--restore" ]]; then
  git checkout -- "$PBX" "$PLIST" "$ENTITLEMENTS"
  echo "iOS project back to BijbelQuiz."
  exit 0
fi
sed -i.bak 's/PRODUCT_BUNDLE_IDENTIFIER = com\.bijbelquiz\.app;/PRODUCT_BUNDLE_IDENTIFIER = com.biblequizzes.app;/g' "$PBX"
sed -i.bak 's#<string>Bijbelquiz</string>#<string>Bible Quizzes</string>#g' "$PLIST"
# Universal links belong to this brand's own domain; left pointing at
# bijbelquiz.com they would simply never match a Bible Quizzes invite link.
sed -i.bak 's#<string>applinks:www\.bijbelquiz\.com</string>#<string>applinks:biblequizzes.app</string>#; s#<string>applinks:bijbelquiz\.com</string>#<string>applinks:www.biblequizzes.app</string>#' "$ENTITLEMENTS"
rm -f "$PBX.bak" "$PLIST.bak" "$ENTITLEMENTS.bak"
echo "iOS project switched to Bible Quizzes (com.biblequizzes.app)."
