import 'dart:convert';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../model/youtube_track.dart';

/// Compatibility reader for playlist layouts the upstream parser misses.
/// Track identity does not depend on optional channel metadata.
class YoutubePlaylistReader {
  Future<List<YoutubeTrack>> load(String id) async {
    final client = YoutubeHttpClient();
    try {
      final html = await client
          .getString(
            Uri.https('www.youtube.com', '/playlist', {'list': id, 'hl': 'en'}),
          )
          .timeout(const Duration(seconds: 20));
      Map<String, dynamic>? data;
      try {
        data = initialData(html);
      } on FormatException {
        /* Try browse. */
      }
      if (data == null || parseTracks(data).isEmpty) {
        data = await client
            .sendPost('browse', {'browseId': 'VL$id'})
            .timeout(const Duration(seconds: 20));
      }
      final tracks = <String, YoutubeTrack>{};
      final tokens = <String>{};
      for (var page = 0; page < 100; page++) {
        for (final track in parseTracks(data!)) {
          tracks.putIfAbsent(track.id, () => track);
        }
        final token = continuation(data);
        if (token == null) return tracks.values.toList();
        if (!tokens.add(token)) {
          throw const FormatException('Playlist pagination stalled');
        }
        data = await client
            .sendContinuation('browse', token)
            .timeout(const Duration(seconds: 20));
      }
      throw const FormatException('Playlist exceeds page limit');
    } finally {
      client.close();
    }
  }

  static Iterable<Map> _maps(dynamic value) sync* {
    if (value is Map) {
      yield value;
      for (final child in value.values) {
        yield* _maps(child);
      }
    } else if (value is List) {
      for (final child in value) {
        yield* _maps(child);
      }
    }
  }

  static String _text(dynamic value) {
    if (value is! Map) return '';
    if (value['simpleText'] is String) return value['simpleText'] as String;
    final runs = value['runs'];
    return runs is List
        ? runs.whereType<Map>().map((r) => r['text'] ?? '').join()
        : '';
  }

  static List<YoutubeTrack> parseTracks(Map<String, dynamic> data) {
    final result = <String, YoutubeTrack>{};
    final content =
        data['contents'] ??
        data['onResponseReceivedActions'] ??
        data['onResponseReceivedCommands'] ??
        data;
    for (final map in _maps(content)) {
      final lockup = map['lockupViewModel'];
      if (lockup is Map &&
          lockup['contentType'] == 'LOCKUP_CONTENT_TYPE_VIDEO') {
        final id = lockup['contentId'];
        final metadata = lockup['metadata']?['lockupMetadataViewModel'];
        final title = metadata?['title']?['content'];
        if (id is String &&
            RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(id) &&
            title is String &&
            title.isNotEmpty) {
          var artist = 'Unknown artist';
          final rows =
              metadata?['metadata']?['contentMetadataViewModel']?['metadataRows'];
          if (rows is List && rows.isNotEmpty) {
            final parts = rows.first['metadataParts'];
            if (parts is List && parts.isNotEmpty) {
              final text = parts.first['text'];
              if (text is Map && text['content'] is String) {
                artist = text['content'] as String;
              }
            }
          }
          result.putIfAbsent(
            id,
            () => YoutubeTrack(id: id, title: title, artist: artist),
          );
        }
        continue;
      }
      final row =
          map['playlistVideoRenderer'] ?? map['playlistPanelVideoRenderer'];
      if (row is! Map || row['isPlayable'] == false) continue;
      final id = row['videoId'];
      final title = _text(row['title']);
      if (id is! String ||
          !RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(id) ||
          title.isEmpty ||
          title == '[Private video]' ||
          title == '[Deleted video]') {
        continue;
      }
      final author = _text(row['shortBylineText']).isNotEmpty
          ? _text(row['shortBylineText'])
          : _text(row['ownerText']);
      result.putIfAbsent(
        id,
        () => YoutubeTrack(
          id: id,
          title: title,
          artist: author.isEmpty ? 'Unknown artist' : author,
        ),
      );
    }
    return result.values.toList();
  }

  static String? continuation(Map<String, dynamic> data) {
    for (final map in _maps(data)) {
      final marker = map['continuationItemRenderer'];
      if (marker is! Map) continue;
      for (final command in _maps(marker)) {
        final continuation = command['continuationCommand'];
        if (continuation is Map && continuation['token'] is String) {
          return continuation['token'] as String;
        }
      }
    }
    return null;
  }

  static Map<String, dynamic> initialData(String html) {
    final match = RegExp(
      r'''(?:var\s+ytInitialData|window\["ytInitialData"\]|ytInitialData)\s*=\s*''',
    ).firstMatch(html);
    if (match == null) throw const FormatException('Missing playlist data');
    final start = html.indexOf('{', match.end);
    if (start < 0) throw const FormatException('Missing playlist JSON');
    var depth = 0;
    var quoted = false;
    var escaped = false;
    for (var i = start; i < html.length; i++) {
      final char = html[i];
      if (quoted) {
        if (escaped) {
          escaped = false;
        } else if (char == r'\') {
          escaped = true;
        } else if (char == '"') {
          quoted = false;
        }
      } else if (char == '"') {
        quoted = true;
      } else if (char == '{') {
        depth++;
      } else if (char == '}' && --depth == 0) {
        return jsonDecode(html.substring(start, i + 1)) as Map<String, dynamic>;
      }
    }
    throw const FormatException('Incomplete playlist JSON');
  }
}

class YoutubePlaylistLoadException implements Exception {
  const YoutubePlaylistLoadException();
  @override
  String toString() =>
      'YouTube did not return any readable tracks. Check that this playlist opens without signing in, then retry.';
}
