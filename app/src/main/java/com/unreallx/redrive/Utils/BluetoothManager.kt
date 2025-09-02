package com.unreallx.redrive.Utils

import android.app.Application
import android.bluetooth.BluetoothA2dp
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothHeadset
import android.bluetooth.BluetoothProfile
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.widget.Toast
import androidx.core.content.ContextCompat
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.TimeoutCancellationException
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import kotlinx.coroutines.withTimeout
import java.io.IOException
import java.io.InputStream
import java.io.OutputStream
import java.util.UUID

enum class DeviceStatus {
    Idle,
    Pairing,
    Paired,
    Connecting,
    Connected,
    Failed,
}

data class BluetoothDeviceUiState(
    val device: BluetoothDevice,
    val status: DeviceStatus,
)

data class Obd2Data(
    val rpm: Int = 0,
    val speed: Int = 0,
    val engineTemp: Int = 0,
)

class BluetoothViewModel(
    application: Application,
) : AndroidViewModel(application) {
    private val context = getApplication<Application>().applicationContext
    private val bluetoothAdapter: BluetoothAdapter? = BluetoothAdapter.getDefaultAdapter()
    private val obd2UUID: UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB")

    private val _deviceStates = MutableStateFlow<Map<String, BluetoothDeviceUiState>>(emptyMap())
    val deviceStates: StateFlow<Map<String, BluetoothDeviceUiState>> = _deviceStates.asStateFlow()

    private val _connectedDevice = MutableStateFlow<BluetoothDevice?>(null)
    val connectedDevice: StateFlow<BluetoothDevice?> = _connectedDevice.asStateFlow()

    private val _isDiscovering = MutableStateFlow(false)
    val isDiscovering: StateFlow<Boolean> = _isDiscovering.asStateFlow()

    private val _obd2Data = MutableStateFlow(Obd2Data())
    val obd2Data: StateFlow<Obd2Data> = _obd2Data.asStateFlow()

    private val deviceJobs = mutableMapOf<String, Job>()
    private val deviceMap = mutableMapOf<String, BluetoothDevice>()

    private val _isDemoMode = MutableStateFlow(false)

    private var demoJob: Job? = null

    fun setDemoMode(enabled: Boolean) {
        LoggingReDrive.logMessage("Setting demo mode to $enabled")
        _isDemoMode.value = enabled
        demoJob?.cancel()
        if (enabled) {
            LoggingReDrive.logMessage("Starting demo mode")
            demoJob =
                viewModelScope.launch {
                    while (isActive) {
                        val randomRpm = (700..4000).random()
                        val randomSpeed = (0..280).random()
                        val randomTemp = (70..110).random()
                        _obd2Data.value = Obd2Data(rpm = randomRpm, speed = randomSpeed, engineTemp = randomTemp)
                        LoggingReDrive.logMessage("Random values car: speed = $randomSpeed, rpm = $randomRpm, temp = $randomTemp")
                        delay(1000)
                    }
                }
        } else {
            LoggingReDrive.logMessage("Demo mode disabled, OBD2 data reset to 0")
            _obd2Data.value = Obd2Data(rpm = 0, speed = 0, engineTemp = 0)
        }
    }

    private val receiver =
        object : BroadcastReceiver() {
            override fun onReceive(
                ctx: Context?,
                intent: Intent?,
            ) {
                LoggingReDrive.logMessage("BroadcastReceiver received intent: ${intent?.action}")
                when (intent?.action) {
                    BluetoothAdapter.ACTION_STATE_CHANGED -> {
                        val state = intent.getIntExtra(BluetoothAdapter.EXTRA_STATE, BluetoothAdapter.ERROR)
                        LoggingReDrive.logMessage("Bluetooth state changed to $state")
                        if (state == BluetoothAdapter.STATE_ON) {
                            LoggingReDrive.logMessage("Bluetooth turned on, initiating discovery")
                            startDiscovery()
                        } else if (state == BluetoothAdapter.STATE_OFF) {
                            LoggingReDrive.logMessage("ACTION_STATE_CHANGED")
                            clearDevices()
                            _isDiscovering.value = false
                            if (_isDemoMode.value != true) {
                                _connectedDevice.value?.let { device ->
                                    if (isObd2Device(device)) {
                                        LoggingReDrive.logMessage("Device disconnected lvl1, OBD2 data reset to 0")
                                        Toast.makeText(context, "Соединение потеряно lvl1", Toast.LENGTH_SHORT).show()
                                        _obd2Data.value = Obd2Data(rpm = 0, speed = 0, engineTemp = 0)
                                    }
                                }
                            }
                        }
                    }

                    BluetoothDevice.ACTION_FOUND -> {
                        val device = intent.getParcelableExtra<BluetoothDevice>(BluetoothDevice.EXTRA_DEVICE)
                        LoggingReDrive.logMessage("Device found: ${device?.name} (${device?.address})")
                        device?.takeIf { it.name != null && !deviceMap.containsKey(it.address) }?.let {
                            LoggingReDrive.logMessage("Adding new device to map: ${it.name}")
                            deviceMap[it.address] = it
                            updateDeviceState(it, DeviceStatus.Idle)
                        }
                    }

                    BluetoothDevice.ACTION_ACL_CONNECTED -> {
                        val device = intent.getParcelableExtra<BluetoothDevice>(BluetoothDevice.EXTRA_DEVICE)
                        device?.let {
                            LoggingReDrive.logMessage("Device ACL connected: ${it.name} (${it.address})")
                            if (isObd2Device(it)) {
                                LoggingReDrive.logMessage("Device auto connecting launch1")
                                connectToObd2Device(it)
                            }
                        }
                    }

                    BluetoothDevice.ACTION_ACL_DISCONNECTED -> {
                        val device = intent.getParcelableExtra<BluetoothDevice>(BluetoothDevice.EXTRA_DEVICE)
                        device?.let {
                            LoggingReDrive.logMessage("Device ACL disconnected: ${it.name} (${it.address})")
                            if (isObd2Device(it)) {
                                LoggingReDrive.logMessage("OBD2 device disconnected and data reset to 0 lnc11111")
                                _obd2Data.value = Obd2Data(rpm = 0, speed = 0, engineTemp = 0)
                                Toast.makeText(context, "OBD2 device disconnected", Toast.LENGTH_SHORT).show()
                            }
                        }
                    }
                    BluetoothAdapter.ACTION_DISCOVERY_FINISHED -> {
                        LoggingReDrive.logMessage("Discovery process finished")
                        _isDiscovering.value = false
                    }
                    BluetoothDevice.ACTION_BOND_STATE_CHANGED -> {
                        val device = intent.getParcelableExtra<BluetoothDevice>(BluetoothDevice.EXTRA_DEVICE)
                        val bondState = intent.getIntExtra(BluetoothDevice.EXTRA_BOND_STATE, BluetoothDevice.ERROR)
                        device?.let {
                            LoggingReDrive.logMessage("Bond state changed for ${it.name} to $bondState")
                            when (bondState) {
                                BluetoothDevice.BOND_BONDED -> {
                                    LoggingReDrive.logMessage("Устройство сопряжено: ${it.name}")
                                    updateDeviceState(it, DeviceStatus.Paired)
                                    connectToDevice(it)
                                }
                                BluetoothDevice.BOND_NONE -> {
                                    LoggingReDrive.logMessage("Сопряжение удалено с ${it.name}")
                                    updateDeviceState(it, DeviceStatus.Failed)
                                }
                            }
                        }
                    }
                    BluetoothHeadset.ACTION_CONNECTION_STATE_CHANGED,
                    BluetoothA2dp.ACTION_CONNECTION_STATE_CHANGED,
                    -> {
                        val device = intent.getParcelableExtra<BluetoothDevice>(BluetoothDevice.EXTRA_DEVICE)
                        val state = intent.getIntExtra(BluetoothProfile.EXTRA_STATE, -1)
                        device?.let {
                            LoggingReDrive.logMessage(" ")
                            LoggingReDrive.logMessage("ACTION_CONNECTION_STATE_CHANGED")
                            LoggingReDrive.logMessage("Profile connection state changed for ${it.name} to $state")
                            LoggingReDrive.logMessage("Device auto connecting launch2")
                            LoggingReDrive.logMessage(" ")
                            if (state == BluetoothProfile.STATE_CONNECTED) {
                                LoggingReDrive.logMessage("Device connected: ${it.name}")
                                updateDeviceState(it, DeviceStatus.Connected)
                                _connectedDevice.value = it
                                if (isObd2Device(it)) {
                                    connectToObd2Device(it)
                                }
                            } else if (state == BluetoothProfile.STATE_DISCONNECTED) {
                                LoggingReDrive.logMessage(" ")
                                LoggingReDrive.logMessage("STATE_DISCONNECTED")
                                LoggingReDrive.logMessage("Device disconnected: ${it.name}")
                                LoggingReDrive.logMessage(" ")
                                updateDeviceState(it, DeviceStatus.Idle)
                                _connectedDevice.value = null
                                if (_isDemoMode.value != true) {
                                    _connectedDevice.value?.let { device ->
                                        if (isObd2Device(device)) {
                                            LoggingReDrive.logMessage("Device disconnected lvl2, OBD2 data reset to 0")
                                            Toast.makeText(context, "Соединение потеряно lvl2", Toast.LENGTH_SHORT).show()
                                            _obd2Data.value = Obd2Data(rpm = 0, speed = 0, engineTemp = 0)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

    private fun registerReceiver() {
        IntentFilter()
            .apply {
                addAction(BluetoothAdapter.ACTION_STATE_CHANGED)
                addAction(BluetoothDevice.ACTION_FOUND)
                addAction(BluetoothAdapter.ACTION_DISCOVERY_FINISHED)
                addAction(BluetoothDevice.ACTION_BOND_STATE_CHANGED)
                addAction(BluetoothHeadset.ACTION_CONNECTION_STATE_CHANGED)
                addAction(BluetoothA2dp.ACTION_CONNECTION_STATE_CHANGED)
            }.also {
                context.registerReceiver(receiver, it)
            }
    }

    init {
        registerReceiver()
        checkConnectedDevices()
    }

    fun startDiscovery() {
        bluetoothAdapter?.takeIf { it.isEnabled }?.let {
            if (ContextCompat.checkSelfPermission(context, android.Manifest.permission.BLUETOOTH_SCAN) ==
                PackageManager.PERMISSION_GRANTED
            ) {
                if (it.isDiscovering) {
                    _isDiscovering.value = true
                    return
                }
                deviceMap.clear()
                _deviceStates.value = emptyMap()
                it.startDiscovery().also { started ->
                    _isDiscovering.value = started || it.isDiscovering
                }
            }
        }
    }

    fun connectToDevice(device: BluetoothDevice) {
        LoggingReDrive.logMessage("Attempting to connect to device: ${device.name} (${device.address})")
        if (isObd2Device(device)) {
            LoggingReDrive.logMessage("Device identified as OBD2, connecting directly")
            connectToObd2Device(device)
            return
        }
        val addr = device.address
        LoggingReDrive.logMessage("Cancelling previous job for device: $addr, if exists")
        deviceJobs[addr]?.cancel()
        val job =
            viewModelScope.launch {
                LoggingReDrive.logMessage("Connection coroutine launched for device: ${device.name}")
                _connectedDevice.value?.let {
                    if (it.address != addr) {
                        LoggingReDrive.logMessage("Disconnecting previous device: ${it.name}")
                        disconnectDevice(it)
                        delay(1000)
                        LoggingReDrive.logMessage("Disconnected previous device and delayed for 1 second")
                    }
                }
                updateDeviceState(device, DeviceStatus.Pairing)
                LoggingReDrive.logMessage("Set device status to Pairing")
                try {
                    withTimeout(15000) {
                        LoggingReDrive.logMessage("Starting connection with 15s timeout")
                        if (ContextCompat.checkSelfPermission(context, android.Manifest.permission.BLUETOOTH_CONNECT) ==
                            PackageManager.PERMISSION_GRANTED
                        ) {
                            LoggingReDrive.logMessage("BLUETOOTH_CONNECT permission granted")
                            if (device.bondState == BluetoothDevice.BOND_NONE) {
                                LoggingReDrive.logMessage("Creating bond with device: ${device.name}")
                                device.createBond()
                            } else {
                                LoggingReDrive.logMessage("Device already bonded, proceeding to connect")
                                updateDeviceState(device, DeviceStatus.Paired)
                                connectToProfile(device)
                            }
                        } else {
                            LoggingReDrive.logMessage("BLUETOOTH_CONNECT permission not granted")
                        }
                    }
                } catch (e: TimeoutCancellationException) {
                    LoggingReDrive.logMessage("Connection timed out for device: ${device.name}")
                    updateDeviceState(device, DeviceStatus.Failed)
                } catch (e: Exception) {
                    LoggingReDrive.logMessage("Connection failed for device: ${device.name}, error: ${e.message}")
                    updateDeviceState(device, DeviceStatus.Failed)
                }
            }
        deviceJobs[addr] = job
        LoggingReDrive.logMessage("Started connection job for device: $addr")
    }

    private fun isObd2Device(device: BluetoothDevice): Boolean {
        LoggingReDrive.logMessage("это OBD DEVICE??: ${device.name}")
        return device.name?.lowercase()?.let {
            val isObd2 = it.contains("obd") || it.contains("elm") || it.contains("unreallx")
            LoggingReDrive.logMessage("ДААА ${device.name} is OBD2: $isObd2")
            isObd2
        } == true
    }

    private fun connectToObd2Device(device: BluetoothDevice) {
        val addr = device.address
        LoggingReDrive.logMessage("Connecting to OBD2 device: ${device.name} addr($addr)")
        if (_connectedDevice.value?.address == addr) {
            LoggingReDrive.logMessage("Уйстровство ${device.name} конектед уже")
            return
        }
        LoggingReDrive.logMessage("Cancelling previous job for OBD2 device: $addr, if exists")
        deviceJobs[addr]?.cancel()
        val job =
            viewModelScope.launch(Dispatchers.IO) {
                LoggingReDrive.logMessage("OBD2 connection coroutine launched for ${device.name}")
                try {
                    updateDeviceState(device, DeviceStatus.Connecting)
                    LoggingReDrive.logMessage("Set OBD2 device status to Connecting")
                    val socket = device.createRfcommSocketToServiceRecord(obd2UUID)
                    LoggingReDrive.logMessage("Created RFCOMM socket for ${device.name}")
                    bluetoothAdapter?.cancelDiscovery()
                    LoggingReDrive.logMessage("Cancelled discovery for OBD2 connection")
                    socket.connect()
                    LoggingReDrive.logMessage("Socket connected to ${device.name}")
                    val input = socket.inputStream
                    val output = socket.outputStream
                    LoggingReDrive.logMessage("Initialized input/output streams for ${device.name}")
                    listOf("ATZ", "ATE0", "ATL0", "ATH0", "ATSP0").forEach {
                        sendObdCommand(it, output)
                        val response = readObdResponse(input)
                        LoggingReDrive.logMessage("Init Command: $it, Response: $response")
                        if (it != "ATZ" && !response.contains("OK")) {
                            LoggingReDrive.logMessage("Warning: Command $it did not return OK")
                            delay(300)
                        }
                    }
                    updateDeviceState(device, DeviceStatus.Connected)
                    _connectedDevice.value = device
                    LoggingReDrive.logMessage("OBD2 device connected: ${device.name}")
                    while (isActive) {
                        if (_isDemoMode.value == true) {
                            LoggingReDrive.logMessage("Demo mode enabled, resetting OBD2 data")
                            _obd2Data.value = Obd2Data(rpm = 0, speed = 0, engineTemp = 0)
                            _isDemoMode.value = false
                            demoJob?.cancel()
                            LoggingReDrive.logMessage("Demo mode disabled from OBD2 loop")
                        }
                        val prev = _obd2Data.value
                        LoggingReDrive.logMessage("Reading OBD2 values for ${device.name}")
                        val rpm = readObdValue("010C", input, output) ?: prev.rpm
                        val speed = readObdValue("010D", input, output) ?: prev.speed
                        val temp = readObdValue("0105", input, output) ?: prev.engineTemp
                        _obd2Data.value = Obd2Data(rpm, speed, temp)
                        LoggingReDrive.logDataOBD2(rpm, speed, temp)
                        delay(100)
                    }
                } catch (e: IOException) {
                    LoggingReDrive.logMessage("OBD2 connection error: ${e.message}")
                    updateDeviceState(device, DeviceStatus.Failed)
                    LoggingReDrive.logMessage("obd value connect to odb2 device")
                    LoggingReDrive.logMessage("OBD2 connection failed for device: ${device.name}")
                    if (_isDemoMode.value != true) {
                        LoggingReDrive.logMessage("Device disconnected lvl4, OBD2 data reset to 0")
                        if (isObd2Device(device)) {
                            viewModelScope.launch(Dispatchers.Main) {
                                Toast
                                    .makeText(context, "Соединение потеряно lvl4", Toast.LENGTH_SHORT)
                                    .show()
                            }
                        }
                        _obd2Data.value = Obd2Data(rpm = 0, speed = 0, engineTemp = 0)
                    }
                }
            }
        deviceJobs[addr] = job
        LoggingReDrive.logMessage("Started OBD2 connection job for device: $addr")
    }

    private fun sendObdCommand(
        cmd: String,
        outputStream: OutputStream,
    ) {
        LoggingReDrive.logMessage("Sending OBD command: $cmd")
        outputStream.write((cmd + "\r").toByteArray())
        outputStream.flush()
        LoggingReDrive.logMessage("Command sent: $cmd")
    }

    private fun readObdResponse(inputStream: InputStream): String {
        LoggingReDrive.logMessage("Reading OBD response")
        val buf = ByteArray(1024)
        val sb = StringBuilder()
        val stop = System.currentTimeMillis() + 500
        while (System.currentTimeMillis() < stop) {
            if (inputStream.available() > 0) {
                val len = inputStream.read(buf)
                val chunk = String(buf, 0, len)
                sb.append(chunk)
                if (chunk.contains(">")) break
            } else {
                Thread.sleep(50)
            }
        }
        val response =
            sb
                .toString()
                .replace("\r", "")
                .replace("\n", " ")
                .replace(">", "")
                .trim()
        LoggingReDrive.logMessage("Read response: $response")
        return response
    }

    private fun readObdValue(
        cmd: String,
        input: InputStream,
        output: OutputStream,
    ): Int? {
        LoggingReDrive.logMessage("Reading OBD value for command: $cmd")
        sendObdCommand(cmd, output)
        val raw = readObdResponse(input)
        LoggingReDrive.logMessage("Command: $cmd, Raw Response: $raw")
        if (raw.contains("NO DATA") || raw.contains("ERROR")) {
            LoggingReDrive.logMessage("Error response for $cmd: $raw")
            return null
        }
        val parts = raw.split(" ").filter { it.matches(Regex("[0-9A-Fa-f]{2}")) }
        return try {
            when (cmd) {
                "010C" ->
                    if (parts.size >= 4 && parts[0] == "41" && parts[1] == "0C") {
                        ((parts[2].toInt(16) * 256 + parts[3].toInt(16)) / 4)
                    } else {
                        null
                    }
                "010D" ->
                    if (parts.size >= 3 && parts[0] == "41" && parts[1] == "0D") {
                        parts[2].toInt(16)
                    } else {
                        null
                    }
                "0105" ->
                    if (parts.size >= 3 && parts[0] == "41" && parts[1] == "05") {
                        parts[2].toInt(16) - 40
                    } else {
                        null
                    }
                else -> null
            }
        } catch (e: Exception) {
            LoggingReDrive.logMessage("Exception parsing response for $cmd: ${e.message}")
            null
        }.also { value ->
            LoggingReDrive.logMessage("Parsed Value for $cmd: $value")
        }
    }

    private fun connectToProfile(device: BluetoothDevice) {
        LoggingReDrive.logMessage("Connecting to profile for device: ${device.name}")
        updateDeviceState(device, DeviceStatus.Connecting)
        LoggingReDrive.logMessage("Set device status to Connecting")
        deviceJobs[device.address]?.cancel()
        LoggingReDrive.logMessage("Cancelled previous job for device: ${device.address}")
        val timeoutJob =
            viewModelScope.launch {
                LoggingReDrive.logMessage("Started timeout job for profile connection")
                delay(15000)
                _deviceStates.value[device.address]
                    ?.status
                    ?.takeIf { it == DeviceStatus.Connecting }
                    ?.let {
                        LoggingReDrive.logMessage("Connection timeout reached for ${device.name}")
                        updateDeviceState(device, DeviceStatus.Failed)
                    }
            }
        deviceJobs[device.address] = timeoutJob
        val serviceListener =
            object : BluetoothProfile.ServiceListener {
                override fun onServiceConnected(
                    profile: Int,
                    proxy: BluetoothProfile?,
                ) {
                    LoggingReDrive.logMessage("Service connected for profile $profile")
                    proxy
                        ?.javaClass
                        ?.getMethod("connect", BluetoothDevice::class.java)
                        ?.invoke(proxy, device)
                    LoggingReDrive.logMessage("Profile $profile connected to ${device.name}")
                }

                override fun onServiceDisconnected(profile: Int) {
                    LoggingReDrive.logMessage("Service disconnected for profile $profile")
                }
            }
        bluetoothAdapter?.getProfileProxy(context, serviceListener, BluetoothProfile.HEADSET)
        bluetoothAdapter?.getProfileProxy(context, serviceListener, BluetoothProfile.A2DP)
        LoggingReDrive.logMessage("Requested profile proxies for HEADSET and A2DP")
    }

    private fun disconnectDevice(device: BluetoothDevice) {
        LoggingReDrive.logMessage("Disconnecting device: ${device.name} (${device.address})")
        listOf(BluetoothProfile.A2DP, BluetoothProfile.HEADSET).forEach { profile ->
            bluetoothAdapter?.getProfileProxy(
                context,
                object : BluetoothProfile.ServiceListener {
                    override fun onServiceConnected(
                        p: Int,
                        proxy: BluetoothProfile?,
                    ) {
                        LoggingReDrive.logMessage("Service connected for disconnect, profile $p")
                        proxy
                            ?.javaClass
                            ?.getMethod("disconnect", BluetoothDevice::class.java)
                            ?.invoke(proxy, device)
                        LoggingReDrive.logMessage("Disconnected profile $p for device: ${device.name}")
                        viewModelScope.launch {
                            delay(500)
                            if (device.bondState == BluetoothDevice.BOND_BONDED) {
                                LoggingReDrive.logMessage("Removing bond for device: ${device.name}")
                                device.javaClass.getMethod("removeBond").invoke(device)
                                LoggingReDrive.logMessage("Bond removed for device: ${device.name}")
                            }
                        }
                    }

                    override fun onServiceDisconnected(p: Int) {
                        LoggingReDrive.logMessage("Service disconnected for profile $p during disconnect")
                    }
                },
                profile,
            )
        }
        if (_isDemoMode.value != true) {
            _connectedDevice.value?.let { device ->
                if (isObd2Device(device)) {
                    LoggingReDrive.logMessage("Device disconnected lvl5, OBD2 data reset to 0")
                    Toast.makeText(context, "Соединение потеряно lvl5", Toast.LENGTH_SHORT).show()
                    _obd2Data.value = Obd2Data(rpm = 0, speed = 0, engineTemp = 0)
                }
            }
        }
    }

    fun checkConnectedDevices() {
        LoggingReDrive.logMessage("Checking connected devices")
        if (ContextCompat.checkSelfPermission(context, android.Manifest.permission.BLUETOOTH_CONNECT) !=
            PackageManager.PERMISSION_GRANTED
        ) {
            LoggingReDrive.logMessage("BLUETOOTH_CONNECT permission not granted, skipping check")
            return
        }
        LoggingReDrive.logMessage("BLUETOOTH_CONNECT permission granted, proceeding with check")
        listOf(BluetoothProfile.HEADSET, BluetoothProfile.A2DP).forEach { profile ->
            bluetoothAdapter?.getProfileProxy(
                context,
                object : BluetoothProfile.ServiceListener {
                    override fun onServiceConnected(
                        p: Int,
                        proxy: BluetoothProfile?,
                    ) {
                        LoggingReDrive.logMessage("Service connected for profile $p during check")
                        proxy?.connectedDevices?.forEach { device ->
                            LoggingReDrive.logMessage("launch 3 connection complete init is true ue")
                            LoggingReDrive.logMessage("Found connected device: ${device.name} (${device.address})")
                            updateDeviceState(device, DeviceStatus.Connected)
                            _connectedDevice.value = device
                            if (isObd2Device(device)) {
                                LoggingReDrive.logMessage("Auto-connecting to OBD2 device: ${device.name}")
                                connectToObd2Device(device)
                            }
                        }
                    }

                    override fun onServiceDisconnected(p: Int) {
                        LoggingReDrive.logMessage("Service disconnected for profile $p during check")
                    }
                },
                profile,
            )
        }

        bluetoothAdapter?.bondedDevices?.forEach { device ->
            LoggingReDrive.logMessage("Checking bonded device: ${device.name} (${device.address})")
            if (isObd2Device(device)) {
                LoggingReDrive.logMessage("launch 4 connection complete init is true ue")
                LoggingReDrive.logMessage("Found bonded OBD2 device: ${device.name}, attempting to connect")
                connectToObd2Device(device)
            }
        }
    }

    private fun updateDeviceState(
        device: BluetoothDevice,
        status: DeviceStatus,
    ) {
        LoggingReDrive.logMessage("Updating device state for ${device.name} to $status")
        deviceMap[device.address] = device
        _deviceStates.update { it + (device.address to BluetoothDeviceUiState(device, status)) }
        LoggingReDrive.logMessage("Device state updated: ${device.name} (${device.address}) to $status")
    }

    fun clearDevices() {
        LoggingReDrive.logMessage("Clearing all devices and states")
        _deviceStates.value = emptyMap()
        _connectedDevice.value = null
        deviceMap.clear()
        LoggingReDrive.logMessage("All devices and states cleared")
    }

    override fun onCleared() {
        LoggingReDrive.logMessage("BluetoothViewModel cleared")
        super.onCleared()
        bluetoothAdapter?.cancelDiscovery()
        LoggingReDrive.logMessage("Discovery cancelled")
        _isDiscovering.value = false
        context.unregisterReceiver(receiver)
        LoggingReDrive.logMessage("BroadcastReceiver unregistered")
    }

    private var hasStartedDiscovery = false

    fun startDiscoveryOnce() {
        LoggingReDrive.logMessage("Attempting to start discovery once, hasStartedDiscovery: $hasStartedDiscovery")
        if (!hasStartedDiscovery) {
            hasStartedDiscovery = true
            LoggingReDrive.logMessage("Starting discovery once")
            startDiscovery()
        } else {
            LoggingReDrive.logMessage("Discovery already started once, skipping")
        }
    }
}
