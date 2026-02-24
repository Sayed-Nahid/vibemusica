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
  // Index of the currently playing song
  int currentIndex = 0;

  @override
  void onInit() {
    super.onInit();
    
    // Listen to player state changes
    audioPlayer.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
      if (state.processingState == ProcessingState.completed) {
        nextSong();
      }
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

  void playSong(SongModel song, int index) {
    currentIndex = index;
    currentSongTitle.value = song.title;
    currentSongArtist.value = song.artist ?? "Unknown Artist";
    currentSongId.value = song.id;
    
    try {
      audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(song.uri!),
          tag: MediaItem(
            id: song.id.toString(),
            album: song.album ?? "Unknown Album",
            title: song.title,
            artist: song.artist ?? "Unknown Artist",
            artUri: Uri.parse(
              "content://media/external/audio/albumart/${song.albumId}",
            ),
          ),
        ),
      );
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
    if (// Check if there are more songs
        currentIndex < allSongs.length - 1) {
      currentIndex++;
      playSong(allSongs[currentIndex], currentIndex);
    } else {
      // Loop back to the first song if needed, or stop
      // For now, let's stop or loop
      currentIndex = 0;
      playSong(allSongs[currentIndex], currentIndex);
    }
  }

  void previousSong() {
    if (audioPlayer.position.inSeconds > 5) {
      audioPlayer.seek(Duration.zero);
    } else if (currentIndex > 0) {
      currentIndex--;
      playSong(allSongs[currentIndex], currentIndex);
    }
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

