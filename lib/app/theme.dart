import 'package:flutter/material.dart';

class MeshLinkColors {
  static const background = Color(0xFF0A0F1C);
  static const primary = Color(0xFF00E5FF);
  static const secondary = Color(0xFF7B61FF);
  static const accent = Color(0xFF00FFA3);
  static const text = Color(0xFFE6EAF2);
  static const subtle = Color(0xFF1A2336);
}

ThemeData buildMeshLinkTheme() {
  final scheme = ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: MeshLinkColors.primary,
    primary: MeshLinkColors.primary,
    secondary: MeshLinkColors.secondary,
    surface: MeshLinkColors.subtle,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: MeshLinkColors.background,
    textTheme: const TextTheme(
      headlineMedium: TextStyle(color: MeshLinkColors.text, fontWeight: FontWeight.w700),
      titleLarge: TextStyle(color: MeshLinkColors.text, fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(color: MeshLinkColors.text),
      bodySmall: TextStyle(color: Color(0xFFA0A7B5)),
    ),
  );
}
