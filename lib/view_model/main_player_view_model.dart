import 'dart:async';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../model/youtube_track.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:vibemusica/common/recently_played_service.dart';
import 'package:vibemusica/view_model/home_view_model.dart';

class MainPlayerViewModel extends GetxController {
  final youtubeArtwork = ''.obs;
  final isLoading = false.obs;
  final playbackError = ''.obs;
  List<YoutubeTrack> _youtubeQueue = [];
  bool _youtubeMode = false;
  int _request = 0;
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  Future<void> playYoutube(List<YoutubeTrack> tracks, int index) async {
    if (index < 0 || index >= tracks.length) return;
    final request = ++_request;
    _youtubeMode = true;
    _youtubeQueue = List.of(tracks);
    currentIndex = index;
    playlist = null;
    currentPlaylist = [];
    final track = tracks[index];
    currentSongTitle.value = track.title;
    currentSongArtist.value = track.artist;
    currentSongId.value = 0;
    youtubeArtwork.value = track.artwork;
    playbackError.value = '';
    isLoading.value = true;
    position.value = Duration.zero;
    duration.value = Duration.zero;
    final yt = YoutubeExplode();
    try {
      await audioPlayer.stop();
      if (request != _request) return;
      await audioPlayer.setLoopMode(LoopMode.off);
      final manifest = await yt.videos.streamsClient
          .getManifest(track.id)
          .timeout(const Duration(seconds: 30));
      if (request != _request) return;
      final streams = manifest.audioOnly.toList()
        ..sort(
          (a, b) => b.bitrate.bitsPerSecond.compareTo(a.bitrate.bitsPerSecond),
        );
      if (streams.isEmpty) throw StateError('No audio stream');
      final stream = streams.firstWhere(
        (s) => s.container == StreamContainer.mp4,
        orElse: () => streams.first,
      );
      await audioPlayer.setAudioSource(
        AudioSource.uri(
          stream.url,
          tag: MediaItem(
            id: 'youtube:${track.id}',
            title: track.title,
            artist: track.artist,
            artUri: Uri.parse(track.artwork),
          ),
        ),
      );
      if (request != _request) return;
      isLoading.value = false;
      unawaited(
        audioPlayer.play().catchError((Object e) {
          if (request == _request) _playbackFailed();
        }),
      );
    } catch (_) {
      if (request == _request) _playbackFailed();
    } finally {
      yt.close();
      if (request == _request) isLoading.value = false;
    }
  }

  void _playbackFailed() {
    playbackError.value =
        'Unable to stream this track. Tap play to retry or choose another track.';
    isPlaying.value = false;
  }

  final AudioPlayer audioPlayer = AudioPlayer();
  var isPlaying = false.obs;
  var currentSongTitle = "".obs;
  var currentSongArtist = "".obs;
  var currentSongId = 0.obs;
  var duration = Duration.zero.obs;
  var position = Duration.zero.obs;

  // List of all songs passed from the previous screen
  List<SongModel> allSongs = [];
  // Current playlist state to sync with AudioSource
  List<SongModel> currentPlaylist = [];
  ConcatenatingAudioSource? playlist;

  // Index of the currently playing song
  int currentIndex = 0;

  @override
  void onInit() {
    super.onInit();

    // Natively loop the playlist
    audioPlayer.setLoopMode(LoopMode.all);

    // Keep UI synced with the native player's index
    // This allows next/prev buttons on lock screen to update the UI
    _subscriptions.add(
      audioPlayer.currentIndexStream.listen((index) {
        if (_youtubeMode) return;
        if (index != null && index >= 0 && index < currentPlaylist.length) {
          currentIndex = index;
          final song = currentPlaylist[index];
          currentSongTitle.value = song.title;
          currentSongArtist.value = song.artist ?? "Unknown Artist";
          currentSongId.value = song.id;

          // Record and instantly refresh the home screen list
          _recordRecentlyPlayed(song.id);
        }
      }),
    );

    // Listen to player state changes
    _subscriptions.add(
      audioPlayer.playerStateStream.listen((state) {
        isPlaying.value = state.playing;
        if (_youtubeMode &&
            !isLoading.value &&
            state.processingState == ProcessingState.completed) {
          nextSong();
        }
      }),
    );

    // Listen to position changes
    _subscriptions.add(
      audioPlayer.positionStream.listen((p) {
        position.value = p;
      }),
    );

    // Listen to duration changes
    _subscriptions.add(
      audioPlayer.durationStream.listen((d) {
        if (d != null) {
          duration.value = d;
        }
      }),
    );
  }

