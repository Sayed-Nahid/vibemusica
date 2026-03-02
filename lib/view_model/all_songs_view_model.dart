import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:vibemusica/view_model/splash_view_model.dart';

class AllSongsViewModel extends GetxController {

  final audioQuery = OnAudioQuery();
  var allList = <SongModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Use cached songs from splash if available, otherwise fetch fresh
    if (SplashViewModel.cachedSongs != null &&
        SplashViewModel.cachedSongs!.isNotEmpty) {
      allList.value = SplashViewModel.cachedSongs!;
      SplashViewModel.cachedSongs = null; // free memory
    } else {
      requestPermission();
    }
  }

  void requestPermission() async {
    bool permissionStatus = await audioQuery.permissionsStatus();
    if (!permissionStatus) {
      await audioQuery.permissionsRequest();
    }
    getAllSongs();
  }

  void getAllSongs() async {
    allList.value = await audioQuery.querySongs(
      ignoreCase: true,
      orderType: OrderType.ASC_OR_SMALLER,
      sortType: null,
      uriType: UriType.EXTERNAL,
    );
  }
}