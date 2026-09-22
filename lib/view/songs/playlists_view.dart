import '../../view_model/youtube_playlists_view_model.dart';
import 'youtube_playlist_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibemusica/common_widget/folder_cell.dart';
import 'package:vibemusica/common_widget/my_playlist_cell.dart';
import 'package:vibemusica/common_widget/playlist_songs_cell.dart';
import 'package:vibemusica/common_widget/view_all_section.dart';
import 'package:vibemusica/view/songs/folder_songs_view.dart';
import 'package:vibemusica/view_model/folders_view_model.dart';
import 'package:vibemusica/view_model/playlists_view_model.dart';

import '../../common/color_extension.dart';

class PlaylistsView extends StatefulWidget {
  const PlaylistsView({super.key});

  @override
  State<PlaylistsView> createState() => _PlaylistsViewState();
}

class _PlaylistsViewState extends State<PlaylistsView> {
  final youtubeVM = Get.put(YoutubePlaylistsViewModel());
  final plVM = Get.put(PlaylistsViewModel());
  final foldersVM = Get.put(FoldersViewModel());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: TColor.glassFill,
        onPressed: () => showYoutubePlaylistImport(context, youtubeVM),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Image.asset("assets/img/add.png"),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ViewAllSection(
              title: 'YouTube Playlists',
              onPressed: () => showYoutubePlaylistImport(context, youtubeVM),
            ),
            Obx(
              () => youtubeVM.playlists.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Tap + to add a YouTube playlist.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : Column(
                      children: youtubeVM.playlists
                          .map(
                            (p) => ListTile(
                              leading: const Icon(
                                Icons.playlist_play,
                                color: Colors.white,
                              ),
                              title: Text(
                                p['title']!,
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: const Text(
                                'YouTube',
                                style: TextStyle(color: Colors.white54),
                              ),
                              onTap: () => Get.to(
                                () => YoutubePlaylistView(playlist: p),
                              ),
                              trailing: IconButton(
                                tooltip: 'Delete playlist',
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.white70,
                                ),
                                onPressed: () => confirmDeleteYoutubePlaylist(
                                  context: context,
                                  playlist: p,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),

            Obx(
              () => GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.4,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemCount: plVM.playlistArr.length,
                itemBuilder: (context, index) {
                  var pObj = plVM.playlistArr[index];
                  return PlaylistSongsCell(
                    pObj: pObj,
                    onPressed: () {},
                    onPressedPlay: () {},
                  );
                },
              ),
            ),
            ViewAllSection(title: "My Playlists", onPressed: () {}),
            SizedBox(
              height: 150,
              child: Obx(
                () => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: plVM.myPlaylistArr.length,
                  itemBuilder: (context, index) {
                    var pObj = plVM.myPlaylistArr[index];
                    return MyPlaylistCell(pObj: pObj, onPressed: () {});
                  },
                ),
              ),
            ),

            // ── Folders Section ──
            ViewAllSection(title: "Folders", onPressed: () {}),
            Obx(() {
              if (foldersVM.isLoading.value) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: TColor.focus,
                      strokeWidth: 2,
                    ),
                  ),
                );
              }

              if (foldersVM.folders.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 20,
                  ),
                  child: Center(
                    child: Text(
                      "No folders found",
                      style: TextStyle(
                        color: TColor.primaryText35,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }

              return ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: foldersVM.folders.length,
                itemBuilder: (context, index) {
                  final folder = foldersVM.folders[index];
                  return FolderCell(
                    folder: folder,
                    index: index,
                    onPressed: () {
                      Get.to(() => FolderSongsView(folder: folder));
                    },
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
