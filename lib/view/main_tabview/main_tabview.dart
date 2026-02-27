import 'dart:math';
import 'dart:ui' as ui;
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

class _MainTabViewState extends State<MainTabView>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _pulseController;
  int _currentIndex = 0;
  int _originIndex = 0;
  double _pageValue = 0;
  final playerVM = Get.put(MainPlayerViewModel());

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(_onPageScroll);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  void _onPageScroll() {
    final page = _pageController.page;
    if (page != null) {
      // Lock origin when the page is settled on an integer
      if ((page - page.roundToDouble()).abs() < 0.01) {
        _originIndex = page.round();
      }
      setState(() => _pageValue = page);
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _switchTab(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutQuart,
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
      bottomNavigationBar: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, _) => _ElectricNavBar(
          pageValue: _pageValue,
          currentIndex: _currentIndex,
          originIndex: _originIndex,
          pulseValue: _pulseController.value,
          onTap: _switchTab,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Electric‑wire bottom nav (wire at icon level,
// hidden when idle, color thrown on switch)
// ──────────────────────────────────────────────
class _ElectricNavBar extends StatelessWidget {
  final double pageValue;
  final int currentIndex;
  final int originIndex;
  final double pulseValue;
  final ValueChanged<int> onTap;
  const _ElectricNavBar({
    required this.pageValue,
    required this.currentIndex,
    required this.originIndex,
    required this.pulseValue,
    required this.onTap,
  });

  // Nav height 72. Content column: icon(22)+gap(4)+label(12)=38, centered.
  // Icon center Y = (72 - 38)/2 + 22/2 = 17 + 11 = 28 from container top.
  static const double _kNavHeight = 72;
  static const double _kWireY = 28;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return ClipRRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: _kNavHeight + bottomPad,
          padding: EdgeInsets.only(bottom: bottomPad),
          decoration: BoxDecoration(
            color: TColor.bg.withOpacity(0.75),
          ),
          child: Stack(
            children: [
              // ── Electric wire (only during transitions, at icon center) ──
              Positioned.fill(
                child: CustomPaint(
                  painter: _ElectricWirePainter(
                    pageValue: pageValue,
                    tabCount: _kTabs.length,
                    originIndex: originIndex,
                    wireY: _kWireY,
                    glowColor: TColor.focus,
                    dimColor: TColor.primaryText28,
                  ),
                ),
              ),

              // ── Tab items ──
              Positioned.fill(
                child: Row(
                  children: List.generate(_kTabs.length, (i) {
                    final distance = (pageValue - i).abs().clamp(0.0, 1.0);
                    final t = 1.0 - distance;
                    final color =
                        Color.lerp(TColor.primaryText28, TColor.focus, t)!;
                    final pulse = 0.85 + pulseValue * 0.15;

                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onTap(i),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Icon with glow halo ("lit bulb")
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  if (t > 0.3)
                                    BoxShadow(
                                      color: TColor.focus
                                          .withOpacity(0.35 * t * pulse),
                                      blurRadius: 14 * t,
                                      spreadRadius: 2 * t,
                                    ),
                                ],
                              ),
                              child: Icon(
                                t > 0.5
                                    ? _kTabs[i].activeIcon
                                    : _kTabs[i].icon,
                                size: 22,
                                color: color,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _kTabs[i].label,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: t > 0.5
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// CustomPainter: neon comet, icon‑center to icon‑center
// Perf: reuses Paint objects, fewer draw calls, 4 particles
// ──────────────────────────────────────────────
class _ElectricWirePainter extends CustomPainter {
  final double pageValue;
  final int tabCount;
  final int originIndex;
  final double wireY;
  final Color glowColor;
  final Color dimColor;

  _ElectricWirePainter({
    required this.pageValue,
    required this.tabCount,
    required this.originIndex,
    required this.wireY,
    required this.glowColor,
    required this.dimColor,
  });

  // Reusable paint to reduce GC
  static final Paint _paint = Paint()..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    final tabW = size.width / tabCount;

    final frac = (pageValue - pageValue.roundToDouble()).abs();
    if (frac < 0.008) return;

    final wireOp = pow(sin(frac * pi), 0.28).toDouble().clamp(0.0, 1.0);

    final originX = originIndex * tabW + tabW / 2;
    final activeX = pageValue * tabW + tabW / 2;
    final direction = pageValue - originIndex;
    final destIdx = direction > 0 ? pageValue.ceil() : pageValue.floor();
    final destX = destIdx * tabW + tabW / 2;
    final wL = min(originX, destX);
    final wR = max(originX, destX);
    final totalDist = (destX - originX).abs();
    final progress = totalDist > 0
        ? ((activeX - originX).abs() / totalDist).clamp(0.0, 1.0)
        : 0.0;
    final trailDist = (activeX - originX).abs();
    final goingRight = activeX >= originX;

    // ── 1. Dim guide wire ──
    _paint
      ..shader = null
      ..maskFilter = null
      ..color = dimColor.withOpacity(0.18 * wireOp)
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(wL, wireY), Offset(wR, wireY), _paint);

    if (trailDist < 2) return;

    final oOff = Offset(originX, wireY);
    final aOff = Offset(activeX, wireY);

    // ── 2. Wide outer bloom (strong) ──
    _paint
      ..strokeWidth = 22
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12)
      ..shader = ui.Gradient.linear(oOff, aOff, [
        glowColor.withOpacity(0.0),
        glowColor.withOpacity(0.08 * wireOp),
        glowColor.withOpacity(0.25 * wireOp),
      ], const [
        0.0,
        0.4,
        1.0
      ]);
    canvas.drawLine(oOff, aOff, _paint);

    // ── 3. Mid glow (vivid) ──
    _paint
      ..strokeWidth = 8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
      ..shader = ui.Gradient.linear(oOff, aOff, [
        glowColor.withOpacity(0.0),
        glowColor.withOpacity(0.25 * wireOp),
        glowColor.withOpacity(0.75 * wireOp),
      ], const [
        0.0,
        0.45,
        1.0
      ]);
    canvas.drawLine(oOff, aOff, _paint);

    // ── 4. Core neon line (bright, clearly visible) ──
    _paint
      ..strokeWidth = 2.6
      ..maskFilter = null
      ..shader = ui.Gradient.linear(oOff, aOff, [
        glowColor.withOpacity(0.02 * wireOp),
        glowColor.withOpacity(0.2 * wireOp),
        glowColor.withOpacity(0.6 * wireOp),
        glowColor.withOpacity(1.0 * wireOp),
      ], const [
        0.0,
        0.25,
        0.65,
        1.0
      ]);
    canvas.drawLine(oOff, aOff, _paint);

    // ── 5. Trailing sparkle particles ──
    final sparkleColor = Color.lerp(glowColor, Colors.white, 0.5)!;
    _paint
      ..shader = null
      ..maskFilter = null;
    for (int p = 0; p < 4; p++) {
      final t = (p + 1) / 5;
      final spread = trailDist * 0.26;
      final px = activeX + (goingRight ? -spread : spread) * t;
      final py = wireY + sin(p * 2.9 + pageValue * 13) * (3.0 + 1.5 * t);
      final op = ((1.0 - t) * 0.8 * wireOp).clamp(0.0, 1.0);
      _paint.color = sparkleColor.withOpacity(op);
      canvas.drawCircle(Offset(px, py), 1.2 + (1.0 - t) * 1.0, _paint);
    }

    // ── 6. Comet spark (3 layers, bigger & brighter) ──
    _paint
      ..shader = null
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14)
      ..color = glowColor.withOpacity(0.35 * wireOp);
    canvas.drawCircle(aOff, 14, _paint);

    _paint
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5)
      ..color = Color.lerp(glowColor, Colors.white, 0.4)!
          .withOpacity(0.7 * wireOp);
    canvas.drawCircle(aOff, 5.5, _paint);

    _paint
      ..maskFilter = null
      ..color = Colors.white.withOpacity(0.95 * wireOp);
    canvas.drawCircle(aOff, 2.0, _paint);

    // ── 7. Arrival bloom ──
    if (progress > 0.6) {
      final bT = ((progress - 0.6) / 0.4).clamp(0.0, 1.0);
      final dOff = Offset(destX, wireY);
      _paint
        ..color = glowColor.withOpacity(0.28 * bT * wireOp)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10 + 8 * bT);
      canvas.drawCircle(dOff, 10 + 14 * bT, _paint);

      _paint
        ..color = Color.lerp(glowColor, Colors.white, 0.35)!
            .withOpacity(0.55 * bT * wireOp)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
      canvas.drawCircle(dOff, 4 * bT, _paint);
    }

    // ── 8. Intermediate node flash ──
    final tL = min(originX, activeX);
    final tR = max(originX, activeX);
    for (int i = 0; i < tabCount; i++) {
      if (i == originIndex) continue;
      final nodeX = i * tabW + tabW / 2;
      if (nodeX >= tL - 2 && nodeX <= tR + 2) {
        final nd = (activeX - nodeX).abs() / tabW;
        final b = (1.0 - nd).clamp(0.0, 1.0) * wireOp;
        if (b > 0.06) {
          _paint
            ..color = glowColor.withOpacity(0.28 * b)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 7 + 6 * b);
          canvas.drawCircle(Offset(nodeX, wireY), 8 + 6 * b, _paint);
        }
      }
    }
    // Reset for next frame
    _paint
      ..shader = null
      ..maskFilter = null;
  }

  @override
  bool shouldRepaint(covariant _ElectricWirePainter old) =>
      old.pageValue != pageValue;
}
