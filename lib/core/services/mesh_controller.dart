import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/chat_message.dart';
import '../models/mesh_user.dart';
import '../models/peer_device.dart';
import '../models/transfer_job.dart';
import '../platform/connectivity_bridge.dart';

class MeshController extends ChangeNotifier {
  MeshController({ConnectivityBridge? bridge}) : _bridge = bridge ?? ConnectivityBridge();

  final ConnectivityBridge _bridge;
  final Random _random = Random();

  Timer? _scanPulse;
  bool _usingSyntheticFallback = false;

  final List<PeerDevice> _peers = <PeerDevice>[];
  final List<MeshUser> _users = <MeshUser>[];
  final Map<String, List<ChatMessage>> _messageByUser = <String, List<ChatMessage>>{};
  final Map<String, Set<String>> _links = <String, Set<String>>{};
  final List<TransferJob> _jobs = <TransferJob>[];

  MeshUser _self = MeshUser(
    id: 'self-node',
    name: '',
    bio: '',
    headline: 'Offline Pioneer',
    avatarSeed: 1,
    isSelf: true,
  );

  String? _activeUserId;

  List<PeerDevice> get peers => List.unmodifiable(_peers);
  List<MeshUser> get users => List.unmodifiable(_users);
  List<ChatMessage> get messages {
    final key = _activeUserId;
    if (key == null) {
      return <ChatMessage>[];
    }
    return List.unmodifiable(_messageByUser[key] ?? <ChatMessage>[]);
  }
  List<TransferJob> get jobs => List.unmodifiable(_jobs);
  MeshUser get self => _self;
  String? get activeUserId => _activeUserId;
  bool get hasProfile => _self.name.trim().isNotEmpty;
  MeshUser? get activeUser => _activeUserId == null ? null : _findUserById(_activeUserId!);

  int get onlineUserCount => _users.where((u) => !u.isSelf).length;
  int get activeRouteHops {
    if (_activeUserId == null) {
      return 0;
    }
    final route = _buildRoute(_activeUserId!);
    return route.length > 1 ? route.length - 1 : 0;
  }

  List<MeshUser> searchableUsers(String query) {
    final q = query.trim().toLowerCase();
    final source = _users.where((u) => !u.isSelf);
    if (q.isEmpty) {
      return source.toList();
    }
    return source.where((u) {
      return u.name.toLowerCase().contains(q) ||
          u.headline.toLowerCase().contains(q) ||
          u.bio.toLowerCase().contains(q);
    }).toList();
  }

  void updateProfile({
    required String name,
    required String bio,
    required String headline,
    required int avatarSeed,
  }) {
    _self = _self.copyWith(
      name: name.trim(),
      bio: bio.trim(),
      headline: headline.trim(),
      avatarSeed: avatarSeed,
    );
    final index = _users.indexWhere((u) => u.id == _self.id);
    if (index >= 0) {
      _users[index] = _self;
    } else {
      _users.insert(0, _self);
    }
    notifyListeners();
  }

  void selectChatUser(String userId) {
    _activeUserId = userId;
    _messageByUser.putIfAbsent(userId, () => <ChatMessage>[]);
    connectPeer(userId);
    notifyListeners();
  }

  Future<void> bootstrap() async {
    _seedUsers();
    await _ensureDiscoveryPermissions();
    await _startNativeDiscovery();
    _startNativePolling();
  }

  Future<void> _ensureDiscoveryPermissions() async {
    if (kIsWeb) {
      return;
    }

    final permissions = <Permission>[Permission.locationWhenInUse];

    if (defaultTargetPlatform == TargetPlatform.android) {
      permissions.addAll(<Permission>[
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.nearbyWifiDevices,
      ]);
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      permissions.add(Permission.bluetooth);
    }

    try {
      await permissions.request();
    } on MissingPluginException {
      // Test and web-like environments may not register permission handlers.
    }
  }

  Future<void> _startNativeDiscovery() async {
    try {
      final nativePeers = await _bridge.discoverPeers();
      if (nativePeers.isNotEmpty) {
        _replacePeers(nativePeers);
      } else {
        _startSyntheticDiscovery();
      }
    } catch (_) {
      _startSyntheticDiscovery();
    }
  }

  void _startNativePolling() {
    _scanPulse?.cancel();
    _scanPulse = Timer.periodic(const Duration(seconds: 3), (_) async {
      try {
        final peers = await _bridge.getDiscoveredPeers();
        if (peers.isEmpty) {
          if (_usingSyntheticFallback && _peers.isNotEmpty) {
            _tickSyntheticSignals();
          }
          if (_peers.isEmpty) {
            _startSyntheticDiscovery();
          }
          return;
        }

        _usingSyntheticFallback = false;
        _replacePeers(peers);
      } catch (_) {
        if (_peers.isEmpty) {
          _startSyntheticDiscovery();
        }
      }
    });
  }

