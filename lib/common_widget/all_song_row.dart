import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../common/color_extension.dart';

class AllSongRow extends StatelessWidget {
  final SongModel sObj;
  final VoidCallback onPressedPlay;
  final VoidCallback onPressed;
  final int index;
  const AllSongRow({
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
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: TColor.glassDecoration(borderRadius: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                // Album art
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: QueryArtworkWidget(
                    id: sObj.id,
                    type: ArtworkType.AUDIO,
                    nullArtworkWidget: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: TColor.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.music_note_rounded,
                        color: TColor.primaryText35,
                        size: 22,
                      ),
                    ),
                    artworkWidth: 48,
                    artworkHeight: 48,
                    artworkFit: BoxFit.cover,
                    artworkBorder: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 12),
                // Song info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sObj.title,
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
                        sObj.artist ?? "Unknown Artist",
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
                // Play button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onPressedPlay();
                  },
                  child: Container(
                    width: 36,
                    height: 36,
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
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 250.ms, delay: (40 * (index % 15)).ms)
        .slideX(
          begin: 0.03,
          end: 0,
          duration: 250.ms,
          delay: (40 * (index % 15)).ms,
          curve: Curves.easeOut,
        );
  }
}
