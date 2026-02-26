import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:vibemusica/common_widget/gradient_mesh_background.dart';
import 'package:vibemusica/view/songs/all_songs_view.dart';
import 'package:vibemusica/view/songs/playlists_view.dart';

import '../../common/color_extension.dart';
import '../../view_model/splash_view_model.dart';

class SongsView extends StatefulWidget {
  const SongsView({super.key});

  @override
  State<SongsView> createState() => _SongsViewState();
}

class _SongsViewState extends State<SongsView>
    with SingleTickerProviderStateMixin {
  TabController? controller;
  int selectTab = 0;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 5, vsync: this);
    controller?.addListener(() {
      selectTab = controller?.index ?? 0;
      setState(() {});
    });
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
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Top row: menu / title / search
                          SizedBox(
                            height: kToolbarHeight,
                            child: Row(
                              children: [
                                IconButton(
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
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      "Songs",
                                      style: TextStyle(
                                        color: TColor.primaryText,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.search_rounded,
                                    color: TColor.primaryText35,
                                    size: 22,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Tab bar
                          SizedBox(
                            height: kToolbarHeight - 15,
                            child: TabBar(
                              controller: controller,
                              indicatorColor: TColor.focus,
                              indicatorWeight: 2.5,
                              isScrollable: true,
                              dividerColor: Colors.transparent,
                              indicatorPadding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              labelStyle: TextStyle(
                                color: TColor.focus,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                              unselectedLabelStyle: TextStyle(
                                color: TColor.primaryText28,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              tabs: const [
                                Tab(text: "All Songs"),
                                Tab(text: "Playlists"),
                                Tab(text: "Albums"),
                                Tab(text: "Artists"),
                                Tab(text: "Genres"),
                              ],
                            ),
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
                      curve: Curves.easeOut),
              // Tab content
              Expanded(
                child: TabBarView(
                  controller: controller,
                  children: const [
                    AllSongsView(),
                    PlaylistsView(),
                    Center(
                        child: Text("Albums",
                            style: TextStyle(color: Colors.white54))),
                    Center(
                        child: Text("Artists",
                            style: TextStyle(color: Colors.white54))),
                    Center(
                        child: Text("Genres",
                            style: TextStyle(color: Colors.white54))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
