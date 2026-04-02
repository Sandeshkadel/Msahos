# MeshLink

Offline-first mesh communication app baseline built with Flutter and native bridges.

## Implemented in this checkpoint

- Multi-screen app shell: Radar, Chat, Transfer, Map, AI
- Futuristic dark neon design system
- Live state controller for discovery simulation, chat state progression, and transfer progress
- Platform channel bridge: meshlink.connectivity
- Android and iOS native channel responders (ping, startDiscovery)
- Permission baseline for BLE, local network, WiFi state, storage, and location

## 1) Verify your setup first

From VS Code terminal:

PowerShell command using local Flutter SDK:

  C:\Users\acer\dev\flutter\bin\flutter.bat doctor -v

You should have:

- Flutter installed
- Android toolchain ready
- VS Code detected

Current machine status found during implementation:

- Flutter installed locally at C:\Users\acer\dev\flutter
- Android SDK exists
- Android cmdline-tools missing
- Android licenses not accepted yet

Fix Android toolchain before emulator runs:

1. Install Android cmdline-tools via Android Studio SDK Manager.
1. Accept licenses:

	C:\Users\acer\dev\flutter\bin\flutter.bat doctor --android-licenses

## 2) Required VS Code extensions

Install:

- Flutter (Dart Code)
- Dart

## 3) How to preview the app

### Method 1: Android Emulator (best start)

1. Press Ctrl + Shift + P
1. Run command: Flutter: Launch Emulator
1. In terminal:

	cd meshlink
	C:\Users\acer\dev\flutter\bin\flutter.bat pub get
	C:\Users\acer\dev\flutter\bin\flutter.bat run

### Real-time preview loop

- Save files for hot reload in VS Code
- Press r in terminal for hot reload
- Press R for hot restart

## Current architecture

- Flutter UI and state: lib/app, lib/features, lib/core/services
- Native bridge contract: lib/core/platform/connectivity_bridge.dart
- Android method channel: android/app/src/main/kotlin/com/example/meshlink/MainActivity.kt
- iOS method channel: ios/Runner/AppDelegate.swift

## Next implementation targets

1. Real BLE and WiFi Direct discovery on Android
1. Multipeer Connectivity transport on iOS
1. Drift local database with event log, routing table, and pending queue
1. End-to-end encryption handshake and session keys
1. Chunk-based file transfer with resume and checksums
