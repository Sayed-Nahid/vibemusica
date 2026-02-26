import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../common/color_extension.dart';

/// Animated soft gradient mesh background (Apple Music style).
/// Renders blurred colour blobs that drift slowly in a loop.
class GradientMeshBackground extends StatefulWidget {
  const GradientMeshBackground({super.key});

  @override
  State<GradientMeshBackground> createState() =>
      _GradientMeshBackgroundState();
}

class _GradientMeshBackgroundState extends State<GradientMeshBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = _ctrl.value * 2 * math.pi; // 0 → 2π
        return Stack(
          fit: StackFit.expand,
          children: [
            // Base dark fill
            Container(color: TColor.bg),

            // Blob 1 — coral (top-left orbit)
            _Blob(
              color: TColor.meshCoral.withOpacity(0.55),
              size: 280,
              dx: 0.15 + 0.18 * math.sin(t),
              dy: 0.10 + 0.12 * math.cos(t * 0.8),
            ),
            // Blob 2 — purple (center-right orbit)
            _Blob(
              color: TColor.meshPurple.withOpacity(0.45),
              size: 320,
              dx: 0.65 + 0.15 * math.cos(t * 0.7),
              dy: 0.30 + 0.18 * math.sin(t * 0.6),
            ),
            // Blob 3 — blue (bottom-center orbit)
            _Blob(
              color: TColor.meshBlue.withOpacity(0.40),
              size: 260,
              dx: 0.45 + 0.20 * math.sin(t * 0.9 + 1),
              dy: 0.65 + 0.14 * math.cos(t * 0.5),
            ),
            // Blob 4 — teal (wanders)
            _Blob(
              color: TColor.meshTeal.withOpacity(0.30),
              size: 220,
              dx: 0.30 + 0.22 * math.cos(t * 0.6 + 2),
              dy: 0.50 + 0.16 * math.sin(t * 0.7 + 1.5),
            ),

            // Heavy blur over everything to smear blobs into a mesh
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
                child: const SizedBox.expand(),
              ),
            ),

            // Subtle dark overlay so text stays readable
            Container(color: TColor.bg.withOpacity(0.55)),
          ],
        );
      },
    );
  }
}

/// A single radial-gradient circle positioned by fractional [dx],[dy].
class _Blob extends StatelessWidget {
  final Color color;
  final double size;
  final double dx; // 0–1 fraction of parent width
  final double dy; // 0–1 fraction of parent height

  const _Blob({
    required this.color,
    required this.size,
    required this.dx,
    required this.dy,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: MediaQuery.sizeOf(context).width * dx - size / 2,
      top: MediaQuery.sizeOf(context).height * dy - size / 2,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withOpacity(0)],
          ),
        ),
      ),
    );
  }
}
