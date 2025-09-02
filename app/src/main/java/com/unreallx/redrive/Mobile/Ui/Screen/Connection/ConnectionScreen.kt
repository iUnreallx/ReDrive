package com.unreallx.redrive.Mobile.Ui.Screen.Connection

import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.provider.Settings
import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.animateContentSize
import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.FastOutLinearInEasing
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.LinearOutSlowInEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.material3.ripple
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.key
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.zIndex
import androidx.navigation.NavHostController
import com.unreallx.redrive.Utils.Permissions.BluetoothPermissionHandler
import com.unreallx.redrive.R
import com.unreallx.redrive.Utils.BluetoothViewModel
import com.unreallx.redrive.Utils.CustomRippleBox
import com.unreallx.redrive.Utils.DeviceStatus
import com.unreallx.redrive.Utils.States.SharedState
import com.unreallx.redrive.Utils.WifiViewModel
import com.unreallx.redrive.Utils.fixedSp
import com.unreallx.redrive.ui.theme.ReDriveColors


data class FakeDeviceState(
    val device: FakeBluetoothDevice,
    val status: DeviceStatus
)

data class FakeBluetoothDevice(
    val name: String?,
    val address: String
)

enum class DeviceStatus {
    Idle, Pairing, Connecting, Connected, Failed
}


