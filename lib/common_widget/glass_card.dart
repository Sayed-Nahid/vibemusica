import 'dart:ui';
import 'package:flutter/material.dart';
import '../common/color_extension.dart';

/// A reusable frosted-glass card that wraps any child with a
/// [BackdropFilter] blur and a translucent tinted surface.
class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final double? blurSigma;
  final Color? fill;
  final Color? borderColor;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.blurSigma,
    this.fill,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final sigma = blurSigma ?? TColor.glassBlurSigma;
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: Container(
            decoration: TColor.glassDecoration(
              borderRadius: borderRadius,
              fill: fill,
              border: borderColor,
            ),
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
