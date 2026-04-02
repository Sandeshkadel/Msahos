# MeshLink Offline 3-Device Physical Test Checklist

This script validates real-world offline behavior with internet disabled on all devices.

## Devices
- Device A: Sender
- Device B: Relay node
- Device C: Receiver (out of direct range from A)

## Preconditions
- Install same app build on all devices.
- Turn off mobile data and WiFi internet on all devices.
- Keep Bluetooth and local wireless discovery permissions enabled.
- Set profile name and avatar on each device.

## Test 1: Nearby Discovery
1. Open app on A, B, C.
2. Verify each device appears in Find Users list with profile image.
3. Confirm user search can find each profile by name.
Expected: all users visible and searchable.

## Test 2: Direct Message Delivery
1. Place A near B; C near B; keep A and C apart.
2. On A, select C from chat receiver dropdown.
3. Send text message from A to C.
Expected: status reaches RELAYED then DELIVERED.
Expected: route includes at least one hop through B.

## Test 3: Voice Message Delivery
1. On A, keep C selected.
2. Send voice message from mic button.
3. Verify voice entry appears on A and arrives on C.
Expected: voice message marked DELIVERED.

## Test 4: Chain Break Recovery
1. Start message from A to C via B.
2. Temporarily disable B discovery connectivity.
3. Re-enable B after 30-60 seconds.
Expected: pending message retries and eventually delivers.

## Test 5: Profile Update Visibility
1. Change profile name/avatar/bio on B.
2. Refresh Find Users on A and C.
Expected: updated profile details visible on other devices.

## Test 6: File Transfer Through Relay
1. From A send file to C while A and C are not directly adjacent.
2. Keep B between devices.
Expected: transfer progresses and completes through relay path.

## Pass Criteria
- All six tests pass without internet.
- No crashes.
- Search, profile cards, text, and voice messaging are functional.
