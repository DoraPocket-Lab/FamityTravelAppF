# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Essential Commands

### Setup & Development
```bash
# Initial setup
flutter pub get
flutterfire configure  # Configure Firebase project (run when Firebase config changes)

# Start development with Firebase emulators (recommended)
firebase emulators:start
flutter run

# Code generation (run after model changes)
flutter packages pub run build_runner build
flutter packages pub run build_runner build --delete-conflicting-outputs  # when conflicts occur
```

### Testing & Quality
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/auth_controller_test.dart

# Analyze code
flutter analyze

# Pre-commit workflow
flutter analyze && flutter test && flutter packages pub run build_runner build
```

### Build Commands
```bash
# Development builds
flutter build apk --debug
flutter build ios --debug

# Production builds
flutter build apk --release
flutter build ios --release
flutter build web --release
```

## Architecture Overview

### Technology Stack
- **Flutter 3.0+** with Material 3
- **Firebase**: Auth, Firestore, Storage, Analytics, Crashlytics
- **State Management**: Riverpod (flutter_riverpod + hooks_riverpod)
- **Navigation**: GoRouter with authentication guards
- **Offline Storage**: Hive with code generation
- **Code Generation**: Freezed for immutable models, Hive for adapters

### Current Structure
**Note**: Project currently uses flat file structure in root directory, though `architecture.md` documents a feature-first approach. Consider refactoring to feature-based organization.

Key architectural files:
- `main.dart` - App initialization with Firebase and Hive setup
- `router.dart` - GoRouter configuration with auth guards
- `*_repository.dart` - Repository pattern for data access
- `*_notifier.dart` - Riverpod state management
- `firestore_service.dart` - Central Firebase service with offline queue

### Code Generation Patterns

**Freezed Models** (generates `.freezed.dart` + `.g.dart`):
```dart
@freezed
class ModelName with _$ModelName {
  const factory ModelName({
    required String id,
    // ... fields
  }) = _ModelName;
  
  factory ModelName.fromJson(Map<String, dynamic> json) => _$ModelNameFromJson(json);
}
```

**Hive Models** (generates `.g.dart`):
```dart
@HiveType(typeId: 0)
class ModelName {
  @HiveField(0)
  final String id;
}
```

**Always run code generation after model changes** - the app will not compile without generated files.

### Firebase Integration

**Development Setup**:
- Use `firebase emulators:start` for local development
- Firestore rules enforce family-based access control
- Schema uses family → plans → (expenses|memories) hierarchy

**Offline-First Architecture**:
- `OfflineWriteQueue` handles operations when offline
- All repositories support offline/online mode switching
- Hive provides local storage for drafts and caching

### Testing Structure
- Repository tests use Mockito to mock Firebase services
- Test files follow `*_test.dart` naming convention
- Comprehensive mocking of Firestore, Storage, and Auth services
- Use `flutter test path/to/specific_test.dart` for individual test files

### State Management
- Riverpod providers handle dependency injection
- Separate notifiers for each feature domain (expense, memory, plan, auth)
- Stream-based reactive programming for real-time Firebase updates

## Firebase Configuration
- Run `flutterfire configure` when adding new platforms or changing Firebase project
- Generates `lib/firebase_options.dart` - commit this file
- Local development should use Firebase emulators when possible