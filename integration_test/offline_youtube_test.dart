import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:vibemusica/common/youtube_download_service.dart';
import 'package:vibemusica/view_model/main_player_view_model.dart';
import 'package:vibemusica/view_model/youtube_playlists_view_model.dart';
import 'package:vibemusica/view/songs/youtube_playlist_view.dart';

// Opt-in live test. By default it downloads two tracks into app-private storage
// and leaves completed files available in the app after the test.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const playlistId = String.fromEnvironment('YOUTUBE_TEST_PLAYLIST');
  const trackCount = int.fromEnvironment('YOUTUBE_TEST_TRACKS', defaultValue: 2);
  testWidgets(
    'download, restore, and play an offline playlist on Android',
    (tester) async {
      await JustAudioBackground.init(
        androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
        androidNotificationChannelName: 'Audio playback',
        androidNotificationOngoing: true,
      );
      final playlists = Get.put(YoutubePlaylistsViewModel());
      final downloads = Get.put(YoutubeDownloadService(), permanent: true);
      final player = Get.put(MainPlayerViewModel());
      await tester.pumpWidget(
        GetMaterialApp(
          home: YoutubePlaylistView(
            playlist: const {
              'id': playlistId,
              'title': 'Download verification',
            },
          ),
        ),
      );
      final tracks = (await playlists.tracks(playlistId)).take(trackCount).toList();
      expect(tracks.length, greaterThanOrEqualTo(2));
      await downloads.downloadAll(tracks);
      expect(downloads.errors, isEmpty, reason: downloads.errors.toString());
      final saved = await downloads.downloaded(tracks);
      expect(saved.length, tracks.length, reason: downloads.summary.value);
      for (final track in saved) {
        expect(await File(track.localPath!).length(), greaterThan(1000));
      }
      final restored = YoutubeDownloadService()..onInit();
      await restored.ready;
      expect((await restored.downloaded(tracks)).length, tracks.length);
      await player.playDownloadedYoutube(saved, 0);
      await Future<void>.delayed(const Duration(seconds: 3));
      expect(player.playbackError.value, isEmpty);
      expect(player.position.value.inMilliseconds, greaterThan(0));
      player.nextSong();
      await Future<void>.delayed(const Duration(seconds: 2));
      expect(player.currentSongTitle.value, saved[1].title);
      player.pauseSong();
      restored.onClose();
    },
    skip: playlistId.isEmpty,
    timeout: const Timeout(Duration(minutes: 12)),
  );
}
