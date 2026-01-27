#!/bin/sh

# Fail this script if any subcommand fails.
set -e

# The default execution directory of this script is the ci_scripts directory.
cd $CI_PRIMARY_REPOSITORY_PATH # change working directory to the root of your cloned repo.

# Install Flutter using git.
git clone https://github.com/flutter/flutter.git --depth 1 -b stable $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

# Install Flutter artifacts for iOS (--ios), or macOS (--macos) platforms.
flutter precache --ios

# Install Flutter dependencies.
flutter pub get

# Create .env file with required environment variables
cat > .env << EOL
VIDEO_SERVICE_URL=https://video.sprk.so
SPRK_APPVIEW_URL=https://api.sprk.so
MESSAGES_SERVICE_URL=https://chat.sprk.so
SHOWCASES_LICENSE_FLUTTER=$SHOWCASES_LICENSE_FLUTTER
EOL

# Decode Firebase config from base64 environment variable
if [ -n "$GOOGLE_SERVICE_INFO_PLIST_BASE64" ]; then
  echo "Decoding GoogleService-Info.plist..."
  echo "$GOOGLE_SERVICE_INFO_PLIST_BASE64" | base64 -d > ios/Runner/GoogleService-Info.plist
else
  echo "Warning: GOOGLE_SERVICE_INFO_PLIST_BASE64 not set"
fi

# Install CocoaPods using Homebrew.
HOMEBREW_NO_AUTO_UPDATE=1 # disable homebrew's automatic updates.
brew install cocoapods

# Install CocoaPods dependencies.
cd ios && pod install # run `pod install` in the `ios` directory.

flutter doctor

exit 0