  void _replacePeers(List<Map<String, dynamic>> nativePeers) {
    final updated = nativePeers
        .map(
          (item) => PeerDevice(
            id: item['id']?.toString() ?? 'native-${DateTime.now().microsecondsSinceEpoch}',
            name: item['name']?.toString() ?? 'Native Node',
            signal: (item['signal'] as num?)?.toInt() ?? 60,
            connected: item['id']?.toString() == _activeUserId,
          ),
        )
        .toList();

    _peers
      ..clear()
      ..addAll(updated);

    _syncUsersFromPeers();
    _rebuildLinkGraph();

    if (_activeUserId == null && _users.where((u) => !u.isSelf).isNotEmpty) {
      _activeUserId = _users.firstWhere((u) => !u.isSelf).id;
    }

    notifyListeners();
  }

  void _startSyntheticDiscovery() {
    if (_usingSyntheticFallback) {
      return;
    }
    _usingSyntheticFallback = true;

    if (_peers.isEmpty) {
      _peers.addAll(<PeerDevice>[
        PeerDevice(id: 'node-a', name: 'Astra Phone', signal: 88),
        PeerDevice(id: 'node-b', name: 'Nebula Tab', signal: 74),
        PeerDevice(id: 'node-c', name: 'Orion Node', signal: 53),
        PeerDevice(id: 'node-d', name: 'Nova Link', signal: 67),
        PeerDevice(id: 'node-e', name: 'Atlas Mesh', signal: 62),
      ]);
      _syncUsersFromPeers();
      _rebuildLinkGraph();
      notifyListeners();
    }

    _tickSyntheticSignals();
  }

  void _tickSyntheticSignals() {
    final idx = _random.nextInt(_peers.length);
    final bumped = (_peers[idx].signal + _random.nextInt(13) - 6).clamp(20, 98);
    _peers[idx] = _peers[idx].copyWith(signal: bumped);
    notifyListeners();
  }

  void connectPeer(String peerId) {
    unawaited(_bridge.connectPeer(peerId));
    for (var i = 0; i < _peers.length; i++) {
      final isTarget = _peers[i].id == peerId;
      _peers[i] = _peers[i].copyWith(connected: isTarget);
    }
    _activeUserId = peerId;
    notifyListeners();
  }

  Future<void> sendTextMessage(String text) async {
    final receiverId = _activeUserId;
    if (receiverId == null) {
      return;
    }
    await _sendMessage(
      receiverId: receiverId,
      content: text,
      type: MessageType.text,
    );
  }

  Future<void> sendVoiceMessage() async {
    final receiverId = _activeUserId;
    if (receiverId == null) {
      return;
    }
    final seconds = 2 + _random.nextInt(8);
    await _sendMessage(
      receiverId: receiverId,
      content: 'Voice message',
      type: MessageType.voice,
      voiceDurationSeconds: seconds,
    );
  }

