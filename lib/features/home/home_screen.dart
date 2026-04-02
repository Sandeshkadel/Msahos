import 'dart:math';

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/models/peer_device.dart';
import '../../core/services/mesh_controller.dart';
import '../../core/widgets/profile_avatar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.controller});

  final MeshController controller;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final peers = widget.controller.peers;
    final self = widget.controller.self;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A0F1C), Color(0xFF0F1830), Color(0xFF0A0F1C)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ProfileAvatar(seed: self.avatarSeed, name: self.name, radius: 21),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Landing Dashboard', style: Theme.of(context).textTheme.headlineMedium),
                      Text(self.name.isEmpty ? 'Set your profile to join mesh.' : 'Welcome ${self.name}'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('Online users: ${widget.controller.onlineUserCount}   Active route hops: ${widget.controller.activeRouteHops}'),
            const SizedBox(height: 10),
            const Text('Tap a nearby node to pair over local mesh links.'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text('Profile: ${self.name.isEmpty ? 'Not set' : self.name}')),
                Chip(label: Text('Bio: ${self.bio.isEmpty ? 'None' : self.bio}')),
                Chip(label: Text('Headline: ${self.headline}')),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _RadarPainter(),
                    ),
                  ),
                  ..._buildPeerBlips(peers),
                  const Align(
                    alignment: Alignment.center,
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: MeshLinkColors.primary,
                      child: Icon(Icons.person_pin_circle, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPeerBlips(List<PeerDevice> peers) {
    if (peers.isEmpty) {
      return const [
        Center(child: Text('Scanning for peers...')),
      ];
    }

    final widgets = <Widget>[];
    for (var i = 0; i < peers.length; i++) {
      final peer = peers[i];
      final angle = (i + 1) * (pi / 1.7);
      final radius = 80 + (i * 36);
      final x = cos(angle) * radius;
      final y = sin(angle) * radius;

      widgets.add(
        Align(
          alignment: Alignment.center,
          child: Transform.translate(
            offset: Offset(x, y),
            child: GestureDetector(
              onTap: () => widget.controller.connectPeer(peer.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: peer.connected ? MeshLinkColors.accent.withValues(alpha: 0.25) : Colors.white12,
                  border: Border.all(
                    color: peer.connected ? MeshLinkColors.accent : MeshLinkColors.primary,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(peer.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text('Signal ${peer.signal}%', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    return widgets;
  }
}

class _RadarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = MeshLinkColors.primary.withValues(alpha: 0.35);

    for (var r = 60.0; r < min(size.width, size.height) / 2; r += 45) {
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
