import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vibemusica/common/color_extension.dart';
import 'package:vibemusica/view/home/home_view.dart';
import 'package:vibemusica/view/player/mini_player_view.dart';
import 'package:vibemusica/view/settings/settings_view.dart';
import 'package:vibemusica/view/songs/songs_view.dart';
import 'package:vibemusica/view_model/main_player_view_model.dart';
import '../../common_widget/icon_text_row.dart';
import '../../view_model/splash_view_model.dart';

// ──────────────────────────────────────────────
// Tab metadata
// ──────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}

const _kTabs = [
  _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
  _NavItem(icon: Icons.music_note_outlined, activeIcon: Icons.music_note_rounded, label: 'Songs'),
  _NavItem(icon: Icons.settings_outlined, activeIcon: Icons.settings_rounded, label: 'Settings'),
];

// ──────────────────────────────────────────────
// Main tab view
// ──────────────────────────────────────────────
class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  late final PageController _pageController;
  int _currentIndex = 0;
  double _pageValue = 0; // continuous 0‥2 for smooth indicator tracking
  final playerVM = Get.put(MainPlayerViewModel());

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(_onPageScroll);
  }

  void _onPageScroll() {
    final page = _pageController.page;
    if (page != null) setState(() => _pageValue = page);
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    super.dispose();
  }

  void _switchTab(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);
    var splashVM = Get.find<SplashViewModel>();
    return Scaffold(
      key: splashVM.scaffoldKey,
      drawer: Drawer(
        backgroundColor: TColor.bg,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 240,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: TColor.primaryText.withOpacity(0.03),
                ),
                child: Column(
                  children: [
                    Image.asset(
                      "assets/img/app_logo.png",
                      width: media.width * 0.2,
                    ),
                    const SizedBox(height: 30),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              "328\nSongs",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Color(0xFFC1C0C0), fontSize: 12),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              "52\nAlbums",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Color(0xFFC1C0C0), fontSize: 12),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              "87\nArtist",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Color(0xFFC1C0C0), fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            IconTextRow(title: "Themes", icon: "assets/img/m_theme.png", onTap: () {}),
            IconTextRow(title: "Ringtone Cutter", icon: "assets/img/m_ring_cut.png", onTap: () {}),
            IconTextRow(title: "Sleep Timer", icon: "assets/img/m_sleep_timer.png", onTap: () {}),
            IconTextRow(title: "Equliser", icon: "assets/img/m_eq.png", onTap: () {}),
            IconTextRow(title: "Driver Mode", icon: "assets/img/m_driver_mode.png", onTap: () {}),
            IconTextRow(title: "Hidden Folders", icon: "assets/img/m_hidden_folder.png", onTap: () {}),
            IconTextRow(title: "Scan Media", icon: "assets/img/m_scan_media.png", onTap: () {}),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (i) => setState(() => _currentIndex = i),
              children: const [
                HomeView(),
                SongsView(),
                SettingsView(),
              ],
            ),
          ),
          Obx(() {
            if (playerVM.currentSongTitle.isNotEmpty) {
              return const MiniPlayerView();
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      bottomNavigationBar: _GlassNavBar(
        pageValue: _pageValue,
        currentIndex: _currentIndex,
        onTap: _switchTab,
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Glass bottom nav with sliding pill indicator
// ──────────────────────────────────────────────
class _GlassNavBar extends StatelessWidget {
  final double pageValue;
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _GlassNavBar({required this.pageValue, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final width = MediaQuery.of(context).size.width;
    final tabW = width / _kTabs.length;
    final pillW = tabW * 0.58;
    final pillLeft = pageValue * tabW + (tabW - pillW) / 2;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 68 + bottomPad,
          padding: EdgeInsets.only(bottom: bottomPad),
          decoration: BoxDecoration(
            color: TColor.bg.withOpacity(0.7),
            border: Border(
              top: BorderSide(color: TColor.glassBorder, width: 0.5),
            ),
          ),
          child: Stack(
            children: [
              // ── Sliding pill ──
              Positioned(
                left: pillLeft,
                top: 6,
                child: Container(
                  width: pillW,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        TColor.focus.withOpacity(0.18),
                        TColor.focus.withOpacity(0.08),
                      ],
                    ),
                    border: Border.all(
                      color: TColor.focus.withOpacity(0.22),
                      width: 0.6,
                    ),
                  ),
                ),
              ),

              // ── Tab items ──
              Row(
                children: List.generate(_kTabs.length, (i) {
                  final distance = (pageValue - i).abs().clamp(0.0, 1.0);
                  final t = 1.0 - distance; // 1 = fully active, 0 = fully inactive
                  final scale = 1.0 + t * 0.1;
                  final color = Color.lerp(TColor.primaryText28, TColor.focus, t)!;

                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onTap(i),
                      child: SizedBox(
                        height: 62,
                        child: Transform.scale(
                          scale: scale,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                t > 0.5 ? _kTabs[i].activeIcon : _kTabs[i].icon,
                                size: 22,
                                color: color,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _kTabs[i].label,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: t > 0.5 ? FontWeight.w700 : FontWeight.w500,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
