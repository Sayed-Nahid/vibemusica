import '../common/youtube_download_service.dart';
import '../common/youtube_playlist_reader.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../model/youtube_track.dart';
import 'main_player_view_model.dart';

class YoutubePlaylistsViewModel extends GetxController {
  static const _key = 'youtube_playlists_v1';
  final playlists = <Map<String, String>>[].obs;
  final busy = false.obs;
  final error = ''.obs;
  late final Future<void> ready;

  @override
  void onInit() {
    super.onInit();
    ready = _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(_key) ?? [];
      playlists.assignAll(
        saved.map((s) => Map<String, String>.from(jsonDecode(s) as Map)),
      );
    } catch (_) {
      error.value = 'Could not load saved YouTube playlists.';
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setStringList(_key, playlists.map(jsonEncode).toList())) {
      throw StateError('Could not save playlists');
    }
  }

  Future<bool> add(String input) async {
    if (busy.value) return false;
    busy.value = true;
    error.value = '';
    final yt = YoutubeExplode();
    try {
      await ready;
      final uri = Uri.tryParse(input.trim());
      if (uri == null ||
          ![
            'youtube.com',
            'www.youtube.com',
            'music.youtube.com',
            'm.youtube.com',
            'youtu.be',
          ].contains(uri.host) ||
          uri.queryParameters['list'] == null) {
        throw const FormatException(
          'Paste a YouTube playlist link containing list=.',
        );
      }
      final playlist = await yt.playlists
          .get(uri.queryParameters['list']!)
          .timeout(const Duration(seconds: 30));
      if (playlists.any((p) => p['id'] == playlist.id.value)) return true;
      final entry = {'id': playlist.id.value, 'title': playlist.title};
      playlists.add(entry);
      try {
        await _save();
      } catch (_) {
        playlists.remove(entry);
        rethrow;
      }
      return true;
    } on FormatException catch (e) {
      error.value = e.message;
      return false;
    } catch (_) {
      error.value =
          'Could not import playlist. Check your connection and use a public or unlisted playlist.';
      return false;
    } finally {
      yt.close();
      busy.value = false;
    }
  }

  Future<void> remove(Map<String, String> entry) async {
    await ready;
    final index = playlists.indexOf(entry);
    if (index < 0) return;
    playlists.removeAt(index);
    try {
      await _save();
    } catch (_) {
      playlists.insert(index, entry);
      error.value = 'Could not remove playlist. Try again.';
    }
  }

  Future<void> deletePlaylistAndAllSongs(Map<String, String> entry) async {
    await ready;
    final playlistId = entry['id'];
    if (playlistId != null) {
      final prefs = await SharedPreferences.getInstance();
      final key = 'youtube_tracks_v1_$playlistId';
      final cached = prefs.getString(key);
      final trackIds = <String>[];
      if (cached != null) {
        try {
          final saved = (jsonDecode(cached) as List)
              .map(
                (t) =>
                    YoutubeTrack.fromJson(Map<String, dynamic>.from(t as Map)),
              )
              .toList();
          trackIds.addAll(saved.map((t) => t.id));
        } catch (_) {}
      }

      if (Get.isRegistered<YoutubeDownloadService>()) {
        final downloadService = Get.find<YoutubeDownloadService>();
        if (downloadService.busy.value) {
          downloadService.cancel();
        }
        if (Get.isRegistered<MainPlayerViewModel>()) {
          final player = Get.find<MainPlayerViewModel>();
          for (final trackId in trackIds) {
            await player.releaseDownloadedTrack(trackId);
          }
        }
        await downloadService.removeMultiple(trackIds, force: true);
      }

      await prefs.remove(key);
    }

    await remove(entry);
  }

  Future<List<YoutubeTrack>> tracks(String id, {bool refresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'youtube_tracks_v1_$id';
    if (!refresh) {
      final cached = prefs.getString(key);
      if (cached != null) {
        try {
          final saved = (jsonDecode(cached) as List)
              .map(
                (t) =>
                    YoutubeTrack.fromJson(Map<String, dynamic>.from(t as Map)),
              )
              .toList();
          if (saved.isNotEmpty) return saved;
        } catch (_) {
          /* Refresh malformed metadata. */
        }
      }
    }
    final result = await _fetchTracks(id);
    await prefs.setString(
      key,
      jsonEncode(result.map((t) => t.toJson()).toList()),
    );
    return result;
  }

  Future<List<YoutubeTrack>> _fetchTracks(String id) async {
    final yt = YoutubeExplode();
    try {
      final videos = await yt.playlists
          .getVideos(id)
          .timeout(const Duration(seconds: 30))
          .toList();
      if (videos.isEmpty) {
        final fallback = await YoutubePlaylistReader().load(id);
        if (fallback.isEmpty) throw const YoutubePlaylistLoadException();
        return fallback;
      }
      return videos
          .map(
            (v) =>
                YoutubeTrack(id: v.id.value, title: v.title, artist: v.author),
          )
          .toList();
    } finally {
      yt.close();
    }
  }
}
