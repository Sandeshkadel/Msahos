import 'package:flutter_test/flutter_test.dart';
import 'package:meshlink/core/models/chat_message.dart';
import 'package:meshlink/core/platform/connectivity_bridge.dart';
import 'package:meshlink/core/services/mesh_controller.dart';

class FakeConnectivityBridge extends ConnectivityBridge {
  @override
  Future<List<Map<String, dynamic>>> discoverPeers() async {
    return <Map<String, dynamic>>[
      {'id': 'node-a', 'name': 'Astra', 'signal': 80},
      {'id': 'node-b', 'name': 'Nebula', 'signal': 72},
      {'id': 'node-c', 'name': 'Orion', 'signal': 65},
      {'id': 'node-d', 'name': 'Nova', 'signal': 60},
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> getDiscoveredPeers() async {
    return discoverPeers();
  }

  @override
  Future<bool> connectPeer(String peerId) async {
    return true;
  }

  @override
  Future<void> stopDiscovery() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('find users returns matches by name', () async {
    final controller = MeshController(bridge: FakeConnectivityBridge());
    await controller.bootstrap();

    final results = controller.searchableUsers('orion');

    expect(results.isNotEmpty, true);
    expect(results.any((u) => u.name.toLowerCase().contains('orion')), true);
    controller.dispose();
  });

  test('chain text message progresses to delivered', () async {
    final controller = MeshController(bridge: FakeConnectivityBridge());
    await controller.bootstrap();
    controller.updateProfile(
      name: 'Tester',
      bio: 'QA node',
      headline: 'Automation',
      avatarSeed: 9,
    );
    controller.selectChatUser('node-c');

    await controller.sendTextMessage('Hello through chain');

    final messages = controller.messages;
    final sent = messages.where((m) => m.senderId == 'self-node').toList();
    expect(sent.isNotEmpty, true);
    expect(sent.last.status, MessageStatus.delivered);
    expect(sent.last.routePath.length >= 2, true);
    controller.dispose();
  });

  test('voice message is sent and stored as voice type', () async {
    final controller = MeshController(bridge: FakeConnectivityBridge());
    await controller.bootstrap();
    controller.updateProfile(
      name: 'Tester',
      bio: 'QA node',
      headline: 'Automation',
      avatarSeed: 10,
    );
    controller.selectChatUser('node-d');

    await controller.sendVoiceMessage();

    final voice = controller.messages.where((m) => m.type == MessageType.voice).toList();
    expect(voice.isNotEmpty, true);
    expect(voice.last.status, MessageStatus.delivered);
    expect((voice.last.voiceDurationSeconds ?? 0) > 0, true);
    controller.dispose();
  });
}
