import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../common/color_extension.dart';

class SongsRow extends StatelessWidget {
  final Map sObj;
  final VoidCallback onPressedPlay;
  final VoidCallback onPressed;
  final int index;
  const SongsRow({
    super.key,
    required this.sObj,
    required this.onPressed,
    required this.onPressedPlay,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: TColor.glassBlurSigma,
            sigmaY: TColor.glassBlurSigma,
          ),
          child: Container(
            decoration: TColor.glassDecoration(borderRadius: 14),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                // Play button with glass circle
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onPressedPlay();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: TColor.primary.withOpacity(0.2),
                      border: Border.all(
                        color: TColor.primary.withOpacity(0.4),
                        width: 0.8,
                      ),
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Song info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sObj["name"],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: TColor.primaryText80,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sObj["artists"],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: TColor.primaryText35,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                // Fav + rating
                Column(
                  children: [
                    Image.asset(
                      "assets/img/fav.png",
                      width: 12,
                      height: 12,
                      color: TColor.focus,
                    ),
                    const SizedBox(height: 4),
                    IgnorePointer(
                      ignoring: true,
                      child: RatingBar.builder(
                        initialRating: (sObj["rate"] ?? 4).toDouble(),
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        unratedColor: TColor.glassBorder,
                        itemCount: 5,
                        itemSize: 12,
                        itemPadding: EdgeInsets.zero,
                        itemBuilder: (context, _) => Icon(
                          Icons.star_rounded,
                          color: TColor.org,
                        ),
                        updateOnDrag: false,
                        onRatingUpdate: (_) {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: (80 * index).ms)
        .slideX(
          begin: 0.04,
          end: 0,
          duration: 300.ms,
          delay: (80 * index).ms,
          curve: Curves.easeOut,
        );
  }
}
