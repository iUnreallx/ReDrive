package com.unreallx.redrive

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.content.pm.PackageManager
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.asPaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBars
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.systemBars
import androidx.compose.material3.Surface
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.unreallx.redrive.Mobile.Ui.Screen.AppNavigation.mobileMainScreen
import com.unreallx.redrive.ui.theme.ReDriveColors
import com.unreallx.redrive.ui.theme.ReDriveTheme
import com.unreallx.redrive.utils.LoggingReDrive
import com.unreallx.redrive.utils.Vibrations

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        LoggingReDrive.initialize(applicationContext)
        Vibrations.initialize(applicationContext)
        setContent {
            ReDriveTheme(darkTheme = true) {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = ReDriveColors.Background,
//                    color = Color.Gray
                ) {
                    val bottomInset = WindowInsets.navigationBars.asPaddingValues().calculateBottomPadding()
                    if (ContextCompat.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE) !=
                        PackageManager.PERMISSION_GRANTED
                    ) {
                        ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE), 100)
                    }

                    Box(Modifier.fillMaxSize()) {
                        Box(
                            Modifier
                                .fillMaxWidth()
                                .height(bottomInset)
                                .background(ReDriveColors.BackgroundToMain)
                                .align(Alignment.BottomCenter),
//                                .zIndex(3f),
                            contentAlignment = Alignment.Center,
                        ) {
                        }
                    }

                    Box(
                        Modifier
                            .fillMaxSize()
                            .padding(WindowInsets.systemBars.asPaddingValues()),
//                        contentAlignment = Alignment.TopStart
                    ) {
//                        if (DeviceUtils.isTablet(this@MainActivity)) {
//                            tabletMainScreen()
//                        } else {
                        mobileMainScreen()
//                        }
                    }
                }
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        val bluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
        bluetoothAdapter?.cancelDiscovery()
    }
}
