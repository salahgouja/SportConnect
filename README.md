# sport_connect

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Firebase Emulator Setup

### 1. Start Firebase emulators

Run from the project root:

```bash
firebase emulators:start --only auth,firestore,database,storage,functions
```

### 2. Run app with emulator mode enabled

Use Flutter with a dart define:

```bash
flutter run --dart-define=USE_FIREBASE_EMULATORS=true
```

### 3. Optional host override for physical devices

When running on a real phone, point to your machine LAN IP:

```bash
flutter run --dart-define=USE_FIREBASE_EMULATORS=true --dart-define=FIREBASE_EMULATOR_HOST=192.168.1.10
```

### 4. VS Code launch profiles

Use the launch profiles in [.vscode/launch.json](.vscode/launch.json):

- SportConnect (Production Firebase)
- SportConnect (Firebase Emulators)