  void playSong(SongModel song, int index) async {
    final request = ++_request;
    _youtubeMode = false;
    isLoading.value = false;
    playbackError.value = '';
    youtubeArtwork.value = '';
    currentIndex = index;
    currentSongTitle.value = song.title;
    currentSongArtist.value = song.artist ?? "Unknown Artist";
    currentSongId.value = song.id;

    // Persist and instantly refresh the home screen list
    _recordRecentlyPlayed(song.id);

    try {
      await audioPlayer.setLoopMode(LoopMode.all);
      if (request != _request) return;
      bool isSamePlaylist =
          playlist != null &&
          currentPlaylist.length == allSongs.length &&
          (allSongs.isNotEmpty &&
              List.generate(
                allSongs.length,
                (i) => currentPlaylist[i].id == allSongs[i].id,
              ).every((same) => same));

      if (!isSamePlaylist) {
        currentPlaylist = List.from(allSongs);
        playlist = ConcatenatingAudioSource(
          children: allSongs
              .map(
                (s) => AudioSource.uri(
                  Uri.parse(s.uri!),
                  tag: MediaItem(
                    id: s.id.toString(),
                    album: s.album ?? "Unknown Album",
                    title: s.title,
                    artist: s.artist ?? "Unknown Artist",
                    artUri: Uri.parse(
                      "content://media/external/audio/albumart/${s.albumId}",
                    ),
                  ),
                ),
              )
              .toList(),
        );
        await audioPlayer.setAudioSource(
          playlist!,
          initialIndex: index,
          initialPosition: Duration.zero,
        );
      } else {
        await audioPlayer.seek(Duration.zero, index: index);
      }

      if (request != _request) return;
      unawaited(
        audioPlayer.play().catchError((Object e) {
          if (request == _request) _playbackFailed();
        }),
      );
    } catch (_) {
      if (request == _request) _playbackFailed();
    }
  }

  void pauseSong() {
    if (isLoading.value) {
      ++_request;
      isLoading.value = false;
    }
    audioPlayer.pause();
  }

  void resumeSong() {
    if (_youtubeMode &&
        (playbackError.value.isNotEmpty ||
            audioPlayer.processingState == ProcessingState.idle)) {
      playYoutube(_youtubeQueue, currentIndex);
      return;
    }
    if (isLoading.value) return;
    unawaited(
      audioPlayer.play().catchError((Object e) {
        _playbackFailed();
      }),
    );
  }

  void nextSong() {
    if (_youtubeMode) {
      if (_youtubeQueue.isNotEmpty) {
        playYoutube(_youtubeQueue, (currentIndex + 1) % _youtubeQueue.length);
      }
      return;
    }
    if (audioPlayer.hasNext) {
      audioPlayer.seekToNext();
    } else {
      audioPlayer.seek(Duration.zero, index: 0);
    }
  }

  void previousSong() {
    if (_youtubeMode) {
      if (_youtubeQueue.isNotEmpty) {
        playYoutube(_youtubeQueue, (currentIndex - 1) % _youtubeQueue.length);
      }
      return;
    }
    audioPlayer.seekToPrevious();
  }

  void seekTo(Duration position) {
    audioPlayer.seek(position);
  }

  /// Persists the song ID to history and immediately refreshes HomeViewModel.
  void _recordRecentlyPlayed(int songId) async {
    await RecentlyPlayedService.addSong(songId);
    try {
      Get.find<HomeViewModel>().loadRecentlyPlayed();
    } catch (_) {
      // HomeViewModel may not be registered yet (e.g. first launch)
    }
  }

  @override
  void onClose() {
    ++_request;
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    audioPlayer.dispose();
    super.onClose();
  }
}
