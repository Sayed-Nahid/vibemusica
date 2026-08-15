import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:vibemusica/view_model/splash_view_model.dart';

class FolderModel {
  final String folderPath;
  final String folderName;
  final int songCount;
  final List<SongModel> songs;

  FolderModel({
    required this.folderPath,
    required this.folderName,
    required this.songCount,
    required this.songs,
  });
}

class FoldersViewModel extends GetxController {
  final _audioQuery = OnAudioQuery();
  var folders = <FolderModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadFolders();
  }

  void loadFolders() async {
    isLoading.value = true;
    try {
      List<SongModel> songs;
      if (SplashViewModel.cachedSongs != null && SplashViewModel.cachedSongs!.isNotEmpty) {
        songs = SplashViewModel.cachedSongs!;
      } else {
        songs = await _audioQuery.querySongs(
          sortType: null,
          orderType: OrderType.ASC_OR_SMALLER,
          uriType: UriType.EXTERNAL,
          ignoreCase: true,
        );
      }

      Map<String, List<SongModel>> folderMap = {};

      for (var song in songs) {
        int lastSlashIndex = song.data.lastIndexOf('/');
        if (lastSlashIndex != -1) {
          String folderPath = song.data.substring(0, lastSlashIndex);
          
          if (!folderMap.containsKey(folderPath)) {
            folderMap[folderPath] = [];
          }
          folderMap[folderPath]!.add(song);
        }
      }

      List<FolderModel> tempFolders = [];
      folderMap.forEach((path, folderSongs) {
        int lastSlashIndex = path.lastIndexOf('/');
        String folderName = lastSlashIndex != -1 ? path.substring(lastSlashIndex + 1) : path;
        
        tempFolders.add(FolderModel(
          folderPath: path,
          folderName: folderName,
          songCount: folderSongs.length,
          songs: folderSongs,
        ));
      });

      tempFolders.sort((a, b) => a.folderName.toLowerCase().compareTo(b.folderName.toLowerCase()));
      folders.value = tempFolders;
    } catch (e) {
      print("Error loading folders: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
