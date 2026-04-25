import 'package:flutter/material.dart';

class ObsidianTheme {
  static const Color bgCream = Color(0xFF1A1A1C);
  static const Color surfaceLight = Color(0xFF222225);
  static const Color cardBg = Color(0xFF2B2B2F);
  static const Color cardBgActive = Color(0xFF3A3A3F);
  static const Color primary = Color(0xFFD96850);
  static const Color primaryDark = Color(0xFFA04840);
  static const Color primaryLight = Color(0xFFEB8777);
  static const Color primaryGhost = Color(0x22D96850);
  static const Color vuGreen = Color(0xFF6BB38A);
  static const Color vuYellow = Color(0xFFE8A860);
  static const Color vuRed = Color(0xFFE07060);
  static const Color textPrimary = Color(0xFFE8E6E1);
  static const Color textSecondary = Color(0xFFBBBBBF);
  static const Color textMuted = Color(0xFF888890);
  static const Color textOnPrimary = Color(0xFFE8E6E1);
  static const Color border = Color(0xFF3A3A3F);
  static const Color borderActive = Color(0xFFD96850);
  static const Color muteActive = Color(0xFFE07060);
  static const Color soloActive = Color(0xFFD96850);
  static const Color beatRepeatOn = Color(0xFF4DA3B3);
  static const Color generateColor = Color(0xFFD96850);
  static const List<Color> pageColors = [
    Color(0xFFD96850),
    Color(0xFF4DA3B3),
    Color(0xFF8B6AB5),
    Color(0xFFD9A54E),
    Color(0xFF6BB38A),
    Color(0xFF5568A0),
    Color(0xFFCB7AA8),
    Color(0xFF6B8299),
  ];
  static const TextStyle labelTiny = TextStyle(
    fontFamily: 'monospace',
    fontSize: 8,
    letterSpacing: 0.8,
    color: textMuted,
  );
  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'monospace',
    fontSize: 10,
    letterSpacing: 0.5,
    color: textSecondary,
  );
  static const TextStyle labelBold = TextStyle(
    fontFamily: 'monospace',
    fontSize: 10,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
    color: textPrimary,
  );
  static const TextStyle slotTitle = TextStyle(
    fontFamily: 'monospace',
    fontSize: 12,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.3,
    color: textPrimary,
  );
  static const TextStyle appTitle = TextStyle(
    fontFamily: 'monospace',
    fontSize: 15,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
    color: primary,
  );
  static const TextStyle noteLabel = TextStyle(
    fontFamily: 'monospace',
    fontSize: 9,
    color: textMuted,
  );
  static BoxDecoration cardDecoration() => BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border, width: 1),
      );
  static BoxDecoration pillDecoration({bool active = false, Color? color}) =>
      BoxDecoration(
        color: active ? (color ?? primary) : cardBg,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: active ? (color ?? primary) : border),
      );
}
