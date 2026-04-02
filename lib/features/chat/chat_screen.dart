import 'package:flutter/material.dart';

import '../../core/models/chat_message.dart';
import '../../core/services/mesh_controller.dart';
import '../../core/widgets/profile_avatar.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.controller});

  final MeshController controller;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    _textController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = widget.controller.messages;
    final activeUser = widget.controller.activeUser;
    final recipients = widget.controller.searchableUsers('');

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Text('Offline Chat', style: Theme.of(context).textTheme.headlineMedium),
              const Spacer(),
              Chip(label: Text(activeUser == null ? 'No target' : activeUser.name)),
            ],
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: activeUser?.id,
            decoration: const InputDecoration(
              labelText: 'Send to',
              filled: true,
            ),
            items: recipients
                .map(
                  (u) => DropdownMenuItem<String>(
                    value: u.id,
                    child: Text('${u.name} (${u.headline})'),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                widget.controller.selectChatUser(value);
              }
            },
          ),
          const SizedBox(height: 8),
          if (activeUser != null)
            Row(
              children: [
                ProfileAvatar(seed: activeUser.avatarSeed, name: activeUser.name),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('${activeUser.headline} · ${activeUser.bio}'),
                ),
              ],
            ),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(12),
              child: messages.isEmpty
                  ? const Center(child: Text('No messages yet. Start a secure local chat.'))
                  : ListView.builder(
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        return _MessageBubble(message: msg);
                      },
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message for selected user',
                    filled: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.tonal(
                onPressed: activeUser == null
                    ? null
                    : () async {
                        await widget.controller.sendVoiceMessage();
                      },
                child: const Icon(Icons.mic_rounded),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: activeUser == null
                    ? null
                    : () async {
                  final text = _textController.text.trim();
                  if (text.isEmpty) {
                    return;
                  }
                  _textController.clear();
                  await widget.controller.sendTextMessage(text);
                },
                child: const Icon(Icons.send_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final own = message.senderId == 'self-node';
    final status = switch (message.status) {
      MessageStatus.created => 'CREATED',
      MessageStatus.sent => 'SENT',
      MessageStatus.relayed => 'RELAYED',
      MessageStatus.delivered => 'DELIVERED',
      MessageStatus.failed => 'FAILED',
    };
    final route = message.routePath.join(' -> ');

    return Align(
      alignment: own ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: own ? const Color(0xFF0F2D46) : Colors.white12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.type == MessageType.voice)
              Text('Voice note (${message.voiceDurationSeconds ?? 0}s)')
            else
              Text(message.content),
            const SizedBox(height: 4),
            Text('Route: $route', style: Theme.of(context).textTheme.bodySmall),
            Text(status, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
