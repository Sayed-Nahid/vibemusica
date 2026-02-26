import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../common/color_extension.dart';

/// Animated soft gradient mesh background (Apple Music style).
/// Uses a custom painter with very large soft radial gradients
/// so blobs appear naturally blurred — no BackdropFilter needed.
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
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return CustomPaint(
            painter: _MeshPainter(_ctrl.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _MeshPainter extends CustomPainter {
  final double t;
  _MeshPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final angle = t * 2 * math.pi;

    // Dark base
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = TColor.bg,
    );

    // Blob definitions: color, radius, center-x fraction, center-y fraction
    final blobs = <_BlobDef>[
      _BlobDef(
        color: TColor.meshCoral.withOpacity(0.50),
        radius: size.width * 0.55,
        cx: size.width * (0.15 + 0.18 * math.sin(angle)),
        cy: size.height * (0.10 + 0.12 * math.cos(angle * 0.8)),
      ),
      _BlobDef(
        color: TColor.meshPurple.withOpacity(0.40),
        radius: size.width * 0.60,
        cx: size.width * (0.65 + 0.15 * math.cos(angle * 0.7)),
        cy: size.height * (0.30 + 0.18 * math.sin(angle * 0.6)),
      ),
      _BlobDef(
        color: TColor.meshBlue.withOpacity(0.35),
        radius: size.width * 0.50,
        cx: size.width * (0.45 + 0.20 * math.sin(angle * 0.9 + 1)),
        cy: size.height * (0.65 + 0.14 * math.cos(angle * 0.5)),
      ),
      _BlobDef(
        color: TColor.meshTeal.withOpacity(0.25),
        radius: size.width * 0.45,
        cx: size.width * (0.30 + 0.22 * math.cos(angle * 0.6 + 2)),
        cy: size.height * (0.50 + 0.16 * math.sin(angle * 0.7 + 1.5)),
      ),
    ];

    for (final blob in blobs) {
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [blob.color, blob.color.withOpacity(0)],
          stops: const [0.0, 1.0],
        ).createShader(
          Rect.fromCircle(center: Offset(blob.cx, blob.cy), radius: blob.radius),
        );
      canvas.drawCircle(Offset(blob.cx, blob.cy), blob.radius, paint);
    }

    // Dark overlay for text readability
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = TColor.bg.withOpacity(0.50),
    );
  }

  @override
  bool shouldRepaint(_MeshPainter oldDelegate) => oldDelegate.t != t;
}

class _BlobDef {
  final Color color;
  final double radius;
  final double cx;
  final double cy;
  const _BlobDef({
    required this.color,
    required this.radius,
    required this.cx,
    required this.cy,
  });
}
