import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../common/color_extension.dart';


class AllSongRow extends StatelessWidget {
  final SongModel sObj;
  final VoidCallback onPressedPlay;
  final VoidCallback onPressed;
  const AllSongRow({
    super.key,
    required this.sObj,
    required this.onPressed,
    required this.onPressedPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [

            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: QueryArtworkWidget(
                    id: sObj.id,
                    type: ArtworkType.AUDIO,
                    nullArtworkWidget: Image.asset(
                      "assets/img/app_logo.png",
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    artworkWidth: 50,
                    artworkHeight: 50,
                    artworkFit: BoxFit.cover,
                  ),
                ),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: TColor.primaryText28),
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: TColor.bg,
                    borderRadius: BorderRadius.circular(7.5),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 15,),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sObj.title,
                    maxLines: 1,
                    style: TextStyle(
                        color: TColor.primaryText60,
                        fontSize: 13,
                        fontWeight: FontWeight.w700
                    ),
                  ),
                  Text(
                    sObj.artist ?? "Unknown Artist",
                    maxLines: 1,
                    style: TextStyle(
                      color: TColor.primaryText28,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
                onPressed: onPressedPlay,
                icon: Image.asset(
                  "assets/img/play_btn.png",
                  width: 25,
                  height: 25,
                ),
            ),


          ],
        ),
        Divider(
          color: Colors.white.withOpacity(0.07),
          indent: 50,
        ),
      ],
    );
  }
}
