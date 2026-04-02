package com.example.meshlink

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	private val channelName = "meshlink.connectivity"
	private lateinit var connectivityManager: MeshConnectivityManager

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)
		connectivityManager = MeshConnectivityManager(this)

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
			.setMethodCallHandler { call, result ->
				when (call.method) {
					"ping" -> result.success(true)
					"startDiscovery" -> result.success(connectivityManager.startDiscovery())
					"getDiscoveredPeers" -> result.success(connectivityManager.getDiscoveredPeers())
					"connectPeer" -> {
						val peerId = call.argument<String>("peerId")
						if (peerId.isNullOrBlank()) {
							result.error("invalid_args", "peerId is required", null)
						} else {
							result.success(connectivityManager.connectPeer(peerId))
						}
					}
					"stopDiscovery" -> {
						connectivityManager.stopDiscovery()
						result.success(true)
					}
					else -> result.notImplemented()
				}
			}
	}

	override fun onDestroy() {
		if (::connectivityManager.isInitialized) {
			connectivityManager.stopDiscovery()
		}
		super.onDestroy()
	}
}
