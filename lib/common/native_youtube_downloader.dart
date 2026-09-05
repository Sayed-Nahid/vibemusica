import 'dart:async';
import 'package:flutter/services.dart';
import 'audio_file_downloader.dart';

class NativeYoutubeDownloader {
  static const channel = MethodChannel('vibemusica/youtube_downloads');

  Future<String> download(
    String id,
    DownloadCancellation cancellation,
    void Function(double) onProgress,
  ) async {
    cancellation.check();
    channel.setMethodCallHandler((call) async {
      if (call.method == 'progress' &&
          call.arguments['videoId'] == id &&
          !cancellation.cancelled) {
        onProgress((call.arguments['progress'] as num).toDouble());
      }
    });
    cancellation.abort = () {
      unawaited(channel.invokeMethod<void>('cancel').catchError((Object _) {}));
    };
    try {
      final path = await channel.invokeMethod<String>('download', {
        'videoId': id,
      });
      if (path == null) {
        throw PlatformException(
          code: 'NO_FILE',
          message: 'No audio file was saved.',
        );
      }
      onProgress(1);
      return path;
    } on PlatformException catch (error) {
      if (error.code == 'CANCELLED' || cancellation.cancelled) {
        throw DownloadCancelled();
      }
      rethrow;
    } finally {
      cancellation.abort = null;
      channel.setMethodCallHandler(null);
    }
  }
}
