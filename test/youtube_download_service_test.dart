import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibemusica/common/youtube_download_service.dart';
import 'package:vibemusica/model/youtube_track.dart';

void main() {
  late Directory root;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('vibemusica-offline-test-');
  });
  tearDown(() async {
    await root.delete(recursive: true);
  });
  test(
    'playlist continues after a failure and retries only missing tracks',
    () async {
      const tracks = [
        YoutubeTrack(id: 'abcdefghijk', title: 'First', artist: 'Artist'),
        YoutubeTrack(id: 'lmnopqrstuv', title: 'Second', artist: 'Artist'),
        YoutubeTrack(id: '01234567890', title: 'Third', artist: 'Artist'),
      ];
      final attempts = <String>[];
      var failSecond = true;
      final service = YoutubeDownloadService(
        directoryProvider: () async => root,
        trackDownloader: (track, directory, cancellation) async {
          attempts.add(track.id);
          if (failSecond && track.id == tracks[1].id) {
            throw const HttpException('HTTP 403');
          }
          final file = await File(
            '${directory.path}/${track.id}.m4a',
          ).writeAsBytes([1, 2, 3]);
          return file.path;
        },
      )..onInit();
      await service.downloadAll(tracks);
      expect(attempts, tracks.map((t) => t.id).toList());
      expect(service.files.length, 2);
      expect(service.errors.keys, [tracks[1].id]);
      expect(service.finished.value, 3);
      expect(service.busy.value, isFalse);
      failSecond = false;
      attempts.clear();
      await service.downloadAll(tracks);
      expect(attempts, [tracks[1].id]);
      expect(service.files.length, 3);
      expect(service.errors, isEmpty);
      expect(
        (await service.downloaded(tracks)).map((t) => t.id),
        tracks.map((t) => t.id),
      );
      service.onClose();
    },
  );
  test(
    'restores completed files, removes interrupted files, preserves playlist order',
    () async {
      final audio = await Directory('${root.path}/youtube_audio').create();
      await File('${audio.path}/abcdefghijk.m4a').writeAsBytes([1, 2, 3]);
      await File('${audio.path}/lmnopqrstuv.webm').writeAsBytes([4, 5]);
      final partial = await File(
        '${audio.path}/incomplete.m4a.part',
      ).writeAsBytes([1]);
      final service = YoutubeDownloadService(
        directoryProvider: () async => root,
      )..onInit();
      await service.ready;
      final saved = await service.downloaded([
        const YoutubeTrack(
          id: 'lmnopqrstuv',
          title: 'Second',
          artist: 'Artist',
        ),
        const YoutubeTrack(id: 'abcdefghijk', title: 'First', artist: 'Artist'),
        const YoutubeTrack(
          id: 'missing0000',
          title: 'Missing',
          artist: 'Artist',
        ),
      ]);
      expect(saved.map((t) => t.title), ['Second', 'First']);
      expect(saved.every((t) => File(t.localPath!).existsSync()), isTrue);
      expect(await partial.exists(), isFalse);
      await service.remove('abcdefghijk');
      expect(await File('${audio.path}/abcdefghijk.m4a').exists(), isFalse);
      expect(service.files.containsKey('abcdefghijk'), isFalse);
      service.onClose();
    },
  );
  test('missing files are removed from availability before playback', () async {
    final audio = await Directory('${root.path}/youtube_audio').create();
    final file = await File('${audio.path}/abcdefghijk.m4a').writeAsBytes([1]);
    final service = YoutubeDownloadService(directoryProvider: () async => root)
      ..onInit();
    await service.ready;
    await file.delete();
    expect(
      await service.downloaded([
        const YoutubeTrack(id: 'abcdefghijk', title: 'Song', artist: 'Artist'),
      ]),
      isEmpty,
    );
    expect(service.files, isEmpty);
    service.onClose();
  });
}
