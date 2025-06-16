import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:family_travel_app/firebase_options.dart';
import 'package:family_travel_app/core/logger.dart';
import 'package:family_travel_app/core/router.dart';
import 'package:family_travel_app/core/offline_write_queue.dart';
import 'package:family_travel_app/core/firestore_service.dart';
import 'package:family_travel_app/features/expense/data/expense_draft.dart';
import 'package:family_travel_app/features/expense/data/expense_sync_service.dart';
import 'package:family_travel_app/features/expense/data/expense_repository.dart';
import 'package:family_travel_app/features/memory/data/pending_memory_draft.dart';
import 'package:family_travel_app/features/memory/data/memory_sync_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // TODO: Add your Firebase App Check debug token here for development
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );

  // Initialize Hive for offline queues
  await Hive.initFlutter();
  Hive.registerAdapter(OfflineOperationAdapter()); // Register your Hive adapters
  Hive.registerAdapter(ExpenseDraftAdapter()); // Register ExpenseDraftAdapter
  Hive.registerAdapter(PendingMemoryDraftAdapter()); // Register PendingMemoryDraftAdapter

  // Initialize Firestore Service
  await FirestoreService().init();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);

    // Initialize ExpenseSyncService
    ref.watch(expenseSyncServiceProvider);
    // Initialize MemorySyncService
    ref.watch(memorySyncServiceProvider);

    return MaterialApp.router(
      title: 'Family Travel App',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue, // TODO: Define your app's color scheme
        brightness: Brightness.light,
      ),
      routerConfig: goRouter,
      navigatorKey: navigatorKey,
    );
  }
}


