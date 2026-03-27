import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';

class MainPlayerViewModel extends GetxController {
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
    audioPlayer.currentIndexStream.listen((index) {
      if (index != null && index >= 0 && index < allSongs.length) {
        currentIndex = index;
        final song = allSongs[index];
        currentSongTitle.value = song.title;
        currentSongArtist.value = song.artist ?? "Unknown Artist";
        currentSongId.value = song.id;
      }
    });

    // Listen to player state changes
    audioPlayer.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
    });

    // Listen to position changes
    audioPlayer.positionStream.listen((p) {
      position.value = p;
    });

    // Listen to duration changes
    audioPlayer.durationStream.listen((d) {
      if (d != null) {
        duration.value = d;
      }
    });
  }

  void playSong(SongModel song, int index) async {
    currentIndex = index;
    currentSongTitle.value = song.title;
    currentSongArtist.value = song.artist ?? "Unknown Artist";
    currentSongId.value = song.id;
    
    try {
      bool isSamePlaylist = playlist != null &&
          currentPlaylist.length == allSongs.length &&
          (allSongs.isNotEmpty && currentPlaylist.isNotEmpty && currentPlaylist.first.id == allSongs.first.id);

      if (!isSamePlaylist) {
        currentPlaylist = List.from(allSongs);
        playlist = ConcatenatingAudioSource(
          children: allSongs.map((s) => AudioSource.uri(
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
          )).toList(),
        );
        await audioPlayer.setAudioSource(playlist!, initialIndex: index, initialPosition: Duration.zero);
      } else {
        await audioPlayer.seek(Duration.zero, index: index);
      }
      
      audioPlayer.play();
      isPlaying.value = true;
    } catch (e) {
      print("Error loading audio source: $e");
    }
  }

  void pauseSong() {
    audioPlayer.pause();
  }

  void resumeSong() {
    audioPlayer.play();
  }

  void nextSong() {
    if (audioPlayer.hasNext) {
      audioPlayer.seekToNext();
    } else {
      audioPlayer.seek(Duration.zero, index: 0);
    }
  }

  void previousSong() {
    audioPlayer.seekToPrevious();
  }
  
  void seekTo(Duration position) {
    audioPlayer.seek(position);
  }

  @override
  void onClose() {
    audioPlayer.dispose();
    super.onClose();
  }
}

