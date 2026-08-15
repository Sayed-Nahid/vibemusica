import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vibemusica/common/color_extension.dart';
import 'package:vibemusica/view_model/folders_view_model.dart';

class FolderCell extends StatelessWidget {
  final FolderModel folder;
  final VoidCallback onPressed;
  final int index;

  const FolderCell({
    super.key,
    required this.folder,
    required this.onPressed,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: TColor.glassDecoration(borderRadius: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: TColor.org.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.folder_rounded,
                color: TColor.org,
                size: 24,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    folder.folderName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: TColor.primaryText80,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${folder.songCount} songs',
                    style: TextStyle(
                      color: TColor.primaryText35,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 15),
            Container(
              width: 34,
              height: 34,
              decoration: TColor.glassDecoration(borderRadius: 17),
              child: Icon(
                Icons.play_arrow_rounded,
                color: TColor.primaryText,
                size: 20,
              ),
            ),
          ],
        ),
      ).animate()
          .fadeIn(
            duration: 400.ms,
            delay: (50 * index).ms,
            curve: Curves.easeOut,
          )
          .slideX(
            begin: 0.1,
            end: 0,
            duration: 400.ms,
            delay: (50 * index).ms,
            curve: Curves.easeOut,
          ),
    );
  }
}
