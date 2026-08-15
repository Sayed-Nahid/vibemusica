import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:vibemusica/common/color_extension.dart';
import 'package:vibemusica/common/recently_played_service.dart';
import 'package:vibemusica/common_widget/all_song_row.dart';
import 'package:vibemusica/common_widget/gradient_mesh_background.dart';
import 'package:vibemusica/view/player/main_player_view.dart';
import 'package:vibemusica/view_model/home_view_model.dart';
import 'package:vibemusica/view_model/main_player_view_model.dart';

/// Displays the last 20 songs the user played, in chronological order
/// (most recent first).
class RecentlyPlayedView extends StatefulWidget {
  const RecentlyPlayedView({super.key});

  @override
  State<RecentlyPlayedView> createState() => _RecentlyPlayedViewState();
}

class _RecentlyPlayedViewState extends State<RecentlyPlayedView> {
  final _playerVM = Get.find<MainPlayerViewModel>();
  final _audioQuery = OnAudioQuery();

  final _songs = <SongModel>[].obs;
  final _isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    _loadRecentSongs();
  }

  Future<void> _loadRecentSongs() async {
    _isLoading.value = true;
    try {
      final ids = await RecentlyPlayedService.getRecentIds(limit: 20);
      if (ids.isEmpty) {
        _songs.clear();
        return;
      }

      final allSongs = await _audioQuery.querySongs(
        ignoreCase: true,
        orderType: OrderType.ASC_OR_SMALLER,
        sortType: null,
        uriType: UriType.EXTERNAL,
      );

      final songMap = <int, SongModel>{};
      for (final song in allSongs) {
        songMap[song.id] = song;
      }

      final resolved = <SongModel>[];
      for (final id in ids) {
        final song = songMap[id];
        if (song != null) {
          resolved.add(song);
        }
      }

      _songs.value = resolved;
    } catch (_) {
      _songs.clear();
    } finally {
      _isLoading.value = false;
    }
  }

  void _showClearHistoryDialog() {
    HapticFeedback.lightImpact();
    Get.dialog(
      AlertDialog(
        backgroundColor: TColor.bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: TColor.glassBorder, width: 0.8),
        ),
        title: Text(
          "Clear History",
          style: TextStyle(
            color: TColor.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          "Are you sure you want to clear your recently played history?",
          style: TextStyle(
            color: TColor.primaryText60,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "Cancel",
              style: TextStyle(
                color: TColor.primaryText35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await RecentlyPlayedService.clearHistory();
              _songs.clear();
              // Also refresh the home screen list
              try {
                Get.find<HomeViewModel>().loadRecentlyPlayed();
              } catch (_) {}
            },
            child: Text(
              "Clear",
              style: TextStyle(
                color: TColor.org,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const GradientMeshBackground(),
          Column(
            children: [
              // ── Glass AppBar ──
              SafeArea(
                bottom: false,
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      color: TColor.glassFill,
                      height: kToolbarHeight,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              Get.back();
                            },
                            icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: TColor.primaryText,
                              size: 20,
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: TColor.primaryG,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds),
                                child: Text(
                                  "Recently Played",
                                  style: TextStyle(
                                    fontFamily: "Circular Std",
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: TColor.primaryText,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              )
                                  .animate()
                                  .fadeIn(duration: 300.ms)
                                  .scale(
                                    begin: const Offset(0.95, 0.95),
                                    end: const Offset(1.0, 1.0),
                                    duration: 300.ms,
                                    curve: Curves.easeOutBack,
                                  ),
                            ),
                          ),
                          // Clear history button
                          Obx(() => _songs.isNotEmpty
                              ? IconButton(
                                  onPressed: _showClearHistoryDialog,
                                  tooltip: "Clear History",
                                  icon: Icon(
                                    Icons.delete_outline_rounded,
                                    color: TColor.primaryText60,
                                    size: 22,
                                  ),
                                )
                              : const SizedBox(width: 48),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(
                    begin: -0.05,
                    end: 0,
                    duration: 400.ms,
                    curve: Curves.easeOut,
                  ),

              // ── Song list ──
              Expanded(
                child: Obx(() {
                  if (_isLoading.value) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: TColor.focus,
                        strokeWidth: 2,
                      ),
                    );
                  }

                  if (_songs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.history_rounded,
                            size: 48,
                            color: TColor.primaryText28,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "No recently played songs",
                            style: TextStyle(
                              color: TColor.primaryText35,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    itemCount: _songs.length,
                    itemBuilder: (context, index) {
                      final song = _songs[index];
                      return AllSongRow(
                        sObj: song,
                        index: index,
                        onPressed: () {
                          _playerVM.allSongs = _songs.toList();
                          _playerVM.playSong(song, index);
                          Get.to(() => const MainPlayerView());
                        },
                        onPressedPlay: () {
                          _playerVM.allSongs = _songs.toList();
                          _playerVM.playSong(song, index);
                          Get.to(() => const MainPlayerView());
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
