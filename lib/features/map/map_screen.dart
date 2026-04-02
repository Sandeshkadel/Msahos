import 'package:flutter/material.dart';

import '../../core/services/mesh_controller.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key, required this.controller});

  final MeshController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Offline Map', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text('MBTiles-ready view for offline routes and secure location sharing.'),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF14243A), Color(0xFF0A0F1C)],
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _GridPainter(),
                    ),
                  ),
                  const Center(
                    child: Icon(Icons.location_on_rounded, size: 46, color: Colors.cyanAccent),
                  ),
                  Positioned(
                    left: 24,
                    top: 34,
                    child: _Pin(label: 'Astra', color: Colors.greenAccent),
                  ),
                  Positioned(
                    right: 30,
                    top: 90,
                    child: _Pin(label: 'Orion', color: Colors.cyanAccent),
                  ),
                  Positioned(
                    left: 70,
                    bottom: 38,
                    child: _Pin(label: 'Nebula', color: Colors.purpleAccent),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Encrypted location beacon sent to nearby nodes.')),
              );
            },
            icon: const Icon(Icons.wifi_tethering),
            label: const Text('Share location offline'),
          ),
        ],
      ),
    );
  }
}

class _Pin extends StatelessWidget {
  const _Pin({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.person_pin_circle, color: color),
        Text(label),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white12
      ..strokeWidth = 1;
    const step = 40.0;

    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
