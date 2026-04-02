import 'package:flutter/material.dart';

import '../../core/services/mesh_controller.dart';
import '../../core/widgets/profile_avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.controller});

  final MeshController controller;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _headlineController;
  late TextEditingController _bioController;
  late int _seed;

  @override
  void initState() {
    super.initState();
    final self = widget.controller.self;
    _nameController = TextEditingController(text: self.name);
    _headlineController = TextEditingController(text: self.headline);
    _bioController = TextEditingController(text: self.bio);
    _seed = self.avatarSeed;
    widget.controller.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    _nameController.dispose();
    _headlineController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (!mounted) {
      return;
    }
    final self = widget.controller.self;
    if (_nameController.text != self.name) {
      _nameController.text = self.name;
    }
    if (_headlineController.text != self.headline) {
      _headlineController.text = self.headline;
    }
    if (_bioController.text != self.bio) {
      _bioController.text = self.bio;
    }
    _seed = self.avatarSeed;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final self = widget.controller.self;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profile', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text('Customize how other users see you across the chain network.'),
          const SizedBox(height: 14),
          Card(
            color: Colors.white10,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: ProfileAvatar(seed: _seed, name: _nameController.text, radius: 42)),
                  const SizedBox(height: 10),
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
                  const SizedBox(height: 10),
                  Text('Avatar style #$_seed'),
                  Slider(
                    value: _seed.toDouble(),
                    min: 1,
                    max: 30,
                    divisions: 29,
                    onChanged: (value) => setState(() => _seed = value.toInt()),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (_nameController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Name is required.')),
                          );
                          return;
                        }
                        widget.controller.updateProfile(
                          name: _nameController.text,
                          bio: _bioController.text,
                          headline: _headlineController.text,
                          avatarSeed: _seed,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profile updated and visible to connected users.')),
                        );
                      },
                      child: const Text('Save Profile'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            color: Colors.white10,
            child: ListTile(
              title: const Text('Public Profile Preview'),
              subtitle: Text('${self.name}\n${self.headline}\n${self.bio}'),
              isThreeLine: true,
              leading: ProfileAvatar(seed: self.avatarSeed, name: self.name),
            ),
          ),
        ],
      ),
    );
  }
}
