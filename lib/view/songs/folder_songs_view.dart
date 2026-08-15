import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vibemusica/common/color_extension.dart';
import 'package:vibemusica/common_widget/all_song_row.dart';
import 'package:vibemusica/common_widget/gradient_mesh_background.dart';
import 'package:vibemusica/view/player/main_player_view.dart';
import 'package:vibemusica/view_model/folders_view_model.dart';
import 'package:vibemusica/view_model/main_player_view_model.dart';

class FolderSongsView extends StatelessWidget {
  final FolderModel folder;

  const FolderSongsView({super.key, required this.folder});

  @override
  Widget build(BuildContext context) {
    final playerVM = Get.put(MainPlayerViewModel());

    void playSongs(int index) {
      if (folder.songs.isNotEmpty) {
        playerVM.allSongs = folder.songs;
        playerVM.playSong(folder.songs[index], index);
        Get.to(() => const MainPlayerView());
      }
    }

    return Scaffold(
      backgroundColor: TColor.bg,
      body: Stack(
        children: [
          const GradientMeshBackground(),
          
          SafeArea(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(top: 70, bottom: 20),
              itemCount: folder.songs.length,
              itemBuilder: (context, index) {
                var sObj = folder.songs[index];
                return AllSongRow(
                  sObj: sObj,
                  index: index,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    playSongs(index);
                  },
                  onPressedPlay: () {
                    HapticFeedback.lightImpact();
                    playSongs(index);
                  },
                );
              },
            ),
          ),
          
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    color: TColor.glassFill,
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Get.back();
                          },
                          icon: Icon(Icons.arrow_back_ios_new_rounded, color: TColor.primaryText, size: 20),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: TColor.primaryG,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds),
                                child: Text(
                                  folder.folderName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${folder.songCount} songs',
                                style: TextStyle(
                                  color: TColor.primaryText35,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            if (folder.songs.isNotEmpty) {
                              playSongs(0);
                            }
                          },
                          icon: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: TColor.primaryG,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.play_arrow_rounded, color: TColor.primaryText, size: 20),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
