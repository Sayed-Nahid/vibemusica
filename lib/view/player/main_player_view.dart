import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../../common/color_extension.dart';
import '../../common_widget/playlist_songs_cell.dart';
import '../../view_model/main_player_view_model.dart';

class MainPlayerView extends StatefulWidget {
  const MainPlayerView({super.key});

  @override
  State<MainPlayerView> createState() => _MainPlayerViewState();
}

class _MainPlayerViewState extends State<MainPlayerView> {
  final playerVM = Get.put(MainPlayerViewModel());

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Image.asset(
            "assets/img/back.png",
            width: 25,
            height: 25,
            fit: BoxFit.contain,
          ),
        ),
        title: Text(
          "Now Playing",
          style: TextStyle(
            color: TColor.primaryText80,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: TColor.bg,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Image.asset(
              "assets/img/more_btn.png",
              width: 20,
              height: 20,
              fit: BoxFit.contain,
              color: TColor.primaryText35,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Obx(
              () => Container(
                width: media.width * 0.7,
                height: media.width * 0.7,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(media.width * 0.35),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(media.width * 0.35),
                  child: QueryArtworkWidget(
                    id: playerVM.currentSongId.value,
                    type: ArtworkType.AUDIO,
                    artworkWidth: media.width * 0.7,
                    artworkHeight: media.width * 0.7,
                    artworkFit: BoxFit.cover,
                    nullArtworkWidget: Image.asset(
                      "assets/img/app_logo.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Obx(
              () => Text(
                playerVM.currentSongTitle.value,
                style: TextStyle(
                  color: TColor.primaryText80,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Obx(
              () => Text(
                playerVM.currentSongArtist.value,
                style: TextStyle(
                  color: TColor.primaryText35,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    formatDuration(playerVM.position.value),
                    style: TextStyle(
                      color: TColor.primaryText35,
                      fontSize: 12,
                    ),
                  ),
                   Expanded(
                    child: Slider(
                      value: playerVM.position.value.inSeconds.toDouble() <= playerVM.duration.value.inSeconds.toDouble() 
                          ? playerVM.position.value.inSeconds.toDouble() 
                          : 0.0,
                      max: playerVM.duration.value.inSeconds.toDouble() > 0 
                          ? playerVM.duration.value.inSeconds.toDouble() 
                          : 1.0,
                      onChanged: (value) {
                         playerVM.seekTo(Duration(seconds: value.toInt()));
                      },
                      activeColor: TColor.focus,
                      inactiveColor: TColor.primaryText28,
                    ),
                  ),
                  Text(
                    formatDuration(playerVM.duration.value),
                    style: TextStyle(
                      color: TColor.primaryText35,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                        playerVM.previousSong();
                    },
                    icon: Image.asset(
                      "assets/img/previous_song.png",
                      width: 50,
                      height: 50,
                    ),
                  ),
                  const SizedBox(
                    width: 25,
                  ),
                  IconButton(
                    onPressed: () {
                      if (playerVM.isPlaying.value) {
                        playerVM.pauseSong();
                      } else {
                        playerVM.resumeSong();
                      }
                    },
                    icon: Image.asset(
                      playerVM.isPlaying.value
                          ? "assets/img/pause_btn.png" 
                          : "assets/img/play_btn.png",
                      width: 70,
                      height: 70,
                    ),
                  ),
                  const SizedBox(
                    width: 25,
                  ),
                  IconButton(
                    onPressed: () {
                        playerVM.nextSong();
                    },
                    icon: Image.asset(
                      "assets/img/next_song.png",
                      width: 50,
                      height: 50,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
