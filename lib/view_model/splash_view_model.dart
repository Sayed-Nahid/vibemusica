import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:vibemusica/view/main_tabview/main_tabview.dart';

class SplashViewModel extends GetxController {

  var scaffoldKey = GlobalKey<ScaffoldState>();

  /// Cached song list populated during splash — avoids re-querying later
  static List<SongModel>? cachedSongs;

  void loadView() async {
    // Run real initialization concurrently with a minimum display time
    // so the entrance animations (≈1.4 s) always play out fully.
    await Future.wait([
      _initializeApp(),
      Future.delayed(const Duration(milliseconds: 2500)),
    ]);

    // Smooth crossfade out — removes splash from nav stack
    Get.off(
      () => const MainTabView(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 600),
    );
  }

  /// Requests storage permission and pre-queries the audio library.
  Future<void> _initializeApp() async {
    try {
      final audioQuery = OnAudioQuery();

      // Request permission if not already granted
      bool hasPermission = await audioQuery.permissionsStatus();
      if (!hasPermission) {
        hasPermission = await audioQuery.permissionsRequest();
      }

      // Pre-load the song list so the songs view is instant
      if (hasPermission) {
        cachedSongs = await audioQuery.querySongs(
          ignoreCase: true,
          orderType: OrderType.ASC_OR_SMALLER,
          sortType: null,
          uriType: UriType.EXTERNAL,
        );
      }
    } catch (e) {
      // Non-fatal — the songs view will retry on its own
      debugPrint("Splash init error: $e");
    }
  }

  void openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  void closeDrawer() {
    scaffoldKey.currentState?.closeDrawer();
  }
}