import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibemusica/common_widget/all_song_row.dart';
import 'package:vibemusica/view/player/main_player_view.dart';
import 'package:vibemusica/view_model/main_player_view_model.dart';

import '../../view_model/all_songs_view_model.dart';

class AllSongsView extends StatefulWidget {
  const AllSongsView({super.key});

  @override
  State<AllSongsView> createState() => _AllSongsViewState();
}

class _AllSongsViewState extends State<AllSongsView> {
  final allVM = Get.put(AllSongsViewModel());
  final playerVM = Get.put(MainPlayerViewModel());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Obx(() => ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: allVM.allList.length,
        itemBuilder: (context, index) {
          var sObj = allVM.allList[index];
          return AllSongRow(
            sObj: sObj,
            index: index,
            onPressed: () {
              playerVM.allSongs = allVM.allList;
              playerVM.playSong(sObj, index);
              Get.to(() => const MainPlayerView());
            },
            onPressedPlay: () {
              playerVM.allSongs = allVM.allList;
              playerVM.playSong(sObj, index);
              Get.to(() => const MainPlayerView());
            },
          );
        },
      )),
    );
  }
}
