# SportConnect - AI Coding Agent Instructions

## Project Overview
**SportConnect** is a production-ready Flutter social carpooling app for students and sports enthusiasts. Built with MVVM architecture using Riverpod code generation, Firebase backend, and battle-tested packages.

## Architecture Quick Reference

### Core Structure
```
lib/
├── core/               # Shared infrastructure
│   ├── config/        # Router, app config, Stripe setup
│   ├── services/      # Firebase, Stripe, Talker logging
│   ├── repositories/  # Core data access
│   ├── providers/     # Riverpod providers
│   ├── theme/         # App theming
│   └── widgets/       # Reusable components
├── features/          # Feature modules (auth, rides, messaging, etc.)
│   └── [feature]/
│       ├── models/       # Freezed data models
│       ├── repositories/ # Feature data access (implements interfaces)
│       ├── view_models/  # Riverpod ViewModels (@riverpod)
│       └── views/        # UI screens
└── l10n/              # Localization (en, fr, es, de)
```

### State Management Pattern
- **Riverpod with code generation** (NOT StateNotifier or ChangeNotifier)
- Use `@riverpod` annotation for all providers (auto-generates `.g.dart` files)
- Example:
  ```dart
  @riverpod
  class RideViewModel extends _$RideViewModel {
    Future<void> build() async { ... }
  }
  ```

### Data Models Pattern
- **Freezed** for all models (generates `.freezed.dart` and `.g.dart`)
- Use sealed classes for union types (e.g., `UserModel.rider` vs `UserModel.driver`)
- Example from [lib/features/auth/models/user_model.dart](lib/features/auth/models/user_model.dart):
  ```dart
  @Freezed(unionKey: 'role')
  sealed class UserModel with _$UserModel {
    @FreezedUnionValue('rider')
    const factory UserModel.rider({ ... }) = RiderUser;
    
    @FreezedUnionValue('driver')
    const factory UserModel.driver({ ... }) = DriverUser;
  }
  ```

### Repository Pattern
- All repositories implement interfaces from `lib/core/interfaces/repositories/`
- Repositories are provided via Riverpod: `@riverpod RideRepository rideRepository(Ref ref) => ...`
- Use Firebase collections via `FirebaseService.firestore`

## Critical Developer Workflows

### Code Generation (Run After Model/Provider Changes)
```bash
# Full rebuild (clean + generate)
dart run build_runner build --delete-conflicting-outputs

# Watch mode for development
dart run build_runner watch --delete-conflicting-outputs
```

### Firebase Emulators (Local Development)
1. Toggle in [lib/core/config/app_config.dart](lib/core/config/app_config.dart): `environmentMode = EnvironmentMode.emulator`
2. Start emulators: `firebase emulators:start`
3. Emulator ports (from [firebase.json](firebase.json)):
   - Firestore: 8080
   - Auth: 9099
   - Storage: 9199
   - Functions: 5001

### Localization Updates
```bash
# Generate l10n after editing .arb files
flutter gen-l10n
```

### Icon/Splash Updates
```bash
# After modifying assets/icons/ or assets/images/
flutter pub run flutter_launcher_icons
flutter pub run flutter_native_splash:create
```

### Running the App
```bash
# With DevicePreview (debug mode only)
flutter run

# Release build
flutter run --release
```

## Project-Specific Conventions

### Navigation (GoRouter)
- All routes defined in [lib/core/config/app_routes.dart](lib/core/config/app_routes.dart)
- Use `AppRoutes.routeName.go(context)` or `.push(context)`
- StatefulShellRoute used for bottom navigation (home, rides, profile)
- Central redirect logic in `app_router.dart` handles auth state

### Logging (Talker)
- **Never use `print()`** - always use [TalkerService](lib/core/services/talker_service.dart)
- Methods: `TalkerService.info()`, `.error()`, `.warning()`, `.debug()`
- Automatically integrates with Riverpod and Dio for request/state logging

### Firebase Collections
- Constants in [lib/core/constants/app_constants.dart](lib/core/constants/app_constants.dart)
- Key collections: `users`, `rides`, `rideRequests`, `messages`, `reviews`, `payments`
- Real-time updates via `.snapshots()` streams, not one-time reads

