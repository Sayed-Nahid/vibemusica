import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibemusica/common/youtube_download_service.dart';
import 'package:vibemusica/view_model/youtube_playlists_view_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('playlist tracks open from cached metadata without network', () async {
    SharedPreferences.setMockInitialValues({
      'youtube_tracks_v1_PLoffline': jsonEncode([
        {'id': 'abcdefghijk', 'title': 'Offline song', 'artist': 'Artist'},
      ]),
    });
    final vm = YoutubePlaylistsViewModel()..onInit();
    final tracks = await vm.tracks('PLoffline');
    expect(tracks.single.title, 'Offline song');
    expect(tracks.single.localPath, isNull);
  });
  test('saved playlists restore and removal persists', () async {
    SharedPreferences.setMockInitialValues({
      'youtube_playlists_v1': [
        jsonEncode({'id': 'PLexample', 'title': 'My music'}),
      ],
    });
    final vm = YoutubePlaylistsViewModel()..onInit();
    await vm.ready;
    expect(vm.playlists.single['title'], 'My music');
    await vm.remove(vm.playlists.single);
    final restored = YoutubePlaylistsViewModel()..onInit();
    await restored.ready;
    expect(restored.playlists, isEmpty);
  });
  test('invalid and non-YouTube URLs do not change saved playlists', () async {
    SharedPreferences.setMockInitialValues({});
    final vm = YoutubePlaylistsViewModel()..onInit();
    for (final url in [
      'bad input',
      'https://example.com/?list=PLexample',
      'https://youtube.com/watch?v=example',
    ]) {
      expect(await vm.add(url), isFalse);
      expect(vm.error.value, isNotEmpty);
      expect(vm.busy.value, isFalse);
      expect(vm.playlists, isEmpty);
    }
  });
  test('corrupt saved data produces a recoverable error', () async {
    SharedPreferences.setMockInitialValues({
      'youtube_playlists_v1': ['invalid json'],
    });
    final vm = YoutubePlaylistsViewModel()..onInit();
    await vm.ready;
    expect(vm.error.value, isNotEmpty);
    expect(vm.playlists, isEmpty);
  });

  test('deletePlaylistAndAllSongs deletes playlist, cache, and downloaded audio files', () async {
    final tempDir = await Directory.systemTemp.createTemp('yt_delete_test_');
    final audioDir = Directory('${tempDir.path}/youtube_audio');
    await audioDir.create(recursive: true);
    final songFile = File('${audioDir.path}/abcdefghijk.m4a');
    await songFile.writeAsBytes([1, 2, 3, 4, 5]);
    expect(await songFile.exists(), isTrue);

    SharedPreferences.setMockInitialValues({
      'youtube_playlists_v1': [
        jsonEncode({'id': 'PLoffline', 'title': 'Offline list'}),
      ],
      'youtube_tracks_v1_PLoffline': jsonEncode([
        {'id': 'abcdefghijk', 'title': 'Song 1', 'artist': 'Artist'},
      ]),
    });

    final downloadService = Get.put(
      YoutubeDownloadService(directoryProvider: () async => tempDir),
    );
    await downloadService.ready;
    expect(downloadService.files['abcdefghijk'], isNotNull);

    final vm = YoutubePlaylistsViewModel()..onInit();
    await vm.ready;
    expect(vm.playlists.length, 1);

    await vm.deletePlaylistAndAllSongs(vm.playlists.single);

    expect(vm.playlists, isEmpty);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('youtube_tracks_v1_PLoffline'), isNull);
    expect(await songFile.exists(), isFalse);
    expect(downloadService.files['abcdefghijk'], isNull);

    Get.delete<YoutubeDownloadService>();
    await tempDir.delete(recursive: true);
  });
}
