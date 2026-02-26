import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:vibemusica/common_widget/gradient_mesh_background.dart';
import 'package:vibemusica/common_widget/playlist_cell.dart';
import 'package:vibemusica/common_widget/recommended_cell.dart';
import 'package:vibemusica/common_widget/songs_row.dart';
import 'package:vibemusica/view_model/home_view_model.dart';
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
                leading: IconButton(
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
                title: _buildGlassSearchBar(),
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
                  onPressed: () {},
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      var sObj = homeVM.recentlyPlayedArr[index];
                      return SongsRow(
                        sObj: sObj,
                        onPressed: () {},
                        onPressedPlay: () {},
                        index: index,
                      );
                    },
                    childCount: homeVM.recentlyPlayedArr.length,
                  ),
                ),
              ),

              // Bottom safe-area padding
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ],
      ),
    );
  }

  /// Frosted-glass search bar
  Widget _buildGlassSearchBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 38,
          decoration: TColor.glassDecoration(borderRadius: 20),
          child: TextField(
            controller: homeVM.txtSearch.value,
            style: TextStyle(
              color: TColor.primaryText,
              fontSize: 13,
            ),
            decoration: InputDecoration(
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 4,
                horizontal: 20,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.only(left: 16),
                alignment: Alignment.centerLeft,
                width: 30,
                child: Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: TColor.primaryText35,
                ),
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
        .fadeIn(duration: 500.ms)
        .slideY(begin: -0.1, end: 0, duration: 500.ms, curve: Curves.easeOut);
  }
}
