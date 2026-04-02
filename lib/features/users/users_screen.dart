import 'package:flutter/material.dart';

import '../../core/models/mesh_user.dart';
import '../../core/services/mesh_controller.dart';
import '../../core/widgets/profile_avatar.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({
    super.key,
    required this.controller,
    required this.onOpenChat,
  });

  final MeshController controller;
  final void Function(String userId) onOpenChat;

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    _searchController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final users = widget.controller.searchableUsers(_searchController.text);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Text('Find Users', style: Theme.of(context).textTheme.headlineMedium),
              const Spacer(),
              Chip(label: Text('${users.length} connected')),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name, headline, or bio',
              filled: true,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
                icon: const Icon(Icons.clear),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: users.isEmpty
                ? const Center(child: Text('No users found.'))
                : ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) => _UserCard(
                      user: users[index],
                      onChat: () {
                        widget.onOpenChat(users[index].id);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({required this.user, required this.onChat});

  final MeshUser user;
  final VoidCallback onChat;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white10,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ProfileAvatar(seed: user.avatarSeed, name: user.name, radius: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name, style: Theme.of(context).textTheme.titleLarge),
                  Text(user.headline, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 2),
                  Text(user.bio),
                ],
              ),
            ),
            const SizedBox(width: 10),
            FilledButton.icon(
              onPressed: onChat,
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Chat'),
            ),
          ],
        ),
      ),
    );
  }
}
