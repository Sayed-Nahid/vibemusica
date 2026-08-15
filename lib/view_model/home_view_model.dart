import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:vibemusica/common/recently_played_service.dart';

class HomeViewModel extends GetxController{

  final txtSearch = TextEditingController().obs;

  final hostRecommendedArr = [
    {
      "image": "assets/img/img_1.png",
      "name": "Sound of Sky",
      "artists": "Dilon Bruce",
    },
    {
      "image": "assets/img/img_2.png",
      "name": "Girl on Fire",
      "artists": "Alecia Keys"
    }
  ].obs;

  final playListArr = [
    {
      "image": "assets/img/img_3.png",
      "name": "Classic Playlist",
      "artists": "Piano Guys"
    },
    {
      "image": "assets/img/img_4.png",
      "name": "Summer Playlist",
      "artists": "Dilon Bruce"
    },
    {
      "image": "assets/img/img_5.png",
      "name": "Pop Music",
      "artists": "Michael Jackson"
    },
  ];

  /// Recently played songs (real SongModel objects from the device).
  final recentlyPlayedSongs = <SongModel>[].obs;

  /// Whether recently played data is still loading.
  final isLoadingRecent = true.obs;

  final _audioQuery = OnAudioQuery();

  @override
  void onInit() {
    super.onInit();
    loadRecentlyPlayed();
  }

  /// Loads the last [limit] recently-played songs from SharedPreferences,
  /// then resolves their IDs against the device's audio library.
  Future<void> loadRecentlyPlayed({int limit = 5}) async {
    isLoadingRecent.value = true;
    try {
      final ids = await RecentlyPlayedService.getRecentIds(limit: limit);
      if (ids.isEmpty) {
        recentlyPlayedSongs.clear();
        return;
      }

      // Query all songs from the device
      final allSongs = await _audioQuery.querySongs(
        ignoreCase: true,
        orderType: OrderType.ASC_OR_SMALLER,
        sortType: null,
        uriType: UriType.EXTERNAL,
      );

      // Build a lookup map for fast resolution
      final songMap = <int, SongModel>{};
      for (final song in allSongs) {
        songMap[song.id] = song;
      }

      // Resolve IDs in order, skipping any that no longer exist on the device
      final resolved = <SongModel>[];
      for (final id in ids) {
        final song = songMap[id];
        if (song != null) {
          resolved.add(song);
        }
      }

      recentlyPlayedSongs.value = resolved;
    } catch (e) {
      // Silently fail — the section will just appear empty
      recentlyPlayedSongs.clear();
    } finally {
      isLoadingRecent.value = false;
    }
  }
}