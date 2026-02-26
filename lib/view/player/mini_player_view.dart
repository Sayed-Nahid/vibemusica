import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../../common/color_extension.dart';
import '../../view_model/main_player_view_model.dart';
import 'main_player_view.dart';

class MiniPlayerView extends StatefulWidget {
  const MiniPlayerView({super.key});

  @override
  State<MiniPlayerView> createState() => _MiniPlayerViewState();
}

class _MiniPlayerViewState extends State<MiniPlayerView> {
  final playerVM = Get.put(MainPlayerViewModel());

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);
    return GestureDetector(
      onTap: () {
        Get.to(() => const MainPlayerView());
      },
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            height: 64,
            width: media.width,
            decoration: BoxDecoration(
              color: TColor.glassFill,
              border: Border(
                top: BorderSide(
                  color: TColor.glassBorder,
                  width: 0.6,
                ),
              ),
            ),
            child: Row(
              children: [
                Obx(
                  () => Container(
                    width: 60,
                    height: 60,
                    padding: const EdgeInsets.all(5),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: QueryArtworkWidget(
                        id: playerVM.currentSongId.value,
                        type: ArtworkType.AUDIO,
                        artworkWidth: 50,
                        artworkHeight: 50,
                        artworkFit: BoxFit.cover,
                        nullArtworkWidget: Image.asset(
                          "assets/img/app_logo.png",
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(
                        () => Text(
                          playerVM.currentSongTitle.value,
                          maxLines: 1,
                          style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Obx(
                        () => Text(
                          playerVM.currentSongArtist.value,
                          maxLines: 1,
                          style: TextStyle(
                            color: TColor.primaryText35,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Obx(
                  () => IconButton(
                    onPressed: () {
                      if (playerVM.isPlaying.value) {
                        playerVM.pauseSong();
                      } else {
                        playerVM.resumeSong();
                      }
                    },
                    icon: Icon(
                      playerVM.isPlaying.value
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: TColor.primaryText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
