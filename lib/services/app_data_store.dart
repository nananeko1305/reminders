import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_data.dart';

/// Low-level persistence of [AppData] as a single JSON blob in
/// [SharedPreferences]. Knows nothing about events or lists; it reads and
/// writes, seeding an empty store on first run and recovering from a corrupt
/// payload. Share one instance so [update] can serialize writers.
class AppDataStore {
  static const String _storageKey = 'reminders_app_data';

  Future<void> _tail = Future.value();

  Future<AppData> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return AppData.empty();
    try {
      return AppData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return AppData.empty();
    }
  }

  /// Read-modify-write, one at a time, so two quick edits (an event and a list
  /// item, say) never overwrite each other. Returns what [mutate] returns.
  Future<T> update<T>(T Function(AppData data) mutate) {
    final result = _tail.then((_) async {
      final data = await read();
      final value = mutate(data);
      await _write(data);
      return value;
    });
    _tail = result.then((_) {}, onError: (_) {});
    return result;
  }

  Future<void> _write(AppData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(data.toJson()));
  }
}