@Composable
fun connectionScreenUI(
    navController: NavHostController,
    viewModel: BluetoothViewModel,
    wifiViewModel: WifiViewModel
) {
    val context = LocalContext.current
    val activity = context as? Activity

    var permissionsGranted by rememberSaveable { mutableStateOf(false) }
    var isToggledBluetooth by rememberSaveable { mutableStateOf(false) }

    LaunchedEffect(permissionsGranted) {
        if (permissionsGranted) {
            viewModel.startDiscoveryOnce()
            val bluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
            isToggledBluetooth = bluetoothAdapter?.isEnabled == true
        }
    }

    if (permissionsGranted) {
        DisposableEffect(Unit) {
            val filter = IntentFilter(BluetoothAdapter.ACTION_STATE_CHANGED)
            val receiver = object : BroadcastReceiver() {
                override fun onReceive(context: Context, intent: Intent) {
                    if (intent.action == BluetoothAdapter.ACTION_STATE_CHANGED) {
                        val state = intent.getIntExtra(BluetoothAdapter.EXTRA_STATE, BluetoothAdapter.ERROR)
                        isToggledBluetooth = state == BluetoothAdapter.STATE_ON
                        viewModel.startDiscovery()
                    }
                }
            }
            context.registerReceiver(receiver, filter)
            onDispose {
                context.unregisterReceiver(receiver)
            }
        }
    }

    val animatedPadding = remember { Animatable(if (isToggledBluetooth) 8f else 30f) }
    val backgroundColor by animateColorAsState(
        targetValue = if (isToggledBluetooth) ReDriveColors.AccentAppColor else Color.White
    )
    val circleSizeAnimation by animateDpAsState(
        targetValue = if (isToggledBluetooth) 28.dp else 25.dp
    )

    BluetoothPermissionHandler(
        onPermissionsGranted = {
            permissionsGranted = true
        }
    ) {
        Box(
            Modifier.fillMaxSize()
        ) {
            Text(
                text = "Подключение",
                fontSize = fixedSp(30),
                fontWeight = FontWeight.Bold,
                color = Color.White,
                modifier = Modifier
                    .align(Alignment.TopStart)
                    .offset(x = 35.dp),
            )

            Box(
                modifier = Modifier
                    .height(35.dp)
                    .width(6.dp)
                    .offset(x = 19.dp)
                    .clip(RoundedCornerShape(16.dp))
                    .background(ReDriveColors.AccentAppColor)
                    .align(Alignment.TopStart)
            )



            Box(
                modifier = Modifier
                    .fillMaxHeight()
                    .fillMaxWidth()
                    .padding(bottom = 115.dp - SharedState.offsetY)
                    .offset(y = 40.dp)
                    .clip(RoundedCornerShape(25.dp))
                    .background(ReDriveColors.ConnectionBackground)
                    .align(Alignment.TopCenter)
            ) {
                val scrollState = rememberScrollState()

                Column(
                    modifier = Modifier
                        .fillMaxSize()
                        .verticalScroll(scrollState)
                        .padding(horizontal = 3.dp, vertical = 3.dp)
                ) {
                    var hasLaunchedBluetooth by remember { mutableStateOf(false) }
                    // Bluetooth Toggle
                    CustomRippleBox(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(70.dp)
                            .offset(y = 10.dp)
                            .padding(horizontal = 10.dp)
                            .border(2.dp, Color(0xFF4178F6), RoundedCornerShape(20.dp))
                            .clip(RoundedCornerShape(20.dp))
                            .background(ReDriveColors.BackgroundToMain)
                            .zIndex(1f),
                        onClick = {
                            val bluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
                            if (bluetoothAdapter != null) {
                                if (isToggledBluetooth) {
                                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                                        val intent = Intent(Settings.ACTION_BLUETOOTH_SETTINGS)
                                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                        context.startActivity(intent)
                                    } else {
                                        bluetoothAdapter.disable()
                                    }
                                } else {
                                    val enableBtIntent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
                                    enableBtIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                    context.startActivity(enableBtIntent)
                                }
                            }
                        }

                    ) {
                    Box(modifier = Modifier.fillMaxSize()) {
                        Image(
                            painter = painterResource(id = R.drawable.bluetooth),
                            contentDescription = null,
                            contentScale = ContentScale.Fit,
                            modifier = Modifier
                                .padding(start = 10.dp)
                                .size(40.dp)
                                .align(Alignment.CenterStart)
                                .zIndex(1f)
                        )
                        Text(
                            text = "Bluetooth",
                            fontSize = fixedSp(25),
                            fontWeight = FontWeight.Bold,
                            color = ReDriveColors.AccentAppColor,
                            modifier = Modifier
                                .padding(start = 50.dp)
                                .align(Alignment.CenterStart)
                        )


                        LaunchedEffect(isToggledBluetooth) {
                            if (hasLaunchedBluetooth) {
                                val target = if (isToggledBluetooth) 8f else 30f
                                val overshoot = if (isToggledBluetooth) target - 6f else target + 6f
                                animatedPadding.animateTo(
                                    overshoot,
                                    animationSpec = tween(
                                        durationMillis = 170,
                                        easing = FastOutLinearInEasing
                                    )
                                )
                                animatedPadding.animateTo(
                                    target,
                                    animationSpec = tween(
                                        durationMillis = 170,
                                        easing = LinearOutSlowInEasing
                                    )
                                )
                            } else {
                                animatedPadding.snapTo(if (isToggledBluetooth) 8f else 30f)
                                hasLaunchedBluetooth = true
                            }
                        }

                        Box(
                            Modifier
                                .fillMaxSize()
                                .align(Alignment.CenterEnd)
                                .offset(x = 0.dp)
                        ) {
                            Box(
                                Modifier
                                    .padding(end = 15.dp)
                                    .align(Alignment.CenterEnd)
                                    .border(
                                        2.dp,
                                        ReDriveColors.AccentAppColor,
                                        RoundedCornerShape(30.dp)
                                    )
                                    .width(65.dp)
                                    .clip(RoundedCornerShape(30.dp))
                                    .height(40.dp)
                            ) {
                                Box(
                                    Modifier
                                        .padding(end = animatedPadding.value.dp)
                                        .align(Alignment.CenterEnd)
                                        .size(circleSizeAnimation)
                                        .background(backgroundColor, CircleShape)
                                        .clip(CircleShape)
                                )
                            }
                        }
                    }
                }
                // LIST BLUETOOTH DEVICES
//                    val deviceStates by viewModel.deviceStates.collectAsState()
//                    val connectedDevice by viewModel.connectedDevice.collectAsState()
//
//                    val devicesList = remember(deviceStates) {
//                        deviceStates.values.sortedBy { it.device.name ?: "" }
//                    }
//
//
//                    Column(
//                        modifier = Modifier
//                            .fillMaxWidth()
//                            .padding(top = 0.dp, start = 8.dp, end = 8.dp, bottom = 0.dp)
//                            .offset(y = (-8).dp)
//                            .clip(RoundedCornerShape(12.dp))
//                            .background(ReDriveColors.BackgroundToMain)
//                            .animateContentSize(animationSpec = tween(durationMillis = 300))
//                    ) {
//                        if (isToggledBluetooth) {
//                            Column(
//                                modifier = Modifier
//                                    .padding(top = 26.dp, start = 0.dp)
//                                    .zIndex(0f)
//                            ) {
//                                Row(
//                                    modifier = Modifier
//                                        .fillMaxWidth()
//                                        .padding(horizontal = 10.dp, vertical = 0.dp)
//                                        .offset(y=-1.dp),
//                                    verticalAlignment = Alignment.CenterVertically
//                                ) {
//                                    Text(
//                                        text = "Доступные устройства",
//                                        color = Color.White,
//                                        fontWeight = FontWeight.SemiBold,
//
//                                        fontSize = fixedSp(25),
//                                        modifier = Modifier.weight(1.1f)
//                                    )
//
//                                    val isDiscovering by viewModel.isDiscovering.collectAsState()
//                                    val interactionSource = remember { MutableInteractionSource() }
//
//                                    val infiniteTransition = rememberInfiniteTransition(label = "rotate")
//                                    val rotation by infiniteTransition.animateFloat(
//                                        initialValue = 0f,
//                                        targetValue = 360f,
//                                        animationSpec = infiniteRepeatable(
//                                            animation = tween(1000, easing = LinearEasing),
//                                            repeatMode = RepeatMode.Restart
//                                        ),
//                                        label = "rotate"
//                                    )
//
//                                    Box(
//                                        modifier = Modifier
//                                            .size(40.dp)
//                                            .padding(bottom = 4.dp)
//                                            .offset(x = 10.dp)
//                                            .clip(RoundedCornerShape(50.dp))
//                                            .clickable(
//                                                interactionSource = interactionSource,
//                                                indication = ripple(color = Color.White, bounded = true),
//                                                enabled = !isDiscovering
//                                            ) {
//                                                viewModel.startDiscovery()
//                                            },
//                                        contentAlignment = Alignment.Center
//                                    ) {
//                                        Image(
//                                                painter = painterResource(id = R.drawable.reload),
//                                            contentDescription = null,
//                                            contentScale = ContentScale.Fit,
//                                            modifier = Modifier
//                                                .size(30.dp)
//                                                .graphicsLayer {
//                                                    rotationZ = if (isDiscovering) rotation else 0f
//                                                }
//                                            )
//                                        }
//                                    }
//
//
//
//                                connectedDevice?.let { device ->
//                                    val deviceState = deviceStates[device.address]
//                                    CustomRippleBox(
//                                        modifier = Modifier
//                                            .fillMaxWidth()
//                                            .height(35.dp)
//                                            .zIndex(1f),
//                                        onClick = {  }
//                                    ) {
//                                        Row(
//                                            verticalAlignment = Alignment.CenterVertically,
//                                            modifier = Modifier
//                                                .fillMaxSize()
//                                                .padding(horizontal = 10.dp)
//                                        ) {
//                                            val displayName = device.name?.let {
//                                                if (it.length > 22) it.take(22) + "..." else it
//                                            } ?: "Unknown Device"
//
//                                            Text(
//                                                text = displayName,
//                                                color = ReDriveColors.AccentAppColor,
//                                                fontWeight = FontWeight.Bold,
//                                                fontSize = 24.sp,
//                                                maxLines = 1,
//                                                overflow = TextOverflow.Ellipsis,
//                                                modifier = Modifier
//                                                    .weight(1f)
//                                            )
//
//                                            Box(
//                                                modifier = Modifier
//                                                    .padding(start = 6.dp)
//                                                    .size(10.dp)
//                                                    .background(
//                                                        Color.Green,
//                                                        shape = CircleShape
//                                                    )
//                                            )
//
//                                            when (deviceState?.status) {
//                                                DeviceStatus.Pairing,
//                                                DeviceStatus.Connecting -> {
//                                                    Spacer(modifier = Modifier.width(8.dp))
//                                                    CircularProgressIndicator(
//                                                        color = ReDriveColors.AccentAppColor,
//                                                        strokeWidth = 2.dp,
//                                                        modifier = Modifier.size(16.dp)
//                                                    )
//                                                }
//                                                DeviceStatus.Failed -> {
//                                                    Spacer(modifier = Modifier.width(8.dp))
//                                                    Text(
//                                                        text = "Ошибка",
//                                                        color = Color.Red,
//                                                        fontSize = fixedSp(18)
//                                                    )
//                                                }
//                                                else -> {}
//                                            }
//                                        }
//                                    }
//                                }
//
//                                val availableDevices = devicesList.filter { it.device.address != connectedDevice?.address }
//
//                                if (availableDevices.isEmpty() && connectedDevice == null) {
//                                    Text(
//                                        text = "Устройства не найдены",
//                                        color = Color.Gray,
//                                        fontSize = fixedSp(22),
//                                        modifier = Modifier.padding(bottom = 10.dp, start = 10.dp)
//                                    )
//                                } else {
//                                    availableDevices.forEach { state ->
//                                        key(state.device.address) {
//                                            val device = state.device
//                                            val status = state.status
//
//                                            CustomRippleBox(
//                                                modifier = Modifier
//                                                    .fillMaxWidth()
//                                                    .height(35.dp)
//                                                    .zIndex(1f),
//                                                onClick = {
//                                                    if (status == DeviceStatus.Idle || status == DeviceStatus.Failed) {
//                                                        viewModel.connectToDevice(device)
//                                                    }
//                                                }
//                                            ) {
//                                                Row(
//                                                    verticalAlignment = Alignment.CenterVertically,
//                                                    modifier = Modifier
//                                                        .fillMaxSize()
//                                                        .padding(start = 10.dp, end = 10.dp, bottom = 2.dp)
//                                                ) {
//                                                    val displayName = device.name?.let {
//                                                        if (it.length > 22) it.take(22) + "..." else it
//                                                    } ?: "Unknown Device"
//
//                                                    Text(
//                                                        text = displayName,
//                                                        color = Color.White,
//                                                        fontSize = fixedSp(22),
//                                                        maxLines = 1,
//                                                        overflow = TextOverflow.Ellipsis,
//                                                        modifier = Modifier.weight(1f)
//                                                    )
//
//                                                    when (status) {
//                                                        DeviceStatus.Pairing -> {
//                                                            Spacer(modifier = Modifier.width(8.dp))
//                                                            Text("Сопряжение", color = Color.Yellow, fontSize = fixedSp(18))
//                                                            CircularProgressIndicator(
//                                                                color = ReDriveColors.AccentAppColor,
//                                                                strokeWidth = 2.dp,
//                                                                modifier = Modifier
//                                                                    .size(16.dp)
//                                                                    .offset(x = 5.dp, y = 1.dp)
//                                                            )
//                                                        }
//                                                        DeviceStatus.Connecting -> {
//                                                            Spacer(modifier = Modifier.width(8.dp))
//                                                            Text("Подключение", color = Color.Cyan, fontSize = fixedSp(18))
//                                                            CircularProgressIndicator(
//                                                                color = ReDriveColors.AccentAppColor,
//                                                                strokeWidth = 2.dp,
//                                                                modifier = Modifier
//                                                                    .size(16.dp)
//                                                                    .offset(x = 5.dp, y = 1.dp)
//                                                            )
//                                                        }
//                                                        DeviceStatus.Connected -> {
//                                                            Spacer(modifier = Modifier.width(8.dp))
//                                                            Box(
//                                                                modifier = Modifier
//                                                                    .size(10.dp)
//                                                                    .background(Color.Green, shape = CircleShape)
//                                                                    .offset(y=1.dp)
//                                                            )
//                                                        }
//                                                        DeviceStatus.Failed -> {
//                                                            Spacer(modifier = Modifier.width(8.dp))
//                                                            Box(
//                                                                modifier = Modifier
//                                                                    .size(10.dp)
//                                                                    .background(Color.Red, shape = CircleShape)
//                                                            )
//                                                        }
//                                                        else -> {
//                                                            Box(
//                                                                modifier = Modifier
//                                                                    .size(10.dp)
//                                                                    .background(Color.Red, shape = CircleShape)
//                                                            )
//                                                        }
//                                                    }
//                                                }
//                                            }
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    }


                    val fakeConnectedDevice: FakeBluetoothDevice? = null

                    val fakeDeviceData = listOf(
                        "00:11:22:33:44:01" to "Fake Device 1" to DeviceStatus.Connected,
                        "00:11:22:33:44:02" to "Fake Device 2" to DeviceStatus.Idle,
                        "00:11:22:33:44:03" to "Fake Device 3" to DeviceStatus.Pairing,
                        "00:11:22:33:44:04" to "Fake Device 4" to DeviceStatus.Connecting,
                        "00:11:22:33:44:05" to "Fake Device 5" to DeviceStatus.Failed,
                        "00:11:22:33:44:06" to "Fake Device 6" to DeviceStatus.Idle,
                        "00:11:22:33:44:07" to "Fake Device 7" to DeviceStatus.Idle,
                        "00:11:22:33:44:08" to "Fake Device 8" to DeviceStatus.Idle,
                        "00:11:22:33:44:09" to "Fake Device 9" to DeviceStatus.Idle,
                        "00:11:22:33:44:10" to "Fake Device 10" to DeviceStatus.Idle
                    )

                    val fakeDeviceStates = remember {
                        (1..30).associate { i ->
                            val address = "00:11:22:33:44:${"%02d".format(i)}"
                            val name = "Fake Device $i"
                            val status = when (i) {
                                1 -> DeviceStatus.Connected
                                3 -> DeviceStatus.Pairing
                                4 -> DeviceStatus.Connecting
                                5 -> DeviceStatus.Failed
                                else -> DeviceStatus.Idle
                            }
                            address to FakeDeviceState(
                                FakeBluetoothDevice(name, address),
                                status
                            )
                        }
                    }

                    val fakeDevicesList = remember(fakeDeviceStates) {
                        fakeDeviceStates.values.sortedBy { it.device.name ?: "" }
                    }

                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(top = 0.dp, start = 8.dp, end = 8.dp, bottom = 0.dp)
                            .offset(y = (-8).dp)
                            .clip(RoundedCornerShape(12.dp))
                            .background(ReDriveColors.BackgroundToMain)
                            .animateContentSize(animationSpec = tween(durationMillis = 300))
                    ) {
                        if (isToggledBluetooth) {
                            Column(
                                modifier = Modifier
                                    .padding(top = 26.dp, start = 0.dp)
                                    .zIndex(0f)
                            ) {
                                Row(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .padding(horizontal = 10.dp, vertical = 0.dp)
                                        .offset(y = -1.dp),
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    Text(
                                        text = "Доступные устройства",
                                        color = Color.White,
                                        fontWeight = FontWeight.SemiBold,
                                        fontSize = fixedSp(25),
                                        modifier = Modifier.weight(1.1f)
                                    )

                                    var isFakeDiscovering by remember { mutableStateOf(false) }
                                    val interactionSource = remember { MutableInteractionSource() }

                                    val infiniteTransition = rememberInfiniteTransition(label = "rotate")
                                    val rotation by infiniteTransition.animateFloat(
                                        initialValue = 0f,
                                        targetValue = 360f,
                                        animationSpec = infiniteRepeatable(
                                            animation = tween(1000, easing = LinearEasing),
                                            repeatMode = RepeatMode.Restart
                                        ),
                                        label = "rotate"
                                    )

                                    Box(
                                        modifier = Modifier
                                            .size(40.dp)
                                            .padding(bottom = 4.dp)
                                            .offset(x = 10.dp)
                                            .clip(RoundedCornerShape(50.dp))
                                            .clickable(
                                                interactionSource = interactionSource,
                                                indication = ripple(color = Color.White, bounded = true),
                                                enabled = !isFakeDiscovering
                                            ) {
                                                isFakeDiscovering = true
                                            },
                                        contentAlignment = Alignment.Center
                                    ) {
                                        Image(
                                            painter = painterResource(id = R.drawable.reload),
                                            contentDescription = null,
                                            contentScale = ContentScale.Fit,
                                            modifier = Modifier
                                                .size(30.dp)
                                                .graphicsLayer {
                                                    rotationZ = if (isFakeDiscovering) rotation else 0f
                                                }
                                        )
                                    }
                                }

                                fakeConnectedDevice?.let { device ->
                                    val deviceState = fakeDeviceStates[device.address]
                                    CustomRippleBox(
                                        modifier = Modifier
                                            .fillMaxWidth()
                                            .height(35.dp)
                                            .zIndex(1f),
                                        onClick = {  }
                                    ) {
                                        Row(
                                            verticalAlignment = Alignment.CenterVertically,
                                            modifier = Modifier
                                                .fillMaxSize()
                                                .padding(horizontal = 10.dp)
                                        ) {
                                            val displayName = device.name?.let {
                                                if (it.length > 22) it.take(22) + "..." else it
                                            } ?: "Unknown Device"

                                            Text(
                                                text = displayName,
                                                color = ReDriveColors.AccentAppColor,
                                                fontWeight = FontWeight.Bold,
                                                fontSize = 24.sp,
                                                maxLines = 1,
                                                overflow = TextOverflow.Ellipsis,
                                                modifier = Modifier
                                                    .weight(1f)
                                            )

                                            Box(
                                                modifier = Modifier
                                                    .padding(start = 6.dp)
                                                    .size(10.dp)
                                                    .background(
                                                        Color.Green,
                                                        shape = CircleShape
                                                    )
                                            )

                                            when (deviceState?.status) {
                                                DeviceStatus.Pairing,
                                                DeviceStatus.Connecting -> {
                                                    Spacer(modifier = Modifier.width(8.dp))
                                                    CircularProgressIndicator(
                                                        color = ReDriveColors.AccentAppColor,
                                                        strokeWidth = 2.dp,
                                                        modifier = Modifier.size(16.dp)
                                                    )
                                                }
                                                DeviceStatus.Failed -> {
                                                    Spacer(modifier = Modifier.width(8.dp))
                                                    Text(
                                                        text = "Ошибка",
                                                        color = Color.Red,
                                                        fontSize = fixedSp(18)
                                                    )
                                                }
                                                else -> {}
                                            }
                                        }
                                    }
                                }

                                val fakeAvailableDevices = fakeDevicesList.filter { it.device.address != fakeConnectedDevice?.address }

                                if (fakeAvailableDevices.isEmpty() && fakeConnectedDevice == null) {
                                    Text(
                                        text = "Устройства не найдены",
                                        color = Color.Gray,
                                        fontSize = fixedSp(22),
                                        modifier = Modifier.padding(bottom = 10.dp, start = 10.dp)
                                    )
                                } else {
                                    fakeAvailableDevices.forEach { state ->
                                        key(state.device.address) {
                                            val device = state.device
                                            val status = state.status

                                            CustomRippleBox(
                                                modifier = Modifier
                                                    .fillMaxWidth()
                                                    .height(35.dp)
                                                    .zIndex(1f),
                                                onClick = {
                                                    if (status == DeviceStatus.Idle || status == DeviceStatus.Failed) {
                                                    }
                                                }
                                            ) {
                                                Row(
                                                    verticalAlignment = Alignment.CenterVertically,
                                                    modifier = Modifier
                                                        .fillMaxSize()
                                                        .padding(start = 10.dp, end = 10.dp, bottom = 2.dp)
                                                ) {
                                                    val displayName = device.name?.let {
                                                        if (it.length > 22) it.take(22) + "..." else it
                                                    } ?: "Unknown Device"

                                                    Text(
                                                        text = displayName,
                                                        color = Color.White,
                                                        fontSize = fixedSp(22),
                                                        maxLines = 1,
                                                        overflow = TextOverflow.Ellipsis,
                                                        modifier = Modifier.weight(1f)
                                                    )

                                                    when (status) {
                                                        DeviceStatus.Pairing -> {
                                                            Spacer(modifier = Modifier.width(8.dp))
                                                            Text("Сопряжение", color = Color.Yellow, fontSize = fixedSp(18))
                                                            CircularProgressIndicator(
                                                                color = ReDriveColors.AccentAppColor,
                                                                strokeWidth = 2.dp,
                                                                modifier = Modifier
                                                                    .size(16.dp)
                                                                    .offset(x = 5.dp, y = 1.dp)
                                                            )
                                                        }
                                                        DeviceStatus.Connecting -> {
                                                            Spacer(modifier = Modifier.width(8.dp))
                                                            Text("Подключение", color = Color.Cyan, fontSize = fixedSp(18))
                                                            CircularProgressIndicator(
                                                                color = ReDriveColors.AccentAppColor,
                                                                strokeWidth = 2.dp,
                                                                modifier = Modifier
                                                                    .size(16.dp)
                                                                    .offset(x = 5.dp, y = 1.dp)
                                                            )
                                                        }
                                                        DeviceStatus.Connected -> {
                                                            Spacer(modifier = Modifier.width(8.dp))
                                                            Box(
                                                                modifier = Modifier
                                                                    .size(10.dp)
                                                                    .background(Color.Green, shape = CircleShape)
                                                                    .offset(y=1.dp)
                                                            )
                                                        }
                                                        DeviceStatus.Failed -> {
                                                            Spacer(modifier = Modifier.width(8.dp))
                                                            Box(
                                                                modifier = Modifier
                                                                    .size(10.dp)
                                                                    .background(Color.Red, shape = CircleShape)
                                                            )
                                                        }
                                                        else -> {
                                                            Box(
                                                                modifier = Modifier
                                                                    .size(10.dp)
                                                                    .background(Color.Red, shape = CircleShape)
                                                            )
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }


                    Spacer(modifier = Modifier.height(if (isToggledBluetooth) 4.dp else 24.dp))

//                    val isScanning by wifiViewModel.isScanning.collectAsState()
//                    val connectedNetwork by wifiViewModel.connectedNetwork.collectAsState()
//                    val wifiNetworks by wifiViewModel.wifiNetworks.collectAsState()
//                    val wifiManager = LocalContext.current.getSystemService(WifiManager::class.java)
//
//                    var isWifiEnabled by remember { mutableStateOf(wifiManager.isWifiEnabled) }
//
//                    LaunchedEffect(Unit) {
//                        while (true) {
//                            val current = wifiManager.isWifiEnabled
//                            if (current != isWifiEnabled) {
//                                isWifiEnabled = current
//                            }
//                            delay(1000)
//                        }
//                    }
//
//                    val animatedPaddingWifi = remember { Animatable(if (isWifiEnabled) 8f else 30f) }
//                    val backgroundColorWifi by animateColorAsState(
//                        targetValue = if (isWifiEnabled) ReDriveColors.AccentAppColor else Color.White
//                    )
//                    val circleSizeWifi by animateDpAsState(
//                        targetValue = if (isWifiEnabled) 28.dp else 25.dp
//                    )
//
//
//
////                    val scrollStateWifi = rememberScrollState()
//
//                    Column(
//                        modifier = Modifier
//                            .fillMaxSize()
////                            .verticalScroll(scrollStateWifi)
//                            .padding(horizontal = 3.dp, vertical = 3.dp)
//                    ) {
//                        CustomRippleBox(
//                            modifier = Modifier
//                                .fillMaxWidth()
//                                .height(70.dp)
//                                .padding(horizontal = 7.dp)
//                                .border(2.dp, Color(0xFF4178F6), RoundedCornerShape(20.dp))
//                                .clip(RoundedCornerShape(20.dp))
//                                .zIndex(1f)
//                                .background(ReDriveColors.BackgroundToMain),
//                            onClick = {
//                                wifiManager.isWifiEnabled = !isWifiEnabled
//                                isWifiEnabled = !isWifiEnabled
//                            }
//                        ) {
//                            Box(modifier = Modifier.fillMaxSize()
//                            ) {
//                                Image(
//                                    painter = painterResource(id = R.drawable.wifi),
//                                    contentDescription = null,
//                                    contentScale = ContentScale.Fit,
//                                    modifier = Modifier
//                                        .padding(start = 10.dp)
//                                        .size(40.dp)
//                                        .align(Alignment.CenterStart)
//                                )
//
//                                Text(
//                                    text = "Wi-Fi",
//                                    fontSize = fixedSp(25),
//                                    fontWeight = FontWeight.Bold,
//                                    color = ReDriveColors.AccentAppColor,
//                                    modifier = Modifier
//                                        .padding(start = 55.dp)
//                                        .align(Alignment.CenterStart)
//                                )
//
//                                LaunchedEffect(isWifiEnabled) {
//                                    val target = if (isWifiEnabled) 8f else 30f
//                                    val overshoot = if (isWifiEnabled) target - 6f else target + 6f
//                                    animatedPaddingWifi.animateTo(
//                                        overshoot,
//                                        animationSpec = tween(durationMillis = 170, easing = FastOutLinearInEasing)
//                                    )
//                                    animatedPaddingWifi.animateTo(
//                                        target,
//                                        animationSpec = tween(durationMillis = 170, easing = LinearOutSlowInEasing)
//                                    )
//                                }
//
////                                 Switch container
//                                Box(
//                                    modifier = Modifier
//                                        .align(Alignment.CenterEnd)
//                                        .padding(end = 15.dp)
//                                        .width(65.dp)
//                                        .height(40.dp)
//                                        .clip(RoundedCornerShape(30.dp))
//                                        .border(2.dp, ReDriveColors.AccentAppColor, RoundedCornerShape(30.dp))
//                                ) {
//                                    Box(
//                                        modifier = Modifier
//                                            .size(circleSizeWifi)
//                                            .offset(x = animatedPaddingWifi.value.dp)
//                                            .align(Alignment.CenterStart)
//                                            .background(backgroundColorWifi, CircleShape)
//                                    )
//                                }
//
//                        }
//
//                    }
//
//
//
//
//                        Column(
//                            modifier = Modifier
//                                .fillMaxWidth()
//                                .padding(top = 0.dp, start = 8.dp, end = 8.dp, bottom=8.dp)
////                                .offset(y = (-20).dp)
//                                .clip(RoundedCornerShape(12.dp))
//                                .background(ReDriveColors.BackgroundToMain)
//                                .animateContentSize(animationSpec = tween(durationMillis = 300))
//                        ) {
//                            if (isWifiEnabled) {
//                                Column(
//                                    modifier = Modifier
//                                        .padding(top = 5.dp, start = 0.dp)
//                                        .zIndex(0f)
//                                ) {
//                                    Row(
//                                        modifier = Modifier
//                                            .fillMaxWidth()
//                                            .padding(horizontal = 10.dp)
//                                            .offset(y = (-1).dp),
//                                        verticalAlignment = Alignment.CenterVertically
//                                    ) {
//                                        Text(
//                                            text = "Доступные Wi-Fi сети",
//                                            color = Color.White,
//                                            fontWeight = FontWeight.SemiBold,
//                                            fontSize = fixedSp(26),
//                                            modifier = Modifier.weight(1.1f)
//                                        )
//
//
//
//                                        val infiniteTransition = rememberInfiniteTransition(label = "rotate")
//                                        val rotation by infiniteTransition.animateFloat(
//                                            initialValue = 0f,
//                                            targetValue = 360f,
//                                            animationSpec = infiniteRepeatable(
//                                                animation = tween(1000, easing = LinearEasing),
//                                                repeatMode = RepeatMode.Restart
//                                            ),
//                                            label = "rotate"
//                                        )
//
//                                        val interactionSource = remember { MutableInteractionSource() }
//
//                                        Box(
//                                            modifier = Modifier
//                                                .size(40.dp)
//                                                .padding(bottom = 4.dp)
//                                                .offset(x = 10.dp)
//                                                .clip(RoundedCornerShape(50.dp))
//                                                .clickable(
//                                                    interactionSource = interactionSource,
//                                                    indication = ripple(color = Color.White, bounded = true),
//                                                    enabled = !isScanning
//                                                ) {
//                                                    wifiViewModel.startScan()
//                                                },
//                                            contentAlignment = Alignment.Center
//                                        ) {
//                                            Image(
//                                                painter = painterResource(id = R.drawable.reload),
//                                                contentDescription = null,
//                                                contentScale = ContentScale.Fit,
//                                                modifier = Modifier
//                                                    .size(30.dp)
//                                                    .graphicsLayer {
//                                                        rotationZ = if (isScanning) rotation else 0f
//                                                    }
//                                            )
//                                        }
//                                    }
//
//                                    Column(
//                                        modifier = Modifier
//                                            .fillMaxWidth()
//                                            .padding(horizontal = 10.dp)
////                                            .fillMaxHeight()
//                                    ) {
//                                        //TODO CREATE THE WIFI LIST
//                                    }
//                                }
//                            }
//                        }}








                }
            }
        }
    }
}