### Stripe Payments
- Configuration: [lib/core/config/stripe_config.dart](lib/core/config/stripe_config.dart)
- Use `StripeService()` singleton for payment operations
- Firebase Cloud Functions handle backend payment processing (see [functions/](functions/))

### Code Quality (DCM)
- **Strict metrics enforced** (see [analysis_options.yaml](analysis_options.yaml)):
  - Max cyclomatic complexity: 10
  - Max function length: 100 lines
  - Max parameters: 5
  - Max widget nesting: 5
- Run analysis: `flutter analyze` or `dcm analyze lib/`

### Testing
- Uses `mockito` for mocking (NOT mocktail)
- Test structure mirrors `lib/` (see [test/](test/))
- Run: `flutter test`

## Integration Points & External Services

### Firebase Services
- **Auth**: Email/password, Google Sign-In, Apple Sign-In
- **Firestore**: Real-time ride matching, user profiles, messaging
- **Storage**: Profile photos, vehicle documents
- **Cloud Functions**: Stripe payment processing, FCM notifications

### Third-Party SDKs
- **flutter_webrtc**: Voice/video calling (see [lib/features/messaging/views/](lib/features/messaging/views/))
- **flutter_map**: OpenStreetMap-based mapping (NOT Google Maps - no API key needed!)
- **flutter_stripe**: Payment UI (requires publishableKey in StripeConfig)
- **Shorebird**: OTA updates (app_id in [shorebird.yaml](shorebird.yaml))

### Environment Variables (.env)
- **NEVER commit `.env`** to Git (use `.env.example` as template)
- Managed via `envied` package (see [ENVIED_SETUP_GUIDE.md](ENVIED_SETUP_GUIDE.md))
- Required vars: `STRIPE_PUBLISHABLE_KEY`, `SENTRY_DSN` (when added)

## Package Management Strategy

### Priority Packages to Add (See [EXECUTIVE_SUMMARY.md](EXECUTIVE_SUMMARY.md))
1. **sentry_flutter**: Production crash reporting (critical for release)
2. **flutter_local_notifications**: Foreground notifications
3. **app_links**: Deep link verification
4. **local_auth**: Biometric authentication

### Current Excellent Stack (Don't Replace)
- riverpod ^3.1.0 (state management)
- go_router ^17.0.1 (navigation)
- firebase_* ^4-6.x (backend)
- flutter_webrtc ^1.3.0 (video calls)
- freezed ^3.1.0 (code generation)
- flutter_map ^8.2.2 (maps - open source, no API key)

## Common Gotchas

1. **Freezed union types**: Always use `@FreezedUnionValue()` with unionKey for role-based models
2. **Riverpod generators**: Must run `build_runner` after creating providers - `.g.dart` files are required
3. **Firebase emulator Android**: Use `10.0.2.2` (not `localhost`) for Android emulator host
4. **Route params**: Extract via `GoRouterState.pathParameters['id']`, not query params
5. **Timestamp serialization**: Use custom `@TimestampConverter()` for Firestore timestamps
6. **Widget rebuilds**: Use `ref.watch()` for reactive updates, `ref.read()` for one-time reads only

## Documentation References

- **Implementation Guides**: [QUICK_IMPLEMENTATION_GUIDE.md](QUICK_IMPLEMENTATION_GUIDE.md), [SENTRY_SETUP_GUIDE.md](SENTRY_SETUP_GUIDE.md)
- **Architecture Diagram**: [diagram.md](diagram.md) (Mermaid class diagrams for all models)
- **Package Analysis**: [BATTLE_TESTED_PRODUCTION_PACKAGES.md](BATTLE_TESTED_PRODUCTION_PACKAGES.md)
- **Full Docs Index**: [DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md)

---

**When in doubt**: Check existing patterns in `lib/features/rides/` (most complete feature) or `lib/features/auth/` (complex models). This codebase prioritizes consistency and battle-tested packages over experimental approaches.
