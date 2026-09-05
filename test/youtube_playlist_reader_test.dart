import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibemusica/common/youtube_playlist_reader.dart';

void main() {
  Map<String, dynamic> row(String id, {bool playable = true}) => {
    'playlistVideoRenderer': {
      'videoId': id,
      'title': {
        'runs': [
          {'text': 'Song { "title" }'},
        ],
      },
      'shortBylineText': {
        'runs': [
          {'text': 'Artist'},
        ],
      },
      'isPlayable': playable,
    },
  };
  test('reads current YouTube lockup layout and ignores playlist cards', () {
    final video = {
      'lockupViewModel': {
        'contentId': 'lvTqbM5Dq4Q',
        'contentType': 'LOCKUP_CONTENT_TYPE_VIDEO',
        'metadata': {
          'lockupMetadataViewModel': {
            'title': {'content': 'How Quantum Computers Break Encryption'},
            'metadata': {
              'contentMetadataViewModel': {
                'metadataRows': [
                  {
                    'metadataParts': [
                      {
                        'text': {'content': 'minutephysics'},
                      },
                    ],
                  },
                ],
              },
            },
          },
        },
      },
    };
    final tracks = YoutubePlaylistReader.parseTracks({
      'contents': [
        video,
        {
          'lockupViewModel': {
            'contentId': 'abcdefghijk',
            'contentType': 'LOCKUP_CONTENT_TYPE_PLAYLIST',
          },
        },
      ],
    });
    expect(tracks.single.id, 'lvTqbM5Dq4Q');
    expect(tracks.single.artist, 'minutephysics');
  });
  test('retains tracks without channel IDs in nested layouts', () {
    final data = {
      'contents': {
        'newLayout': [row('abcdefghijk'), row('lmnopqrstuv')],
      },
    };
    final tracks = YoutubePlaylistReader.parseTracks(data);
    expect(tracks.map((t) => t.id), ['abcdefghijk', 'lmnopqrstuv']);
    expect(tracks.first.artist, 'Artist');
  });
  test('skips unavailable tracks and duplicate renderers', () {
    final data = {
      'contents': [
        row('abcdefghijk'),
        row('abcdefghijk'),
        row('lmnopqrstuv', playable: false),
      ],
    };
    expect(YoutubePlaylistReader.parseTracks(data).length, 1);
  });
  test('reads JSON with quoted braces and trailing scripts', () {
    final data = {
      'contents': [row('abcdefghijk')],
    };
    expect(
      YoutubePlaylistReader.initialData(
        '<script>var ytInitialData = ${jsonEncode(data)}; other();</script>',
      ),
      data,
    );
  });
  test('finds nested continuation commands', () {
    expect(
      YoutubePlaylistReader.continuation({
        'contents': [
          {
            'continuationItemRenderer': {
              'continuationEndpoint': {
                'commandExecutorCommand': {
                  'commands': [
                    {
                      'continuationCommand': {'token': 'next-page'},
                    },
                  ],
                },
              },
            },
          },
        ],
      }),
      'next-page',
    );
  });
  test('missing data fails instead of claiming the playlist is empty', () {
    expect(
      () => YoutubePlaylistReader.initialData('<html>Sign in</html>'),
      throwsFormatException,
    );
  });
}
