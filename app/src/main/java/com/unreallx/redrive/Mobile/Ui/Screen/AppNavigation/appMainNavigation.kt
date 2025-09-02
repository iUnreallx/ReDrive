package com.unreallx.redrive.Mobile.Ui.Screen.AppNavigation

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.compose.rememberNavController
import com.unreallx.redrive.Mobile.Navigation.RootNavigation
import com.unreallx.redrive.Mobile.Navigation.Screen
import com.unreallx.redrive.Mobile.Ui.Screen.Components.BottomPanel
import com.unreallx.redrive.R
import com.unreallx.redrive.Utils.BluetoothViewModel
import com.unreallx.redrive.Utils.WifiViewModel

@Composable
fun mobileMainScreen() {
    val navController = rememberNavController()
    val bluetoothViewModel: BluetoothViewModel = viewModel()
    val wifiViewModel: WifiViewModel = viewModel()

    Box(modifier = Modifier.fillMaxSize()) {
        RootNavigation(navController, bluetoothViewModel, wifiViewModel)
        BottomPanel(onIconSelected = { iconId ->
            val route = when (iconId) {
                R.drawable.home -> Screen.Menu.route
                R.drawable.car -> Screen.Car.route
                R.drawable.ai -> Screen.AI.route
                R.drawable.connect -> Screen.Connection.route
                else -> Screen.Menu.route
            }

            navController.navigate(route) {
                popUpTo(navController.graph.startDestinationId) { saveState = true }
                launchSingleTop = true
                restoreState = true
            }
        })
    }
}
