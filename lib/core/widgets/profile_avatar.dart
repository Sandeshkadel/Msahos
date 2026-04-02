import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.seed,
    required this.name,
    this.radius = 20,
  });

  final int seed;
  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final palette = <Color>[
      const Color(0xFF00E5FF),
      const Color(0xFF7B61FF),
      const Color(0xFF00FFA3),
      const Color(0xFFFF8A00),
      const Color(0xFF4ADE80),
      const Color(0xFFF97316),
    ];
    final color = palette[seed.abs() % palette.length];
    final trimmed = name.trim();
    final initial = trimmed.isEmpty ? '?' : trimmed.substring(0, 1).toUpperCase();

    return CircleAvatar(
      radius: radius,
      backgroundColor: color.withValues(alpha: 0.25),
      child: Text(
        initial,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.9,
        ),
      ),
    );
  }
}
