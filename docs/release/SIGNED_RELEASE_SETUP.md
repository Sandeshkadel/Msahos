# Signed Release Setup (Android)

## Option A: key.properties file
1. Copy `android/key.properties.example` to `android/key.properties`.
2. Place your keystore file at the path set by `storeFile`.
3. Fill store and key passwords.

## Option B: Environment variables
Set these before build:
- ANDROID_KEYSTORE_PATH
- ANDROID_KEYSTORE_PASSWORD
- ANDROID_KEY_ALIAS
- ANDROID_KEY_PASSWORD

## Build commands
- Analyze: `C:\\Users\\acer\\dev\\flutter\\bin\\flutter.bat analyze`
- Test: `C:\\Users\\acer\\dev\\flutter\\bin\\flutter.bat test`
- Release APK: `C:\\Users\\acer\\dev\\flutter\\bin\\flutter.bat build apk --release`

## Output artifact
- `build/app/outputs/flutter-apk/app-release.apk`

If no signing secrets are configured, build falls back to debug signing to keep local testing unblocked.
For store publishing, configure release signing secrets first.
