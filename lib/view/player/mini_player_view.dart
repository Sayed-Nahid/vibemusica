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
      child: Container(
        height: 60,
        width: media.width,
        decoration: BoxDecoration(color: const Color(0xff22283A), boxShadow: const [
          BoxShadow(
              color: Colors.black26, blurRadius: 4, offset: Offset(0, -2))
        ]),
        child: Row(
          children: [
            Obx(
              () => Container(
                width: 60,
                height: 60,
                padding: const EdgeInsets.all(5),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
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
            const SizedBox(
              width: 10,
            ),
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
                        color: TColor.primaryText.withOpacity(0.5),
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
                  playerVM.isPlaying.value ? Icons.pause : Icons.play_arrow,
                  color: TColor.primaryText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
