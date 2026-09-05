import 'dart:async';
import 'dart:io';
import 'dart:math';

class DownloadCancelled implements Exception {}

class DownloadCancellation {
  bool cancelled = false;
  void Function()? abort;
  void cancel() {
    cancelled = true;
    abort?.call();
  }

  void check() {
    if (cancelled) throw DownloadCancelled();
  }
}

/// Downloads bounded ranges to a temporary file. Only a complete, validated
/// response becomes playable; interrupted or rejected responses are discarded.
class AudioFileDownloader {
  static const chunkBytes = 64 * 1024;
  Future<void> download({
    required Uri url,
    required int expectedBytes,
    required File destination,
    required DownloadCancellation cancellation,
    required void Function(int received, int total) onProgress,
    String? userAgent,
    Future<Uri> Function()? refreshUrl,
  }) async {
    if (expectedBytes <= 0) throw const FormatException('Unknown audio size');
    cancellation.check();
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 20);
    if (userAgent != null) client.userAgent = userAgent;
    cancellation.abort = () => client.close(force: true);
    final partial = File('${destination.path}.part');
    RandomAccessFile? output;
    try {
      await destination.parent.create(recursive: true);
      output = await partial.open(mode: FileMode.write);
      var received = 0;
      var currentUrl = url;
      var refreshes = 0;
      while (received < expectedBytes) {
        cancellation.check();
        final end = min(received + chunkBytes - 1, expectedBytes - 1);
        final request = await client
            .getUrl(currentUrl)
            .timeout(const Duration(seconds: 20));
        request.headers.set(HttpHeaders.rangeHeader, 'bytes=$received-$end');
        request.headers.set(HttpHeaders.acceptEncodingHeader, 'identity');
        final response = await request.close().timeout(
          const Duration(seconds: 20),
        );
        cancellation.check();
        if (response.statusCode == 403 && refreshUrl != null && refreshes < 2) {
          await response.drain<void>().timeout(const Duration(seconds: 20));
          cancellation.check();
          refreshes++;
          currentUrl = await refreshUrl();
          continue;
        }
        if (response.statusCode != 206 &&
            !(response.statusCode == 200 && received == 0)) {
          throw HttpException(
            'Audio download rejected (HTTP ${response.statusCode})',
          );
        }
        var responseBytes = expectedBytes;
        if (response.statusCode == 206) {
          final range =
              response.headers.value(HttpHeaders.contentRangeHeader) ?? '';
          final match = RegExp(r'^bytes (\d+)-(\d+)/(\d+)$').firstMatch(range);
          if (match == null ||
              int.parse(match[1]!) != received ||
              int.parse(match[2]!) != end ||
              int.parse(match[3]!) != expectedBytes) {
            throw const FormatException('Invalid audio byte range');
          }
          responseBytes = end - received + 1;
        }
        final type = response.headers.contentType?.mimeType ?? '';
        if (type.contains('text') || type.contains('json')) {
          throw const FormatException(
            'Server returned an error instead of audio',
          );
        }
        var count = 0;
        await for (final chunk in response.timeout(
          const Duration(seconds: 20),
        )) {
          cancellation.check();
          count += chunk.length;
          if (count > responseBytes) {
            throw const FormatException('Audio response exceeds expected size');
          }
          await output.writeFrom(chunk);
          received += chunk.length;
          onProgress(received, expectedBytes);
        }
        if (count != responseBytes) {
          throw const FormatException('Incomplete audio download');
        }
      }
      await output.flush();
      await output.close();
      output = null;
      cancellation.check();
      await partial.rename(destination.path);
    } catch (_) {
      if (cancellation.cancelled) throw DownloadCancelled();
      rethrow;
    } finally {
      cancellation.abort = null;
      client.close(force: true);
      await output?.close();
      if (await partial.exists()) await partial.delete();
    }
  }
}
