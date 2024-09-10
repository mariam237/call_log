# Call Duration Tracker

**Call Duration Tracker** is a Flutter-based application that tracks and displays the duration of phone calls in real-time. It uses system-level phone states (incoming, started, ended) and visually represents the duration using a circular progress bar.

---

## Features

- **Real-Time Call Duration**: Tracks call duration from the moment the call is initiated and shows the time in hours, minutes, and seconds.
- **Progress Indicator**: Displays a circular progress bar to visually represent the call time.
- **Call States**: Displays statuses for incoming, ongoing, and ended calls.
- **iOS Production Mode**: Detects production mode on iOS devices using platform channels.
- **Phone Permission Handling**: Requests the necessary phone permissions for both Android and iOS to track calls.

---

## Dependencies

The app uses the following Flutter packages:

- `phone_state`: Monitors phone state to capture call events.
- `permission_handler`: Manages phone-related permissions.
- `flutter/material.dart`: For building the user interface.

Install these dependencies using:
```
flutter pub get
```

---

## Code Overview

- The app tracks different phone states: CALL_INCOMING, CALL_STARTED, and CALL_ENDED using the phone_state package.
- It listens to phone state changes and calculates the duration between the start and end of the call.
- On iOS, the app checks whether it is running in production mode via a method channel.
- Permissions are requested using the permission_handler package.

---

## How to Build and Run
### Android
- Step 1: Configure Android Permissions
Add the necessary phone-related permissions to the AndroidManifest.xml file located at android/app/src/main/AndroidManifest.xml:
```
<uses-permission android:name="android.permission.READ_PHONE_STATE"/>

<uses-permission android:name="android.permission.CALL_PHONE"/>
```
- Step 2: Run on Android Emulator or Device
Ensure your Android device or emulator is connected. In your terminal, run:
flutter run

The app should compile and run on your Android device or emulator. You can simulate call states or test on a real device.

### iOS
- Step 1: Configure iOS Permissions
Add the following permissions to the ios/Runner/Info.plist file:
```
<key>NSContactsUsageDescription</key>
<string>We need access to phone contacts for tracking calls.</string>
<key>NSPhoneUsageDescription</key>
<string>We need access to the phone system to monitor call duration.</string>
```
- Step 2: Run on iOS Simulator or Device
Open the iOS project in Xcode:
```
open ios/Runner.xcworkspace
```
Select a simulator or connected device.
Click the Run button in Xcode or run the following command from your terminal:
flutter run
Ensure that you have an Apple Developer Account configured and are using a physical iPhone to test phone-related functionality.