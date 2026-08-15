import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:vibemusica/common_widget/all_song_row.dart';
import 'package:vibemusica/common_widget/gradient_mesh_background.dart';
import 'package:vibemusica/common_widget/playlist_cell.dart';
import 'package:vibemusica/common_widget/recommended_cell.dart';
import 'package:vibemusica/view/home/recently_played_view.dart';
import 'package:vibemusica/view/player/main_player_view.dart';
import 'package:vibemusica/view_model/home_view_model.dart';
import 'package:vibemusica/view_model/main_player_view_model.dart';
import 'package:vibemusica/view_model/splash_view_model.dart';

import '../../common/color_extension.dart';
import '../../common_widget/title_section.dart';
import '../../common_widget/view_all_section.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final homeVM = Get.put(HomeViewModel());
  final playerVM = Get.find<MainPlayerViewModel>();
  bool _isSearching = false;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Layer 0 — animated gradient mesh background
          const GradientMeshBackground(),

          // Layer 1 — scrollable content
          CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // ── Glass AppBar ──
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                floating: true,
                snap: true,
                centerTitle: true,
                leading: _isSearching
                    ? IconButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _isSearching = false;
                            homeVM.txtSearch.value.clear();
                          });
                        },
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: TColor.primaryText,
                          size: 20,
                        ),
                      )
                    : IconButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Get.find<SplashViewModel>().openDrawer();
                        },
                        icon: Image.asset(
                          "assets/img/menu.png",
                          width: 25,
                          height: 25,
                          fit: BoxFit.contain,
                        ),
                      ),
                title: _isSearching ? _buildActiveSearchBar() : _buildBrandTitle(),
                actions: [
                  if (!_isSearching)
                    IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _isSearching = true;
                        });
                        _searchFocusNode.requestFocus();
                      },
                      icon: Icon(
                        Icons.search_rounded,
                        color: TColor.primaryText80,
                        size: 24,
                      ),
                    ),
                  if (_isSearching && homeVM.txtSearch.value.text.isNotEmpty)
                    IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          homeVM.txtSearch.value.clear();
                        });
                      },
                      icon: Icon(
                        Icons.close_rounded,
                        color: TColor.primaryText60,
                        size: 20,
                      ),
                    ),
                  const SizedBox(width: 6),
                ],
              ),

              // ── Hot Recommended ──
              const SliverToBoxAdapter(
                child: TitleSection(title: "Hot Recommended"),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 200,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: homeVM.hostRecommendedArr.length,
                    itemBuilder: (context, index) {
                      var mObj = homeVM.hostRecommendedArr[index];
                      return RecommendedCell(mObj: mObj, index: index);
                    },
                  ),
                ),
              ),

              // ── Spacing ──
              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // ── Playlists ──
              SliverToBoxAdapter(
                child: ViewAllSection(
                  title: "Playlist",
                  onPressed: () {},
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 200,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: homeVM.playListArr.length,
                    itemBuilder: (context, index) {
                      var mObj = homeVM.playListArr[index];
                      return PlaylistCell(mObj: mObj, index: index);
                    },
                  ),
                ),
              ),

              // ── Spacing ──
              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // ── Recently Played ──
              SliverToBoxAdapter(
                child: ViewAllSection(
                  title: "Recently Played",
                  onPressed: () {
                    Get.to(() => const RecentlyPlayedView());
                  },
                ),
              ),
              Obx(() {
                if (homeVM.isLoadingRecent.value) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: TColor.focus,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  );
                }

                if (homeVM.recentlyPlayedSongs.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 30,
                        horizontal: 20,
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.history_rounded,
                              size: 36,
                              color: TColor.primaryText28,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Play some music to see\nyour history here",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: TColor.primaryText35,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                // Show last 5 recently played songs
                final songs = homeVM.recentlyPlayedSongs.take(5).toList();
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final song = songs[index];
                        return AllSongRow(
                          sObj: song,
                          index: index,
                          onPressed: () {
                            playerVM.allSongs = songs;
                            playerVM.playSong(song, index);
                            Get.to(() => const MainPlayerView());
                          },
                          onPressedPlay: () {
                            playerVM.allSongs = songs;
                            playerVM.playSong(song, index);
                            Get.to(() => const MainPlayerView());
                          },
                        );
                      },
                      childCount: songs.length,
                    ),
                  ),
                );
              }),

              // Bottom safe-area padding
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ],
      ),
    );
  }

  /// Centered brand title "VibeMusica"
  Widget _buildBrandTitle() {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: TColor.primaryG,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Text(
        "VibeMusica",
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
        );
  }

  /// Frosted-glass search bar when search is active
  Widget _buildActiveSearchBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 38,
          decoration: TColor.glassDecoration(borderRadius: 20),
          child: TextField(
            controller: homeVM.txtSearch.value,
            focusNode: _searchFocusNode,
            autofocus: true,
            style: TextStyle(
              color: TColor.primaryText,
              fontSize: 13,
            ),
            decoration: InputDecoration(
              isDense: true,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 16,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.only(left: 12, right: 8),
                alignment: Alignment.centerLeft,
                width: 20,
                child: Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: TColor.focus,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 36,
                minHeight: 20,
              ),
              hintText: "Search Song",
              hintStyle: TextStyle(
                color: TColor.primaryText28,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 250.ms)
        .slideX(begin: 0.05, end: 0, duration: 250.ms, curve: Curves.easeOut);
  }
}
