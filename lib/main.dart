import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'database/database_provider.dart';

void main() async {
  // Required when doing async work before runApp.
  WidgetsFlutterBinding.ensureInitialized();

  // Open the database before the app starts so databaseProvider is ready.
  final db = await openAppDatabase();

  runApp(
    ProviderScope(
      overrides: [
        // Override the placeholder with the real database instance.
        databaseProvider.overrideWithValue(db),
      ],
      child: const DoubleEntryApp(),
    ),
  );
}
