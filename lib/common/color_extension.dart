import 'dart:ui';
import 'package:flutter/material.dart';

class TColor {
  static Color get primary => const Color(0xffC35BD1);
  static Color get focus => const Color(0xffD9519D);
  static Color get unfocused => const Color(0xff63666E);
  static Color get focusStart => const Color(0xffED8770);

  static Color get secondaryStart => primary;
  static Color get secondaryEnd => const Color(0xff657DDF);

  static Color get org => const Color(0xffE1914B);

  static Color get primaryText => const Color(0xffFFFFFF);
  static Color get primaryText80 => const Color(0xffFFFFFF).withOpacity(0.8);
  static Color get primaryText60 => const Color(0xffFFFFFF).withOpacity(0.6);
  static Color get primaryText35 => const Color(0xffFFFFFF).withOpacity(0.35);
  static Color get primaryText28 => const Color(0xffFFFFFF).withOpacity(0.28);
  static Color get secondaryText => const Color(0xff585A66);
  

  static List<Color> get primaryG => [ focusStart, focus ];
  static List<Color> get secondaryG => [secondaryStart, secondaryEnd];

  static Color get bg => const Color(0xff181B2C);
  static Color get darkGray => const Color(0xff383B49);
  static Color get lightGray => const Color(0xffD0D1D4);

  // --- Glassmorphism tokens ---
  static Color get glassFill => Colors.white.withOpacity(0.08);
  static Color get glassBorder => Colors.white.withOpacity(0.15);
  static Color get glassHighlight => Colors.white.withOpacity(0.25);
  static double get glassBlurSigma => 12.0;

  // Gradient mesh blob colors
  static Color get meshCoral => const Color(0xffED8770);
  static Color get meshPurple => const Color(0xffC35BD1);
  static Color get meshBlue => const Color(0xff657DDF);
  static Color get meshTeal => const Color(0xff4FD1C5);

  /// Standard glass card decoration — frosted translucent card
  static BoxDecoration glassDecoration({
    double borderRadius = 16,
    Color? fill,
    Color? border,
  }) =>
      BoxDecoration(
        color: fill ?? glassFill,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: border ?? glassBorder, width: 0.8),
      );
}

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}