  Future<void> _sendMessage({
    required String receiverId,
    required String content,
    required MessageType type,
    int? voiceDurationSeconds,
  }) async {
    final route = _buildRoute(receiverId);

    final message = ChatMessage(
      id: 'm-${DateTime.now().microsecondsSinceEpoch}',
      senderId: _self.id,
      receiverId: receiverId,
      content: content,
      timestamp: DateTime.now(),
      status: MessageStatus.created,
      type: type,
      routePath: route,
      voiceDurationSeconds: voiceDurationSeconds,
    );
    final inbox = _messageByUser.putIfAbsent(receiverId, () => <ChatMessage>[]);
    inbox.add(message);
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 300));
    _updateMessageStatus(message.id, MessageStatus.sent);
    await Future<void>.delayed(Duration(milliseconds: max(350, route.length * 240)));
    _updateMessageStatus(message.id, MessageStatus.relayed);
    await Future<void>.delayed(Duration(milliseconds: max(420, route.length * 280)));
    _updateMessageStatus(message.id, MessageStatus.delivered);

    await Future<void>.delayed(const Duration(milliseconds: 600));
    final receiver = _findUserById(receiverId);
    if (receiver != null) {
      final response = ChatMessage(
        id: 'r-${DateTime.now().microsecondsSinceEpoch}',
        senderId: receiverId,
        receiverId: _self.id,
        content: type == MessageType.voice
            ? 'Voice note received, forwarding secure reply.'
            : 'Received on mesh route ${route.join(' -> ')}',
        timestamp: DateTime.now(),
        status: MessageStatus.delivered,
        type: MessageType.text,
        routePath: List<String>.from(route.reversed),
      );
      inbox.add(response);
      notifyListeners();
    }
  }

  void _updateMessageStatus(String messageId, MessageStatus status) {
    for (final entry in _messageByUser.entries) {
      final index = entry.value.indexWhere((m) => m.id == messageId);
      if (index < 0) {
        continue;
      }
      entry.value[index] = entry.value[index].copyWith(status: status);
      notifyListeners();
      return;
    }
  }

  void queueTransfer(String fileName, int totalBytes) {
    final job = TransferJob(
      id: 'f-${DateTime.now().microsecondsSinceEpoch}',
      fileName: fileName,
      receiverId: _activeUserId ?? 'unknown',
      totalBytes: totalBytes,
      sentBytes: 0,
      state: TransferState.queued,
    );
    _jobs.add(job);
    notifyListeners();
    _runTransfer(job.id);
  }

  Future<void> _runTransfer(String id) async {
    var index = _jobs.indexWhere((j) => j.id == id);
    if (index < 0) {
      return;
    }
    _jobs[index] = _jobs[index].copyWith(state: TransferState.inProgress);
    notifyListeners();

    while (true) {
      index = _jobs.indexWhere((j) => j.id == id);
      if (index < 0) {
        return;
      }
      final current = _jobs[index];
      if (current.sentBytes >= current.totalBytes) {
        _jobs[index] = current.copyWith(state: TransferState.completed);
        notifyListeners();
        return;
      }
      final step = max(65536, current.totalBytes ~/ 12);
      final nextValue = min(current.totalBytes, current.sentBytes + step);
      _jobs[index] = current.copyWith(sentBytes: nextValue);
      notifyListeners();
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }
  }

  @override
  void dispose() {
    _scanPulse?.cancel();
    unawaited(_bridge.stopDiscovery());
    super.dispose();
  }

  void _seedUsers() {
    _users
      ..clear()
      ..add(_self)
      ..addAll(<MeshUser>[
        MeshUser(id: 'node-a', name: 'Astra', bio: 'Relay volunteer', headline: 'Node Operator', avatarSeed: 2, isSelf: false),
        MeshUser(id: 'node-b', name: 'Nebula', bio: 'Campus network', headline: 'Mesh Builder', avatarSeed: 3, isSelf: false),
        MeshUser(id: 'node-c', name: 'Orion', bio: 'Disaster comms', headline: 'Signal Scout', avatarSeed: 4, isSelf: false),
        MeshUser(id: 'node-d', name: 'Nova', bio: 'Offline map share', headline: 'Map Host', avatarSeed: 5, isSelf: false),
        MeshUser(id: 'node-e', name: 'Atlas', bio: 'Voice relay zone', headline: 'Voice Relay', avatarSeed: 6, isSelf: false),
        MeshUser(id: 'node-f', name: 'Kite', bio: 'Hilltop bridge', headline: 'Chain Link', avatarSeed: 7, isSelf: false),
        MeshUser(id: 'node-g', name: 'Luna', bio: 'Remote station', headline: 'Far Endpoint', avatarSeed: 8, isSelf: false),
      ]);

    _activeUserId = 'node-c';
    _rebuildLinkGraph();
  }

  void _syncUsersFromPeers() {
    final existingIds = _users.map((u) => u.id).toSet();
    for (final peer in _peers) {
      if (!existingIds.contains(peer.id)) {
        _users.add(
          MeshUser(
            id: peer.id,
            name: peer.name,
            bio: 'Nearby mesh peer',
            headline: 'Discovered Node',
            avatarSeed: peer.id.hashCode,
            isSelf: false,
          ),
        );
      }
    }
  }

  void _rebuildLinkGraph() {
    _links
      ..clear()
      ..addAll(<String, Set<String>>{});

    final remoteIds = _users.where((u) => !u.isSelf).map((u) => u.id).toList();
    if (remoteIds.isEmpty) {
      return;
    }

    for (var i = 0; i < remoteIds.length; i++) {
      final current = remoteIds[i];
      if (i == 0) {
        _link(_self.id, current);
      } else {
        _link(remoteIds[i - 1], current);
      }
      if (i > 1 && i.isEven) {
        _link(remoteIds[i - 2], current);
      }
    }
  }

  void _link(String a, String b) {
    _links.putIfAbsent(a, () => <String>{}).add(b);
    _links.putIfAbsent(b, () => <String>{}).add(a);
  }

  List<String> _buildRoute(String targetId) {
    final source = _self.id;
    if (source == targetId) {
      return <String>[source];
    }

    final queue = Queue<String>()..add(source);
    final seen = <String>{source};
    final parent = <String, String>{};

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      final neighbors = _links[current] ?? <String>{};

      for (final next in neighbors) {
        if (seen.contains(next)) {
          continue;
        }
        seen.add(next);
        parent[next] = current;

        if (next == targetId) {
          final path = <String>[targetId];
          var node = targetId;
          while (parent.containsKey(node)) {
            node = parent[node]!;
            path.add(node);
          }
          return path.reversed.toList();
        }
        queue.add(next);
      }
    }

    return <String>[source, targetId];
  }

  MeshUser? _findUserById(String id) {
    for (final user in _users) {
      if (user.id == id) {
        return user;
      }
    }
    return null;
  }
}
