class PeerDevice {
  PeerDevice({
    required this.id,
    required this.name,
    required this.signal,
    this.connected = false,
  });

  final String id;
  final String name;
  final int signal;
  final bool connected;

  PeerDevice copyWith({
    String? id,
    String? name,
    int? signal,
    bool? connected,
  }) {
    return PeerDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      signal: signal ?? this.signal,
      connected: connected ?? this.connected,
    );
  }
}
