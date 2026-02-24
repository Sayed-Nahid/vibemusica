import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:vibemusica/common_widget/all_song_row.dart';
import 'package:vibemusica/view/player/main_player_view.dart';
import 'package:vibemusica/view_model/main_player_view_model.dart'; // Import Player VM

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
      body: Obx(() => ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: allVM.allList.length,
        itemBuilder: (context, index) {
          var sObj = allVM.allList[index];
          return AllSongRow(
            sObj: sObj,
            onPressed: () {
               playerVM.allSongs = allVM.allList;
               playerVM.playSong(sObj, index);
               Get.to(() => const MainPlayerView());
            },
            onPressedPlay: (){
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
