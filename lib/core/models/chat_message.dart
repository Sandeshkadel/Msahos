enum MessageStatus { created, sent, relayed, delivered, failed }
enum MessageType { text, voice }

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    required this.status,
    required this.type,
    required this.routePath,
    this.voiceDurationSeconds,
  });

  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final MessageStatus status;
  final MessageType type;
  final List<String> routePath;
  final int? voiceDurationSeconds;

  ChatMessage copyWith({
    MessageStatus? status,
    List<String>? routePath,
  }) {
    return ChatMessage(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      timestamp: timestamp,
      status: status ?? this.status,
      type: type,
      routePath: routePath ?? this.routePath,
      voiceDurationSeconds: voiceDurationSeconds,
    );
  }
}
