import 'dart:developer' as developer;

import 'package:firebase_crashlytics/firebase_crashlytics.dart'; // TODO: Add firebase_crashlytics to pubspec.yaml

class AppLogger {
  static void log(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(message, error: error, stackTrace: stackTrace);
    // TODO: Integrate with Firebase Crashlytics for production logging
    // FirebaseCrashlytics.instance.recordError(error, stackTrace, reason: message);
  }

  static void error(String message, Object error, StackTrace stackTrace) {
    developer.log(message, error: error, stackTrace: stackTrace, name: 'ERROR');
    // TODO: Integrate with Firebase Crashlytics for error reporting
    // FirebaseCrashlytics.instance.recordError(error, stackTrace, reason: message, fatal: true);
  }
}


