import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../model/youtube_track.dart';
import 'audio_file_downloader.dart';
import 'native_youtube_downloader.dart';

typedef TrackDownloader =
    Future<String> Function(
      YoutubeTrack track,
      Directory directory,
      DownloadCancellation cancellation,
    );

class YoutubeDownloadService extends GetxService {
  YoutubeDownloadService({
    Future<Directory> Function()? directoryProvider,
    TrackDownloader? trackDownloader,
  }) : _directoryProvider = directoryProvider ?? getApplicationSupportDirectory,
       _trackDownloader = trackDownloader;
  final Future<Directory> Function() _directoryProvider;
  final TrackDownloader? _trackDownloader;
  final files = <String, String>{}.obs;
  final errors = <String, String>{}.obs;
  final busy = false.obs;
  final activeId = ''.obs;
  final progress = 0.0.obs;
  final finished = 0.obs;
  final total = 0.obs;
  final summary = ''.obs;
  late final Future<void> ready;
  late Directory _directory;
  DownloadCancellation? _cancellation;
  YoutubeExplode? _extractor;

  @override
  void onInit() {
    super.onInit();
    ready = _restore();
  }

  Future<void> _restore() async {
    _directory = Directory(
      '${(await _directoryProvider()).path}/youtube_audio',
    );
    await _directory.create(recursive: true);
    await for (final entry in _directory.list()) {
      if (entry is Directory &&
          RegExp(
            r'^[a-zA-Z0-9_-]{11}\.pending$',
          ).hasMatch(entry.uri.pathSegments.where((s) => s.isNotEmpty).last)) {
        await entry.delete(recursive: true);
        continue;
      }
      if (entry is! File) continue;
      final name = entry.uri.pathSegments.last;
      final match = RegExp(
        r'^([a-zA-Z0-9_-]{11})\.(m4a|webm)$',
      ).firstMatch(name);
      if (match != null && await entry.length() > 0) {
        files[match[1]!] = entry.path;
      }
      if (name.endsWith('.part')) await entry.delete();
    }
  }

  Future<List<YoutubeTrack>> downloaded(List<YoutubeTrack> tracks) async {
    await ready;
    final result = <YoutubeTrack>[];
    for (final track in tracks) {
      final path = files[track.id];
      if (path == null) continue;
      if (!await File(path).exists()) {
        files.remove(track.id);
        continue;
      }
      result.add(track.withLocalPath(path));
    }
    return result;
  }

  Future<void> downloadAll(List<YoutubeTrack> tracks) async {
    if (busy.value) return;
    busy.value = true;
    summary.value = '';
    total.value = 0;
    finished.value = 0;
    final cancellation = DownloadCancellation();
    _cancellation = cancellation;
    var failures = 0;
    try {
      await ready;
      final existing = (await downloaded(tracks)).map((t) => t.id).toSet();
      final queue = <String, YoutubeTrack>{
        for (final t in tracks)
          if (!existing.contains(t.id)) t.id: t,
      }.values.toList();
      total.value = queue.length;
      finished.value = 0;
      for (final track in queue) {
        cancellation.check();
        activeId.value = track.id;
        progress.value = 0;
        errors.remove(track.id);
        try {
          final path =
              await (_trackDownloader?.call(track, _directory, cancellation) ??
                  _downloadTrack(track, cancellation));
          final file = File(path);
          if (!await file.exists() || await file.length() == 0) {
            throw const FileSystemException('Downloaded file is missing');
          }
          files[track.id] = path;
        } on DownloadCancelled {
          rethrow;
        } catch (e) {
          failures++;
          errors[track.id] = _message(e);
        }
        finished.value++;
      }
      summary.value = failures == 0
          ? 'All tracks saved for offline playback.'
          : '$failures tracks could not be downloaded. Tap Download missing to retry.';
    } on DownloadCancelled {
      summary.value = 'Download cancelled. Completed tracks are saved.';
    } catch (e) {
      summary.value = _message(e);
    } finally {
      busy.value = false;
      activeId.value = '';
      _cancellation = null;
    }
  }

