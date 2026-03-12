import 'package:flutter/material.dart';

class ObsidianTheme {
  static const Color bgCream = Color(0xFFF5EDE8);
  static const Color surfaceLight = Color(0xFFFAF3EF);
  static const Color cardBg = Color(0xFFEFE3DC);
  static const Color cardBgActive = Color(0xFFF7E8E4);

  static const Color primary = Color(0xFFB5443A);
  static const Color primaryDark = Color(0xFF8C302A);
  static const Color primaryLight = Color(0xFFD4736A);
  static const Color primaryGhost = Color(0x22B5443A);

  static const Color vuGreen = Color(0xFF7BAE7F);
  static const Color vuYellow = Color(0xFFD4A843);
  static const Color vuRed = Color(0xFFB5443A);

  static const Color textPrimary = Color(0xFF2E1A18);
  static const Color textSecondary = Color(0xFF7A5550);
  static const Color textMuted = Color(0xFFAA8880);
  static const Color textOnPrimary = Color(0xFFFFF5F3);

  static const Color border = Color(0xFFD4B8B0);
  static const Color borderActive = Color(0xFFB5443A);

  static const Color muteActive = Color(0xFF8C302A);
  static const Color soloActive = Color(0xFFD4A843);
  static const Color beatRepeatOn = Color(0xFF4A7A8A);
  static const Color generateColor = Color(0xFFB5443A);

  static const List<Color> pageColors = [
    Color(0xFFB5443A),
    Color(0xFFC46B40),
    Color(0xFF8B6B9A),
    Color(0xFF4A7A8A),
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
        border: Border.all(
          color: border,
          width: 1,
        ),
      );

  static BoxDecoration pillDecoration({bool active = false, Color? color}) =>
      BoxDecoration(
        color: active ? (color ?? primary) : cardBg,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: active ? (color ?? primary) : border),
      );
}
