package com.unreallx.redrive.Utils

import android.app.Application
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.wifi.ScanResult
import android.net.wifi.WifiConfiguration
import android.net.wifi.WifiManager
import android.os.Build
import android.util.Log
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

enum class WifiStatus {
    Idle,
    Scanning,
    Scanned,
    Connecting,
    Connected,
    Failed
}

data class WifiNetworkUiState(
    val ssid: String,
    val bssid: String?,
    val level: Int,
    val status: WifiStatus
)

class WifiViewModel(application: Application) : AndroidViewModel(application) {
    private val context = getApplication<Application>().applicationContext
    private val wifiManager = context.getSystemService(Context.WIFI_SERVICE) as WifiManager

    private val _wifiNetworks = MutableStateFlow<Map<String, WifiNetworkUiState>>(emptyMap())
    val wifiNetworks: StateFlow<Map<String, WifiNetworkUiState>> = _wifiNetworks.asStateFlow()

    private val _connectedNetwork = MutableStateFlow<WifiNetworkUiState?>(null)
    val connectedNetwork: StateFlow<WifiNetworkUiState?> = _connectedNetwork.asStateFlow()

    private val _isScanning = MutableStateFlow(false)
    val isScanning: StateFlow<Boolean> = _isScanning.asStateFlow()

    private val receiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            when (intent?.action) {
                WifiManager.SCAN_RESULTS_AVAILABLE_ACTION -> {
                    val results = wifiManager.scanResults
                    Log.d("wifiQQ", "Сканирование завершено. Найдено: ${results.size} сетей")
                    updateScanResults(results)
                    _isScanning.value = false
                }
            }
        }
    }

    init {
        registerReceiver()
        checkCurrentConnection()
    }

    private fun registerReceiver() {
        val filter = IntentFilter(WifiManager.SCAN_RESULTS_AVAILABLE_ACTION)
        context.registerReceiver(receiver, filter)
    }

    fun startScan() {
        if (!wifiManager.isWifiEnabled) {
            wifiManager.isWifiEnabled = true
        }

        if (_isScanning.value) {
            Log.d("wifi", "Сканирование уже запущено")
            return
        }

        _isScanning.value = true
        val started = wifiManager.startScan()
        Log.d("wifi", "Сканирование сетей Wi-Fi запущено: $started")
    }

    private fun updateScanResults(results: List<ScanResult>) {
        val networkMap = results.associateBy(
            keySelector = { it.SSID },
            valueTransform = {
                WifiNetworkUiState(
                    ssid = it.SSID,
                    bssid = it.BSSID,
                    level = it.level,
                    status = WifiStatus.Scanned
                )
            }
        )
        _wifiNetworks.value = networkMap
    }

    fun connectToNetwork(ssid: String, password: String?) {
        val existing = _wifiNetworks.value[ssid]
        if (existing == null) {
            Log.w("wifi", "Нет сети с SSID $ssid в списке")
            return
        }

        _wifiNetworks.update { oldMap ->
            oldMap + (ssid to existing.copy(status = WifiStatus.Connecting))
        }

        viewModelScope.launch {
            val config = WifiConfiguration().apply {
                SSID = "\"$ssid\""
                if (password.isNullOrBlank()) {
                    allowedKeyManagement.set(WifiConfiguration.KeyMgmt.NONE)
                } else {
                    preSharedKey = "\"$password\""
                }
            }

            val netId = wifiManager.addNetwork(config)
            if (netId == -1) {
                Log.e("wifi", "Не удалось добавить конфигурацию для $ssid")
                updateStatus(ssid, WifiStatus.Failed)
                return@launch
            }

            wifiManager.disconnect()
            val enabled = wifiManager.enableNetwork(netId, true)
            val reconnected = wifiManager.reconnect()

            Log.d("wifi", "enableNetwork=$enabled, reconnect=$reconnected")

            if (enabled && reconnected) {
                updateStatus(ssid, WifiStatus.Connected)
                _connectedNetwork.value = existing.copy(status = WifiStatus.Connected)
            } else {
                updateStatus(ssid, WifiStatus.Failed)
            }
        }
    }

    private fun updateStatus(ssid: String, status: WifiStatus) {
        _wifiNetworks.update { oldMap ->
            oldMap.mapValues { entry ->
                if (entry.key == ssid) {
                    entry.value.copy(status = status)
                } else {
                    entry.value
                }
            }
        }
    }

    private fun checkCurrentConnection() {
        val connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            connectivityManager.registerDefaultNetworkCallback(object : ConnectivityManager.NetworkCallback() {
                override fun onAvailable(network: Network) {
                    val capabilities = connectivityManager.getNetworkCapabilities(network)
                    if (capabilities?.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) == true) {
                        val info = wifiManager.connectionInfo
                        val ssid = info.ssid?.removeSurrounding("\"")
                        Log.d("wifi", "Подключено к $ssid")

                        ssid?.let {
                            _connectedNetwork.value = WifiNetworkUiState(
                                ssid = it,
                                bssid = info.bssid,
                                level = WifiManager.calculateSignalLevel(info.rssi, 5),
                                status = WifiStatus.Connected
                            )
                        }
                    }
                }

                override fun onLost(network: Network) {
                    Log.d("wifi", "Wi-Fi соединение потеряно")
                    _connectedNetwork.value = null
                }
            })
        } else {
            // Для старых API можно проверить текущее подключение напрямую:
            val info = wifiManager.connectionInfo
            if (info.networkId != -1) {
                val ssid = info.ssid?.removeSurrounding("\"")
                ssid?.let {
                    _connectedNetwork.value = WifiNetworkUiState(
                        ssid = it,
                        bssid = info.bssid,
                        level = WifiManager.calculateSignalLevel(info.rssi, 5),
                        status = WifiStatus.Connected
                    )
                }
            }
        }
    }

    fun clearNetworks() {
        _wifiNetworks.value = emptyMap()
    }

    override fun onCleared() {
        super.onCleared()
        context.unregisterReceiver(receiver)
    }
}