  Future<String> _downloadTrack(
    YoutubeTrack track,
    DownloadCancellation cancellation,
  ) async {
    if (!RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(track.id)) {
      throw const FormatException('Invalid video ID');
    }
    if (Platform.isAndroid) {
      try {
        return await NativeYoutubeDownloader().download(
          track.id,
          cancellation,
          (value) => progress.value = value,
        );
      } on DownloadCancelled {
        rethrow;
      } catch (_) {
        cancellation.check();
      }
    }
    final yt = YoutubeExplode();
    _extractor = yt;
    try {
      final manifest = await yt.videos.streams
          .getManifest(track.id)
          .timeout(const Duration(seconds: 30));
      cancellation.check();
      final streams = manifest.audioOnly
          .where(
            (s) =>
                s.fragments.isEmpty &&
                (s.container == StreamContainer.mp4 ||
                    s.container == StreamContainer.webM),
          )
          .toList();
      streams.sort((a, b) {
        final aMp4 = a.container == StreamContainer.mp4;
        final bMp4 = b.container == StreamContainer.mp4;
        if (aMp4 != bMp4) return aMp4 ? -1 : 1;
        return b.bitrate.bitsPerSecond.compareTo(a.bitrate.bitsPerSecond);
      });
      Object? failure;
      for (final stream in streams) {
        cancellation.check();
        final ext = stream.container == StreamContainer.mp4 ? 'm4a' : 'webm';
        final file = File('${_directory.path}/${track.id}.$ext');
        try {
          await AudioFileDownloader().download(
            url: stream.url,
            expectedBytes: stream.size.totalBytes,
            destination: file,
            cancellation: cancellation,
            userAgent: YoutubeHttpClient.defaultHeaders['user-agent'],
            refreshUrl: () async {
              cancellation.check();
              final fresh = await yt.videos.streams
                  .getManifest(track.id)
                  .timeout(const Duration(seconds: 30));
              cancellation.check();
              return fresh.audioOnly
                  .firstWhere(
                    (s) =>
                        s.tag == stream.tag &&
                        s.size.totalBytes == stream.size.totalBytes,
                  )
                  .url;
            },
            onProgress: (received, size) => progress.value = received / size,
          );
          return file.path;
        } on DownloadCancelled {
          rethrow;
        } on FileSystemException {
          rethrow;
        } catch (e) {
          failure = e;
        }
      }
      throw failure ?? StateError('YouTube provided no downloadable audio');
    } catch (_) {
      cancellation.check();
      rethrow;
    } finally {
      yt.close();
      _extractor = null;
    }
  }

  String _message(Object error) {
    if (error is PlatformException) {
      return error.message ?? 'Audio download failed. Try again.';
    }
    if (error is FileSystemException) {
      return 'Could not save audio. Check free storage space.';
    }
    if (error is TimeoutException || error is SocketException) {
      return 'Connection failed or timed out. Try again.';
    }
    if (error.toString().contains('403')) {
      return 'YouTube rejected this audio download.';
    }
    return 'Could not download this track. It may be unavailable through YouTube.';
  }

  void cancel() {
    _cancellation?.cancel();
    _extractor?.close();
  }

  Future<void> remove(String id, {bool force = false}) async {
    if (busy.value && !force) return;
    try {
      await ready;
      final path = files[id];
      if (path != null && await File(path).exists()) await File(path).delete();
      for (final ext in ['m4a', 'webm', 'm4a.part', 'webm.part']) {
        final f = File('${_directory.path}/$id.$ext');
        if (await f.exists()) await f.delete();
      }
      files.remove(id);
      errors.remove(id);
    } catch (e) {
      errors[id] = _message(e);
    }
  }

  Future<void> removeMultiple(Iterable<String> ids, {bool force = false}) async {
    await ready;
    for (final id in ids) {
      await remove(id, force: force);
    }
  }

  @override
  void onClose() {
    cancel();
    super.onClose();
  }
}
