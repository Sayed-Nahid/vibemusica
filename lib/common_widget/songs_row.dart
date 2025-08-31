import 'package:flutter/material.dart';

import '../common/color_extension.dart';


class SongsRow extends StatelessWidget {
  final Map sObj;
  final VoidCallback onPressedPlay;
  final VoidCallback onPressed;
  const SongsRow({
    super.key,
    required this.sObj,
    required this.onPressed,
    required this.onPressedPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            IconButton(
                onPressed: onPressedPlay,
                icon: Image.asset(
                  "assets/img/play_btn.png",
                  width: 25,
                  height: 25,
                ),
            ),
            Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sObj["name"],
                      maxLines: 1,
                      style: TextStyle(
                          color: TColor.primaryText60,
                          fontSize: 13,
                          fontWeight: FontWeight.w700
                      ),
                    ),
                    Text(
                      sObj["artists"],
                      maxLines: 1,
                      style: TextStyle(
                          color: TColor.secondaryText,
                          fontSize: 10,
                      ),
                    ),
                  ],
                ),
            ),
          ],
        ),
        Divider(
          color: Colors.white.withOpacity(0.07),
          indent: 50,
        ),
      ],
    );
  }
}
