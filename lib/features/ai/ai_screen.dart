import 'package:flutter/material.dart';

import '../../core/services/mesh_controller.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key, required this.controller});

  final MeshController controller;

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final TextEditingController _promptController = TextEditingController();
  final List<String> _history = <String>[];

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Offline AI', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(width: 12),
              const Chip(label: Text('LOCAL MODEL ACTIVE')),
            ],
          ),
          const SizedBox(height: 10),
          const Text('Edge-ready AI panel. The current baseline includes local prompt flow wiring.'),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(16),
              ),
              child: _history.isEmpty
                  ? const Center(child: Text('Ask for summary, route insight, or relay diagnostics.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _history.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(_history[index]),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _promptController,
                  decoration: const InputDecoration(
                    hintText: 'Ask offline AI or Ask Network',
                    filled: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () {
                  final input = _promptController.text.trim();
                  if (input.isEmpty) {
                    return;
                  }
                  _promptController.clear();
                  setState(() {
                    _history.add('You: $input');
                    _history.add('MeshLink AI: Draft answer generated locally and queued for network assist.');
                  });
                },
                child: const Icon(Icons.auto_awesome),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
