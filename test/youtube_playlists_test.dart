import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibemusica/view_model/youtube_playlists_view_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
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
}
