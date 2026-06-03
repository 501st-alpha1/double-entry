import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'database.dart';

/// Opens the SQLite database file from the app's documents directory.
/// Works on Android and all desktop platforms without GMS.
Future<AppDatabase> openAppDatabase() async {
  final appDir = await getApplicationDocumentsDirectory();
  final dbPath = p.join(appDir.path, 'double_entry.db');
  final dbFile = File(dbPath);
  return AppDatabase(NativeDatabase(dbFile));
}

/// Global provider for the database instance.
/// Initialized before runApp via ProviderContainer — see main.dart.
final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError(
    'databaseProvider must be overridden before use. '
    'See main.dart for initialization.',
  );
});
