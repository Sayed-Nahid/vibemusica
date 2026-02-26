import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../../common/color_extension.dart';
import '../../common_widget/gradient_mesh_background.dart';
import '../../view_model/main_player_view_model.dart';

class MainPlayerView extends StatefulWidget {
  const MainPlayerView({super.key});

  @override
  State<MainPlayerView> createState() => _MainPlayerViewState();
}

class _MainPlayerViewState extends State<MainPlayerView> {
  final playerVM = Get.put(MainPlayerViewModel());

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Animated mesh background
          const GradientMeshBackground(),

          // Content
          SafeArea(
            child: Column(
              children: [
                // ── Glass AppBar ──
                ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      height: kToolbarHeight,
                      color: TColor.glassFill,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              Get.back();
                            },
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                "Now Playing",
                                style: TextStyle(
                                  color: TColor.primaryText,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.more_horiz_rounded,
                              color: TColor.primaryText35,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: -0.08, end: 0, duration: 400.ms, curve: Curves.easeOut),

                // ── Scrollable body ──
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 30),

                        // ── Album art with glow ──
                        Obx(
                          () => Container(
                            width: media.width * 0.72,
                            height: media.width * 0.72,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: TColor.primary.withOpacity(0.3),
                                  blurRadius: 40,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 10),
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: QueryArtworkWidget(
                                id: playerVM.currentSongId.value,
                                type: ArtworkType.AUDIO,
                                artworkWidth: media.width * 0.72,
                                artworkHeight: media.width * 0.72,
                                artworkFit: BoxFit.cover,
                                nullArtworkWidget: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        TColor.meshPurple.withOpacity(0.4),
                                        TColor.meshBlue.withOpacity(0.4),
                                      ],
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.music_note_rounded,
                                      size: 80,
                                      color: TColor.primaryText35,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 500.ms, delay: 100.ms)
                            .scale(
                              begin: const Offset(0.9, 0.9),
                              end: const Offset(1, 1),
                              duration: 500.ms,
                              delay: 100.ms,
                              curve: Curves.easeOut,
                            ),

                        const SizedBox(height: 32),

                        // ── Song info ──
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            children: [
                              Obx(
                                () => Text(
                                  playerVM.currentSongTitle.value,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: TColor.primaryText,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Obx(
                                () => Text(
                                  playerVM.currentSongArtist.value,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: TColor.primaryText35,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 200.ms)
                            .slideY(begin: 0.06, end: 0, duration: 400.ms, delay: 200.ms, curve: Curves.easeOut),

                        const SizedBox(height: 36),

                        // ── Seek bar ──
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Obx(
                            () => Column(
                              children: [
                                SliderTheme(
                                  data: SliderThemeData(
                                    trackHeight: 3,
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 6,
                                    ),
                                    overlayShape: const RoundSliderOverlayShape(
                                      overlayRadius: 14,
                                    ),
                                    activeTrackColor: TColor.focus,
                                    inactiveTrackColor: TColor.glassBorder,
                                    thumbColor: TColor.focus,
                                    overlayColor: TColor.focus.withOpacity(0.15),
                                  ),
                                  child: Slider(
                                    value: playerVM.position.value.inSeconds.toDouble() <=
                                            playerVM.duration.value.inSeconds.toDouble()
                                        ? playerVM.position.value.inSeconds.toDouble()
                                        : 0.0,
                                    max: playerVM.duration.value.inSeconds.toDouble() > 0
                                        ? playerVM.duration.value.inSeconds.toDouble()
                                        : 1.0,
                                    onChanged: (value) {
                                      playerVM.seekTo(Duration(seconds: value.toInt()));
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        formatDuration(playerVM.position.value),
                                        style: TextStyle(
                                          color: TColor.primaryText35,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        formatDuration(playerVM.duration.value),
                                        style: TextStyle(
                                          color: TColor.primaryText35,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 300.ms),

                        const SizedBox(height: 20),

                        // ── Playback controls ──
                        Obx(
                          () => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Shuffle
                              _controlButton(
                                icon: Icons.shuffle_rounded,
                                size: 22,
                                color: TColor.primaryText35,
                                onTap: () {},
                              ),
                              const SizedBox(width: 16),
                              // Previous
                              _controlButton(
                                icon: Icons.skip_previous_rounded,
                                size: 36,
                                color: TColor.primaryText,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  playerVM.previousSong();
                                },
                              ),
                              const SizedBox(width: 16),
                              // Play / Pause (glass circle)
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.mediumImpact();
                                  if (playerVM.isPlaying.value) {
                                    playerVM.pauseSong();
                                  } else {
                                    playerVM.resumeSong();
                                  }
                                },
                                child: Container(
                                  width: 68,
                                  height: 68,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: TColor.primaryG,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: TColor.focus.withOpacity(0.4),
                                        blurRadius: 20,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    playerVM.isPlaying.value
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 36,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Next
                              _controlButton(
                                icon: Icons.skip_next_rounded,
                                size: 36,
                                color: TColor.primaryText,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  playerVM.nextSong();
                                },
                              ),
                              const SizedBox(width: 16),
                              // Repeat
                              _controlButton(
                                icon: Icons.repeat_rounded,
                                size: 22,
                                color: TColor.primaryText35,
                                onTap: () {},
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 350.ms)
                            .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 350.ms, curve: Curves.easeOut),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required double size,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: TColor.glassFill,
          border: Border.all(color: TColor.glassBorder, width: 0.6),
        ),
        child: Icon(icon, size: size, color: color),
      ),
    );
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
