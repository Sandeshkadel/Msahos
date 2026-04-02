# MeshLink v1.0.0 Release Notes

## Highlights
- Offline-first mesh communication baseline
- User profiles with visible name/avatar across connected users
- Find Users directory with live search and one-tap chat entry
- Text + voice message support
- Chain-route messaging status: CREATED -> SENT -> RELAYED -> DELIVERED
- File relay dashboard and offline map panel

## Tested
- Static analysis: pass
- Unit/widget tests: pass
- APK release build: pass

## Android artifact
- `build/app/outputs/flutter-apk/app-release.apk`

## Notes
This release includes functional application flows and automated tests. Real radio-level validation for BLE/WiFi Direct relay requires multi-device physical field testing using the checklist in `docs/testing/OFFLINE_3_DEVICE_TEST_CHECKLIST.md`.
