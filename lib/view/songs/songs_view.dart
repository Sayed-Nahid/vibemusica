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
  bool _isSearching = false;
  final TextEditingController _txtSearch = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

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
  void dispose() {
    controller?.dispose();
    _txtSearch.dispose();
    _searchFocusNode.dispose();
    super.dispose();
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
                                _isSearching
                                    ? IconButton(
                                        onPressed: () {
                                          HapticFeedback.lightImpact();
                                          setState(() {
                                            _isSearching = false;
                                            _txtSearch.clear();
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
                                Expanded(
                                  child: _isSearching
                                      ? _buildActiveSearchBar()
                                      : Center(
                                          child: _buildTitle(),
                                        ),
                                ),
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
                                if (_isSearching && _txtSearch.text.isNotEmpty)
                                  IconButton(
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      setState(() {
                                        _txtSearch.clear();
                                      });
                                    },
                                    icon: Icon(
                                      Icons.close_rounded,
                                      color: TColor.primaryText60,
                                      size: 20,
                                    ),
                                  ),
                                const SizedBox(width: 4),
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

  /// Centered title "Songs"
  Widget _buildTitle() {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: TColor.primaryG,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Text(
        "Songs",
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
            controller: _txtSearch,
            focusNode: _searchFocusNode,
            autofocus: true,
            onChanged: (val) {
              setState(() {});
            },
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
              hintText: "Search Songs, Playlists...",
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
