import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'database/database_provider.dart';
import 'services/settings_service.dart';

void main() async {
  // Required when doing async work before runApp.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database and settings service before the app starts.
  final db = await openAppDatabase();
  final prefs = await SharedPreferences.getInstance();
  final settingsService = SettingsService(
    const FlutterSecureStorage(),
    prefs,
  );

  // Pre-load settings so settingsProvider never starts in a loading state.
  final initialSettings = await settingsService.load();

  runApp(
    ProviderScope(
      overrides: [
        // Override the placeholder with the real database instance.
        databaseProvider.overrideWithValue(db),
        settingsServiceProvider.overrideWithValue(settingsService),
        settingsProvider.overrideWith(
          (ref) => SettingsNotifier.withInitial(
            settingsService,
            ref,
            initialSettings,
          ),
        ),
      ],
      child: const DoubleEntryApp(),
    ),
  );
}
