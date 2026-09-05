import 'dart:io';
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibemusica/common/audio_file_downloader.dart';

void main() {
  late Directory directory;
  late HttpServer server;
  late Uri url;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp(
      'vibemusica-download-test-',
    );
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    url = Uri.parse('http://127.0.0.1:${server.port}/audio');
  });
  tearDown(() async {
    await server.close(force: true);
    await directory.delete(recursive: true);
  });

  test('writes multiple ranges atomically and reports completion', () async {
    final bytes = List<int>.generate(
      AudioFileDownloader.chunkBytes + 123,
      (i) => i % 251,
    );
    var requests = 0;
    server.listen((request) async {
      request.response.headers.contentType = ContentType('audio', 'mp4');
      requests++;
      final range = RegExp(
        r'bytes=(\d+)-(\d+)',
      ).firstMatch(request.headers.value('range')!)!;
      final start = int.parse(range[1]!);
      final end = min(int.parse(range[2]!), bytes.length - 1);
      request.response.statusCode = 206;
      request.response.headers.set(
        'content-range',
        'bytes $start-$end/${bytes.length}',
      );
      request.response.add(bytes.sublist(start, end + 1));
      await request.response.close();
    });
    final target = File('${directory.path}/song.m4a');
    var last = 0;
    await AudioFileDownloader().download(
      url: url,
      expectedBytes: bytes.length,
      destination: target,
      cancellation: DownloadCancellation(),
      onProgress: (received, _) {
        last = received;
        expect(target.existsSync(), isFalse);
      },
    );
    expect(await target.readAsBytes(), bytes);
    expect(last, bytes.length);
    expect(requests, 2);
    expect(File('${target.path}.part').existsSync(), isFalse);
  });

  test('refreshes a rejected URL with a bounded retry', () async {
    var refreshes = 0;
    server.listen((r) async {
      if (r.uri.path == '/audio') {
        r.response.statusCode = 403;
      } else {
        r.response.headers.contentType = ContentType('audio', 'mp4');
        r.response.add([1, 2, 3]);
      }
      await r.response.close();
    });
    final target = File('${directory.path}/song.m4a');
    await AudioFileDownloader().download(
      url: url,
      expectedBytes: 3,
      destination: target,
      cancellation: DownloadCancellation(),
      onProgress: (_, _) {},
      refreshUrl: () async {
        refreshes++;
        return url.replace(path: '/fresh');
      },
    );
    expect(await target.readAsBytes(), [1, 2, 3]);
    expect(refreshes, 1);
  });

  test('rejected streams never become downloaded files', () async {
    server.listen((r) async {
      r.response.headers.contentType = ContentType('audio', 'mp4');
      r.response.statusCode = 403;
      await r.response.close();
    });
    final target = File('${directory.path}/song.m4a');
    await expectLater(
      AudioFileDownloader().download(
        url: url,
        expectedBytes: 100,
        destination: target,
        cancellation: DownloadCancellation(),
        onProgress: (_, _) {},
      ),
      throwsA(isA<HttpException>()),
    );
    expect(target.existsSync(), isFalse);
    expect(File('${target.path}.part').existsSync(), isFalse);
  });

  test('truncated body is discarded', () async {
    server.listen((r) async {
      r.response.headers.contentType = ContentType('audio', 'mp4');
      r.response.add([1, 2, 3]);
      await r.response.close();
    });
    final target = File('${directory.path}/song.m4a');
    await expectLater(
      AudioFileDownloader().download(
        url: url,
        expectedBytes: 100,
        destination: target,
        cancellation: DownloadCancellation(),
        onProgress: (_, _) {},
      ),
      throwsFormatException,
    );
    expect(target.existsSync(), isFalse);
    expect(File('${target.path}.part').existsSync(), isFalse);
  });

  test('cancelling an active transfer discards the partial file', () async {
    final cancellation = DownloadCancellation();
    server.listen((r) async {
      r.response.headers.contentType = ContentType('audio', 'mp4');
      r.response.add(List.filled(100, 1));
      await r.response.close();
    });
    final target = File('${directory.path}/song.m4a');
    await expectLater(
      AudioFileDownloader().download(
        url: url,
        expectedBytes: 100,
        destination: target,
        cancellation: cancellation,
        onProgress: (_, _) => cancellation.cancel(),
      ),
      throwsA(isA<DownloadCancelled>()),
    );
    expect(target.existsSync(), isFalse);
    expect(File('${target.path}.part').existsSync(), isFalse);
  });

  test('wrong byte ranges fail instead of corrupting the audio', () async {
    server.listen((r) async {
      r.response.headers.contentType = ContentType('audio', 'mp4');
      r.response.statusCode = 206;
      r.response.headers.set('content-range', 'bytes 1-100/101');
      r.response.add(List.filled(100, 1));
      await r.response.close();
    });
    final target = File('${directory.path}/song.m4a');
    await expectLater(
      AudioFileDownloader().download(
        url: url,
        expectedBytes: 100,
        destination: target,
        cancellation: DownloadCancellation(),
        onProgress: (_, _) {},
      ),
      throwsFormatException,
    );
    expect(target.existsSync(), isFalse);
  });
}
