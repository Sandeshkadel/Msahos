import 'package:flutter/material.dart';

import '../../core/services/mesh_controller.dart';
import '../../core/widgets/profile_avatar.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.controller});

  final MeshController controller;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _headlineController = TextEditingController(text: 'Mesh Explorer');
  int _seed = 1;

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _headlineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF081225), Color(0xFF101D3A), Color(0xFF081225)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Card(
                  color: Colors.white10,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Create Your Profile', style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 8),
                        const Text('Your name and profile card will be visible across the local mesh network.'),
                        const SizedBox(height: 16),
                        Center(child: ProfileAvatar(seed: _seed, name: _nameController.text, radius: 40)),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'User name', filled: true),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _headlineController,
                          decoration: const InputDecoration(labelText: 'Headline', filled: true),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _bioController,
                          decoration: const InputDecoration(labelText: 'Bio', filled: true),
                          minLines: 2,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 14),
                        Text('Avatar style #$_seed'),
                        Slider(
                          value: _seed.toDouble(),
                          min: 1,
                          max: 30,
                          divisions: 29,
                          label: '$_seed',
                          onChanged: (value) => setState(() => _seed = value.toInt()),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () {
                              final name = _nameController.text.trim();
                              if (name.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please enter your user name.')),
                                );
                                return;
                              }
                              widget.controller.updateProfile(
                                name: name,
                                bio: _bioController.text,
                                headline: _headlineController.text,
                                avatarSeed: _seed,
                              );
                            },
                            child: const Text('Enter MeshLink Dashboard'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
