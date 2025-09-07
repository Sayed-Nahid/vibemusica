import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:vibemusica/common_widget/all_song_row.dart';
import 'package:vibemusica/common_widget/my_playlist_cell.dart';
import 'package:vibemusica/common_widget/view_all_section.dart';
import 'package:vibemusica/view_model/playlists_view_model.dart';

class PlaylistsView extends StatefulWidget {
  const PlaylistsView({super.key});

  @override
  State<PlaylistsView> createState() => _PlaylistsViewState();
}

class _PlaylistsViewState extends State<PlaylistsView> {

  final plVM = Get.put(PlaylistsViewModel());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ViewAllSection(title: "My Playlists", onPressed: (){}),
            SizedBox(
              height: 150,
              child: Obx( () => ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: plVM.myPlaylistArr.length,
                itemBuilder: (context, index) {
                  var pObj = plVM.myPlaylistArr[index];
                  return MyPlaylistCell(
                      pObj: pObj,
                      onPressed: () {}
                  );
                },
              )),
            ),
          ],
        ),
      ),
    );
  }
}
