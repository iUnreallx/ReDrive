package com.unreallx.redrive.Mobile.Navigation

import androidx.compose.animation.EnterTransition
import androidx.compose.animation.ExitTransition
import androidx.compose.animation.ExperimentalAnimationApi
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.scaleIn
import androidx.compose.animation.scaleOut
import androidx.compose.runtime.Composable
import androidx.navigation.NavHostController
import com.google.accompanist.navigation.animation.AnimatedNavHost
import com.google.accompanist.navigation.animation.composable
import com.unreallx.redrive.Mobile.Ui.Screen.Connection.connectionScreenUI
import com.unreallx.redrive.Mobile.Ui.Screen.Home.getMenuUI
import com.unreallx.redrive.Utils.BluetoothViewModel
import com.unreallx.redrive.Utils.WifiViewModel


sealed class Screen(val route: String) {
    object Menu : Screen("menu")
    object Car : Screen("car")
    object AI : Screen("ai")
    object Connection : Screen("connection")
}

@OptIn(ExperimentalAnimationApi::class)
@Composable
fun RootNavigation(navController: NavHostController,
                   bluetoothViewModel: BluetoothViewModel,
                   wifiViewModel: WifiViewModel) {
    AnimatedNavHost(
        navController = navController,
        startDestination = Screen.Menu.route,
        enterTransition = { scaleInAnimation() },
        exitTransition = { scaleOutAnimation() },
        popEnterTransition = { scaleInAnimation() },
        popExitTransition = { scaleOutAnimation() }
    ) {
        composable(Screen.Menu.route) { getMenuUI(
            bluetoothViewModel
        ) }
        composable(Screen.Car.route) { /* TODO */ }
        composable(Screen.AI.route) { /* TODO */ }
        composable(Screen.Connection.route) {
            connectionScreenUI(navController, bluetoothViewModel, wifiViewModel)
        }
    }
}

@OptIn(ExperimentalAnimationApi::class)
fun scaleInAnimation(): EnterTransition {
    return scaleIn(
        initialScale = 0.9f,
        animationSpec = tween(durationMillis = 250)
    ) + fadeIn(animationSpec = tween(250))
}

@OptIn(ExperimentalAnimationApi::class)
fun scaleOutAnimation(): ExitTransition {
    return scaleOut(
        targetScale = 1.1f,
        animationSpec = tween(durationMillis = 250)
    ) + fadeOut(animationSpec = tween(250))
}
