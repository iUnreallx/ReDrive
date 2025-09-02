package com.unreallx.redrive.Mobile.Permissions

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalLifecycleOwner
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.zIndex
import androidx.core.content.ContextCompat
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import com.unreallx.redrive.ui.theme.ReDriveColors
import com.unreallx.redrive.utils.fixedSp

@Composable
fun BluetoothPermissionHandler(
    onPermissionsGranted: () -> Unit,
    content: @Composable () -> Unit,
) {
    val context = LocalContext.current
    val lifecycleOwner = LocalLifecycleOwner.current

    var hasLaunched by remember { mutableStateOf(false) }
    var permissionDenied by remember { mutableStateOf(false) }

    val permissions =
        listOf(
            Manifest.permission.BLUETOOTH_CONNECT,
            Manifest.permission.BLUETOOTH_SCAN,
        )

    val permissionLauncher =
        rememberLauncherForActivityResult(
            contract = ActivityResultContracts.RequestMultiplePermissions(),
        ) { result ->
            val allGranted = result.values.all { it }
            if (allGranted) {
                hasLaunched = true
                permissionDenied = false
                onPermissionsGranted()
            } else {
                permissionDenied = true
            }
        }

    LaunchedEffect(Unit) {
        hasLaunched = false
        permissionDenied = false

        val notGranted =
            permissions.filter {
                ContextCompat.checkSelfPermission(context, it) != PackageManager.PERMISSION_GRANTED
            }

        if (notGranted.isNotEmpty()) {
            permissionLauncher.launch(notGranted.toTypedArray())
        } else {
            hasLaunched = true
            onPermissionsGranted()
        }
    }

    DisposableEffect(lifecycleOwner) {
        val observer =
            LifecycleEventObserver { _, event ->
                if (event == Lifecycle.Event.ON_RESUME) {
                    val notGranted =
                        permissions.filter {
                            ContextCompat.checkSelfPermission(context, it) != PackageManager.PERMISSION_GRANTED
                        }

                    if (notGranted.isEmpty()) {
                        hasLaunched = true
                        permissionDenied = false
                        onPermissionsGranted()
                    } else {
                        permissionDenied = true
                    }
                }
            }
        lifecycleOwner.lifecycle.addObserver(observer)

        onDispose {
            lifecycleOwner.lifecycle.removeObserver(observer)
        }
    }

    if (!hasLaunched || permissionDenied) {
        PermissionOverlay(
            message = "Выдайте разрешения на использование Bluetooth (устройства поблизости) в настройках",
            onSettingsClick = {
                val intent =
                    Intent(
                        android.provider.Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                        Uri.fromParts("package", context.packageName, null),
                    )
                context.startActivity(intent)
            },
        )
    }
    content()
}

@Composable
private fun PermissionOverlay(
    message: String,
    onSettingsClick: () -> Unit,
) {
    Box(
        modifier =
            Modifier
                .fillMaxSize()
                .background(Color.Black.copy(alpha = 0.5f))
                .zIndex(10f)
                .pointerInput(Unit) {
                    awaitPointerEventScope {
                        while (true) {
                            awaitPointerEvent()
                        }
                    }
                },
        contentAlignment = Alignment.Center,
    ) {
        Box(
            modifier =
                Modifier
                    .width(250.dp)
                    .height(175.dp)
                    .clip(RoundedCornerShape(16.dp))
                    .background(ReDriveColors.PermissionColorBackground)
                    .zIndex(10f),
        ) {
            Column(
                modifier =
                    Modifier
                        .fillMaxSize()
                        .padding(12.dp),
                verticalArrangement = Arrangement.SpaceBetween,
                horizontalAlignment = Alignment.CenterHorizontally,
            ) {
                Text(
                    text = message,
                    color = Color.White,
                    fontSize = fixedSp(20),
                    textAlign = TextAlign.Center,
                    modifier = Modifier.fillMaxWidth(),
                )

                Button(
                    onClick = onSettingsClick,
                    modifier =
                        Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 4.dp),
                ) {
                    Text("Открыть настройки", fontSize = fixedSp(18))
                }
            }
        }
    }
}
