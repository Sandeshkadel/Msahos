package com.example.meshlink

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.bluetooth.le.BluetoothLeScanner
import android.bluetooth.le.ScanCallback
import android.bluetooth.le.ScanResult
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.net.MacAddress
import android.net.wifi.p2p.WifiP2pConfig
import android.net.wifi.p2p.WifiP2pDevice
import android.net.wifi.p2p.WifiP2pManager
import android.os.Build
import androidx.core.content.ContextCompat

class MeshConnectivityManager(private val context: Context) {
    private val discoveredPeers = LinkedHashMap<String, MutableMap<String, Any>>()

    private val wifiManager = context.getSystemService(Context.WIFI_P2P_SERVICE) as? WifiP2pManager
    private val wifiChannel = wifiManager?.initialize(context, context.mainLooper, null)

    private var bleScanner: BluetoothLeScanner? = null
    private var isScanningBle = false
    private var receiverRegistered = false

    private val bleCallback = object : ScanCallback() {
        override fun onScanResult(callbackType: Int, result: ScanResult) {
            val device = result.device ?: return
            val deviceId = device.address ?: return
            val label = device.name ?: "BLE-${deviceId.takeLast(5)}"
            val signal = normalizeRssi(result.rssi)
            discoveredPeers[deviceId] = mutableMapOf(
                "id" to deviceId,
                "name" to label,
                "signal" to signal,
                "transport" to "ble",
            )
        }

        override fun onBatchScanResults(results: MutableList<ScanResult>) {
            results.forEach { onScanResult(0, it) }
        }
    }

    private val wifiReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            when (intent.action) {
                WifiP2pManager.WIFI_P2P_PEERS_CHANGED_ACTION -> requestWifiPeers()
            }
        }
    }

    fun startDiscovery(): List<Map<String, Any>> {
        startBleDiscovery()
        startWifiDiscovery()
        return snapshotPeers()
    }

    fun getDiscoveredPeers(): List<Map<String, Any>> = snapshotPeers()

    fun connectPeer(peerId: String): Boolean {
        if (!hasWifiPermissions() || wifiManager == null || wifiChannel == null) {
            return false
        }

        val target = discoveredPeers[peerId] ?: return false
        val address = target["address"] as? String ?: peerId

        val config = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            WifiP2pConfig.Builder()
                .setDeviceAddress(MacAddress.fromString(address))
                .build()
        } else {
            WifiP2pConfig().apply {
                deviceAddress = address
            }
        }

        return try {
            wifiManager.connect(wifiChannel, config, null)
            true
        } catch (_: Exception) {
            false
        }
    }

    fun stopDiscovery() {
        stopBleDiscovery()
        if (receiverRegistered) {
            context.unregisterReceiver(wifiReceiver)
            receiverRegistered = false
        }
    }

    private fun startBleDiscovery() {
        if (!hasBlePermissions()) {
            return
        }

        val adapter = BluetoothAdapter.getDefaultAdapter() ?: return
        if (!adapter.isEnabled) {
            return
        }

        bleScanner = adapter.bluetoothLeScanner ?: return
        if (isScanningBle) {
            return
        }

        try {
            bleScanner?.startScan(bleCallback)
            isScanningBle = true
        } catch (_: SecurityException) {
            // Permissions are checked before scanning.
        }
    }

    private fun stopBleDiscovery() {
        if (!isScanningBle) {
            return
        }
        try {
            bleScanner?.stopScan(bleCallback)
        } catch (_: SecurityException) {
            // Ignore failures during app shutdown.
        }
        isScanningBle = false
    }

    private fun startWifiDiscovery() {
        if (!hasWifiPermissions() || wifiManager == null || wifiChannel == null) {
            return
        }

        if (!receiverRegistered) {
            val filter = IntentFilter(WifiP2pManager.WIFI_P2P_PEERS_CHANGED_ACTION)
            context.registerReceiver(wifiReceiver, filter)
            receiverRegistered = true
        }

        try {
            wifiManager.discoverPeers(wifiChannel, null)
        } catch (_: SecurityException) {
            // Permission checks happen before discovery.
        }
    }

    private fun requestWifiPeers() {
        if (!hasWifiPermissions() || wifiManager == null || wifiChannel == null) {
            return
        }

        try {
            wifiManager.requestPeers(wifiChannel) { list ->
                list.deviceList.forEach { device ->
                    val id = device.deviceAddress
                    discoveredPeers[id] = mutableMapOf(
                        "id" to id,
                        "name" to (device.deviceName ?: "WiFi Node"),
                        "signal" to statusToSignal(device.status),
                        "transport" to "wifi_direct",
                        "address" to id,
                    )
                }
            }
        } catch (_: SecurityException) {
            // Permission checks happen before requesting peers.
        }
    }

    private fun snapshotPeers(): List<Map<String, Any>> {
        return discoveredPeers.values.map { HashMap(it) }
    }

    private fun hasBlePermissions(): Boolean {
        val scanPermission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            Manifest.permission.BLUETOOTH_SCAN
        } else {
            Manifest.permission.ACCESS_FINE_LOCATION
        }

        val connectPermission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            Manifest.permission.BLUETOOTH_CONNECT
        } else {
            Manifest.permission.BLUETOOTH
        }

        return hasPermission(scanPermission) && hasPermission(connectPermission)
    }

    private fun hasWifiPermissions(): Boolean {
        val nearbyWifiAllowed = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            hasPermission(Manifest.permission.NEARBY_WIFI_DEVICES)
        } else {
            true
        }

        return nearbyWifiAllowed && hasPermission(Manifest.permission.ACCESS_FINE_LOCATION)
    }

    private fun hasPermission(permission: String): Boolean {
        return ContextCompat.checkSelfPermission(context, permission) == PackageManager.PERMISSION_GRANTED
    }

    private fun normalizeRssi(rssi: Int): Int {
        return ((rssi + 100) * 100 / 65).coerceIn(5, 98)
    }

    private fun statusToSignal(status: Int): Int {
        return when (status) {
            WifiP2pDevice.CONNECTED -> 95
            WifiP2pDevice.INVITED -> 75
            WifiP2pDevice.AVAILABLE -> 65
            WifiP2pDevice.FAILED -> 25
            else -> 50
        }
    }
}
