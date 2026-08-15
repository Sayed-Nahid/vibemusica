import 'package:shared_preferences/shared_preferences.dart';

/// Persists a list of recently-played song IDs using SharedPreferences.
/// The list is stored newest-first and capped at [_maxHistory] entries.
class RecentlyPlayedService {
  static const String _key = 'recently_played_ids';
  static const int _maxHistory = 20;

  /// Records a song ID at the front of the recently-played list.
  /// Duplicates are moved to the front instead of being added again.
  static Future<void> addSong(int songId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> ids = prefs.getStringList(_key) ?? [];

    // Remove duplicate if it already exists
    ids.remove(songId.toString());

    // Insert at the beginning (most recent first)
    ids.insert(0, songId.toString());

    // Cap the list
    if (ids.length > _maxHistory) {
      ids.removeRange(_maxHistory, ids.length);
    }

    await prefs.setStringList(_key, ids);
  }

  /// Returns up to [limit] recently-played song IDs, newest first.
  static Future<List<int>> getRecentIds({int limit = 20}) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> ids = prefs.getStringList(_key) ?? [];

    return ids
        .take(limit)
        .map((id) => int.tryParse(id))
        .where((id) => id != null)
        .cast<int>()
        .toList();
  }

  /// Clears the entire recently-played history.
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
