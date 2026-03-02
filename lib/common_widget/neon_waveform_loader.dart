import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../common/color_extension.dart';

/// A small neon equalizer/waveform animation that pulses like a music visualizer.
/// Uses a single [AnimationController] driving 7 bars with staggered sine phases.
///
/// Performance:
/// - Wrapped in [RepaintBoundary] to isolate repaints
/// - Uses static [Paint] objects to avoid GC pressure
/// - Only 7 × drawRRect calls per frame (trivially cheap)
/// - Glow via [MaskFilter.blur] (GPU-native, no layer compositing)
class NeonWaveformLoader extends StatefulWidget {
  final double width;
  final double height;
  final Duration duration;

  const NeonWaveformLoader({
    super.key,
    this.width = 80,
    this.height = 32,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<NeonWaveformLoader> createState() => _NeonWaveformLoaderState();
}

class _NeonWaveformLoaderState extends State<NeonWaveformLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _WaveformPainter(_controller.value),
            size: Size(widget.width, widget.height),
          );
        },
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final double t;

  _WaveformPainter(this.t);

  static const int _barCount = 7;
  static const double _barWidth = 3.5;
  static const double _barGap = 5.5;
  static const double _barRadius = 2.0;

  // Static paints to avoid per-frame allocation
  static final Paint _barPaint = Paint()..style = PaintingStyle.fill;
  static final Paint _glowPaint = Paint()
    ..style = PaintingStyle.fill
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

  // Per-bar phase offsets for staggered animation
  static const List<double> _phases = [
    0.0,
    0.9,
    1.8,
    2.7,
    1.2,
    2.1,
    0.5,
  ];

  // Per-bar min/max height ratios (adds variety)
  static const List<double> _minRatios = [
    0.20,
    0.15,
    0.25,
    0.18,
    0.22,
    0.15,
    0.20,
  ];
  static const List<double> _maxRatios = [
    0.85,
    1.0,
    0.90,
    0.95,
    0.80,
    1.0,
    0.88,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final angle = t * 2 * math.pi;
    final totalBarsWidth =
        _barCount * _barWidth + (_barCount - 1) * _barGap;
    final startX = (size.width - totalBarsWidth) / 2;

    for (int i = 0; i < _barCount; i++) {
      // Sine wave with per-bar phase offset → staggered pulsing
      final sinVal = (math.sin(angle + _phases[i]) + 1) / 2; // 0..1
      final minH = size.height * _minRatios[i];
      final maxH = size.height * _maxRatios[i];
      final barHeight = minH + (maxH - minH) * sinVal;

      final x = startX + i * (_barWidth + _barGap);
      final y = size.height - barHeight; // grow from bottom

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, _barWidth, barHeight),
        const Radius.circular(_barRadius),
      );

      // Gradient from coral (top) to pink (bottom) matching app's primaryG
      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [TColor.focusStart, TColor.focus],
      );

      final shaderRect = Rect.fromLTWH(x, y, _barWidth, barHeight);

      // Draw glow layer (behind)
      _glowPaint.shader = gradient.createShader(shaderRect);
      _glowPaint.color = _glowPaint.color.withValues(alpha: 0.5);
      canvas.drawRRect(rect, _glowPaint);

      // Draw solid bar (on top)
      _barPaint.shader = gradient.createShader(shaderRect);
      canvas.drawRRect(rect, _barPaint);
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter oldDelegate) => oldDelegate.t != t;
}
