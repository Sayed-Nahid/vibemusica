import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:vibemusica/common/color_extension.dart';
import 'package:vibemusica/common_widget/glass_card.dart';
import 'package:vibemusica/common_widget/gradient_mesh_background.dart';
import 'package:vibemusica/common_widget/neon_waveform_loader.dart';
import 'package:vibemusica/view_model/splash_view_model.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  final splashVM = Get.put(SplashViewModel());

  @override
  void initState() {
    super.initState();
    splashVM.loadView();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: TColor.bg,
      body: Stack(
        children: [
          // Layer 0: Animated gradient mesh background
          const Positioned.fill(
            child: GradientMeshBackground(),
          ),

          // Layer 1: Centered branding content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── App logo with purple glow bloom ──
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: TColor.primary.withValues(alpha: 0.45),
                        blurRadius: 50,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    "assets/img/splash_screen.png",
                    width: screenWidth * 0.38,
                  ),
                )
                    .animate()
                    .fadeIn(
                      duration: 500.ms,
                      delay: 200.ms,
                      curve: Curves.easeOut,
                    )
                    .scale(
                      begin: const Offset(0.6, 0.6),
                      end: const Offset(1.0, 1.0),
                      duration: 500.ms,
                      delay: 200.ms,
                      curve: Curves.easeOutBack,
                    ),

                const SizedBox(height: 24),

                // ── "VibeMúsica" wordmark with gradient ──
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: TColor.primaryG,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    "VibeMúsica",
                    style: TextStyle(
                      fontFamily: "Circular Std",
                      fontWeight: FontWeight.w700,
                      fontSize: 30,
                      color: TColor.primaryText,
                      letterSpacing: 1.2,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(
                      duration: 500.ms,
                      delay: 500.ms,
                      curve: Curves.easeOut,
                    )
                    .slideY(
                      begin: 0.3,
                      end: 0,
                      duration: 500.ms,
                      delay: 500.ms,
                      curve: Curves.easeOutCubic,
                    ),

                const SizedBox(height: 40),

                // ── Neon waveform loading indicator ──
                const NeonWaveformLoader(
                  width: 85,
                  height: 30,
                  duration: Duration(milliseconds: 800),
                )
                    .animate()
                    .fadeIn(
                      duration: 400.ms,
                      delay: 800.ms,
                      curve: Curves.easeOut,
                    )
                    .scale(
                      begin: const Offset(0.7, 0.7),
                      end: const Offset(1.0, 1.0),
                      duration: 400.ms,
                      delay: 800.ms,
                      curve: Curves.easeOutBack,
                    ),

                const SizedBox(height: 28),

                // ── Frosted glass tagline pill ──
                GlassCard(
                  borderRadius: 20,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  blurSigma: 8,
                  child: Text(
                    "Feel the Vibe",
                    style: TextStyle(
                      fontFamily: "Circular Std",
                      fontSize: 13,
                      color: TColor.primaryText60,
                      letterSpacing: 0.8,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(
                      duration: 400.ms,
                      delay: 1000.ms,
                      curve: Curves.easeOut,
                    )
                    .slideY(
                      begin: 0.4,
                      end: 0,
                      duration: 400.ms,
                      delay: 1000.ms,
                      curve: Curves.easeOutCubic,
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
