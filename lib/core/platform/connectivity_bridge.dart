import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ConnectivityBridge {
  ConnectivityBridge();

  static const MethodChannel _channel = MethodChannel('meshlink.connectivity');

  Future<bool> pingNative() async {
    if (kIsWeb) {
      return false;
    }
    try {
      final result = await _channel.invokeMethod<bool>('ping');
      return result ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> discoverPeers() async {
    if (kIsWeb) {
      return <Map<String, dynamic>>[];
    }
    try {
      final result = await _channel.invokeMethod<List<dynamic>>('startDiscovery');
      return _normalizePeers(result);
    } on MissingPluginException {
      return <Map<String, dynamic>>[];
    }
  }

  Future<List<Map<String, dynamic>>> getDiscoveredPeers() async {
    if (kIsWeb) {
      return <Map<String, dynamic>>[];
    }
    try {
      final result = await _channel.invokeMethod<List<dynamic>>('getDiscoveredPeers');
      return _normalizePeers(result);
    } on MissingPluginException {
      return <Map<String, dynamic>>[];
    }
  }

  Future<bool> connectPeer(String peerId) async {
    if (kIsWeb) {
      return false;
    }
    try {
      final result = await _channel.invokeMethod<bool>('connectPeer', {'peerId': peerId});
      return result ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<void> stopDiscovery() async {
    if (kIsWeb) {
      return;
    }
    try {
      await _channel.invokeMethod<bool>('stopDiscovery');
    } on MissingPluginException {
      return;
    }
  }

  List<Map<String, dynamic>> _normalizePeers(List<dynamic>? result) {
    if (result == null) {
      return <Map<String, dynamic>>[];
    }
    return result
        .whereType<Map>()
        .map((item) => item.map((key, value) => MapEntry(key.toString(), value)))
        .toList();
  }
}
