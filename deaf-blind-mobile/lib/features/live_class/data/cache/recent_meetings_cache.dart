import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/meeting.dart';

/// Local cache for recent meetings (offline / fallback).
class RecentMeetingsCache {
  RecentMeetingsCache([this._prefs]);

  SharedPreferences? _prefs;
  static const _key = 'recent_meetings_v1';

  Future<SharedPreferences> get _storage async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<List<Meeting>> load() async {
    final prefs = await _storage;
    final raw = prefs.getStringList(_key) ?? [];
    return raw
        .map((s) => Meeting.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<void> save(List<Meeting> meetings) async {
    final prefs = await _storage;
    await prefs.setStringList(
      _key,
      meetings.map((m) => jsonEncode(m.toJson())).toList(),
    );
  }

  Future<void> remember(Meeting meeting) async {
    final existing = await load();
    final updated = [
      meeting,
      ...existing.where((m) => m.id != meeting.id),
    ].take(10).toList();
    await save(updated);
  }
}
