import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AllSongsViewModel extends GetxController {

  final audioQuery = OnAudioQuery();
  var allList = <SongModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    requestPermission();
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