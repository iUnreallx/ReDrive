package com.unreallx.redrive.Mobile.Ui.Screen.Home

import android.util.Log
import android.widget.Toast
import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.withTransform
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.zIndex
import com.unreallx.redrive.Mobile.Ui.Screen.Speedometer.SpeedometerMini
import com.unreallx.redrive.R
import com.unreallx.redrive.Utils.BluetoothViewModel
import com.unreallx.redrive.Utils.CustomRippleBox
import com.unreallx.redrive.Utils.fixedSp
import com.unreallx.redrive.ui.theme.ReDriveColors
import kotlinx.coroutines.delay
import kotlin.random.Random

@Composable
fun getMenuUI(viewModel: BluetoothViewModel) {
    val context = LocalContext.current

    val scrollState = rememberScrollState()
    var isToggled by rememberSaveable { mutableStateOf(false) }
    val connectedDevice by viewModel.connectedDevice.collectAsState()
    val isRealObdConnected =
        remember(connectedDevice) {
            connectedDevice?.name?.lowercase()?.contains("obd") == true ||
                connectedDevice?.name?.lowercase()?.contains("elm") == true ||
                connectedDevice?.name?.lowercase()?.contains("unreallx") == true
        }

    val circlePositionX by animateDpAsState(
        targetValue = if (isToggled) 34.dp else 6.dp,
        animationSpec = tween(durationMillis = 300),
    )

    val textPositionX by animateDpAsState(
        targetValue = if (isToggled) 10.dp else 30.dp,
        animationSpec = tween(durationMillis = 300),
    )

    val circleColor by animateColorAsState(
        targetValue = if (isToggled) ReDriveColors.AccentAppColor else Color.White,
        animationSpec = tween(durationMillis = 300),
    )

    val textColor by animateColorAsState(
        targetValue = ReDriveColors.AccentAppColor,
        animationSpec = tween(durationMillis = 300),
    )

    Column(
        modifier =
            Modifier
                .fillMaxSize()
                .verticalScroll(scrollState)
                .padding(bottom = 70.dp),
    ) {
        Row {
            // button connection
            CustomRippleBox(
                modifier =
                    Modifier
                        .width(70.dp)
                        .padding(start = 10.dp)
                        .height(30.dp)
                        .border(2.dp, Color(0xFF4178F6), RoundedCornerShape(50.dp))
                        .clip(RoundedCornerShape(20.dp))
                        .background(ReDriveColors.BackgroundToMain),
                onClick = {
                    Log.d("obd2conn", "$isRealObdConnected")
                    if (!isRealObdConnected) {
                        isToggled = !isToggled
                        viewModel.setDemoMode(isToggled)
                    } else {
                        Toast.makeText(context, "OBD2 уже подключено", Toast.LENGTH_SHORT).show()
                    }
                },
            ) {
                Box(modifier = Modifier.fillMaxSize()) {
                    Box(
                        modifier =
                            Modifier
                                .padding(start = circlePositionX)
                                .align(Alignment.CenterStart)
                                .size(20.dp)
                                .background(circleColor, CircleShape)
                                .clip(CircleShape)
                                .zIndex(1f),
                    )

                    // Текст
                    Text(
                        text = "Demo\nMode",
                        fontSize = 8.sp,
                        lineHeight = 10.sp,
                        fontWeight = FontWeight.Bold,
                        color = textColor,
                        modifier =
                            Modifier
                                .padding(start = textPositionX)
                                .align(Alignment.CenterStart),
                    )
                }
            }

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.End,
            ) {
                Box(
                    modifier =
                        Modifier
                            .width(40.dp)
                            .height(30.dp)
                            .padding(end = 10.dp),
                ) {
                    Image(
                        painter = painterResource(id = R.drawable.settings_accent),
                        contentDescription = null,
                        contentScale = ContentScale.Fit,
                        modifier =
                            Modifier
                                .size(35.dp)
                                .align(Alignment.Center)
                                .zIndex(1f),
                    )
                }
            }
        }

        // Main box
        BoxWithConstraints(
            modifier =
                Modifier
                    .fillMaxWidth()
                    .height(250.dp)
                    .padding(start = 10.dp, end = 10.dp, top = 5.dp)
                    .clip(RoundedCornerShape(20.dp))
                    .background(ReDriveColors.BackgroundToMain),
        ) {
            val screenWidth = LocalConfiguration.current.screenWidthDp.dp

            Column(
                modifier =
                    Modifier
                        .fillMaxSize()
                        .padding(vertical = 16.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
            ) {
                // car name
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text(
                        text = "Mitsubishi Lancer IX",
                        fontSize = fixedSp(26),
                        letterSpacing = 2.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color.White,
                    )
                }

                // Car
                BoxWithConstraints(
                    modifier =
                        Modifier
                            .fillMaxWidth()
                            .height(150.dp)
                            .offset(y = 40.dp),
                    Alignment.Center,
                ) {
                    Image(
                        painter = painterResource(id = R.drawable.car_background),
                        contentDescription = null,
                        contentScale = ContentScale.Crop,
                        modifier =
                            Modifier
                                .width(screenWidth * 0.95f)
                                .widthIn(max = 100.dp)
                                .offset(y = (-20).dp)
                                .zIndex(1f),
                    )

                    Canvas(
                        modifier =
                            Modifier
                                .width(350.dp)
                                .height(60.dp)
                                .align(Alignment.BottomCenter)
                                .offset(y = (-15.dp)),
                    ) {
                        val center = Offset(size.width / 2, size.height / 2)
                        val radius = size.width / 2
                        val scaleY = size.height / size.width
                        withTransform({
                            scale(1f, scaleY, pivot = center)
                        }) {
                            drawCircle(
                                brush =
                                    Brush.radialGradient(
                                        colors = listOf(Color(0xFF000000), ReDriveColors.BackgroundToMain),
                                        center = center,
                                        radius = radius,
                                    ),
                                center = center,
                                radius = radius,
                            )
                        }
                    }
                }
            }
        }

        // button connection

        val connectedDevice by viewModel.connectedDevice.collectAsState()
        val isRealObdConnected =
            remember(connectedDevice) {
                connectedDevice?.name?.lowercase()?.contains("obd") == true ||
                    connectedDevice?.name?.lowercase()?.contains("elm") == true ||
                    connectedDevice?.name?.lowercase()?.contains("unreallx") == true
            }

        val animatedPadding by animateDpAsState(
            targetValue = if (isToggled) 8.dp else 30.dp,
            animationSpec = tween(durationMillis = 340, easing = FastOutSlowInEasing),
        )

        val backgroundColor by animateColorAsState(
            targetValue = if (isToggled) ReDriveColors.AccentAppColor else Color.White,
            animationSpec = tween(durationMillis = 340),
        )

        val circleSizeAnimation by animateDpAsState(
            targetValue = if (isToggled) 28.dp else 25.dp,
            animationSpec = tween(durationMillis = 340),
        )
        val context = LocalContext.current
        CustomRippleBox(
            modifier =
                Modifier
                    .fillMaxWidth()
                    .padding(start = 10.dp, end = 10.dp, top = 10.dp)
                    .height(60.dp)
                    .border(2.dp, Color(0xFF4178F6), RoundedCornerShape(50.dp))
                    .clip(RoundedCornerShape(20.dp))
                    .background(ReDriveColors.BackgroundToMain),
            onClick = {
                Log.d("obd2conn", "$isRealObdConnected")
                if (!isRealObdConnected) {
                    isToggled = !isToggled
                    viewModel.setDemoMode(isToggled)
                } else {
                    Toast.makeText(context, "OBD2 уже подключено", Toast.LENGTH_SHORT).show()
                }
            },
        ) {
            Box(modifier = Modifier.fillMaxSize()) {
                Image(
                    painter = painterResource(id = R.drawable.connect_accent),
                    contentDescription = null,
                    contentScale = ContentScale.Fit,
                    modifier =
                        Modifier
                            .padding(start = 17.dp)
                            .size(40.dp)
                            .align(Alignment.CenterStart)
                            .zIndex(1f),
                )
                Text(
                    text = "Подключено",
                    fontSize = fixedSp(24),
                    fontWeight = FontWeight.Bold,
                    color = ReDriveColors.AccentAppColor,
                    modifier =
                        Modifier
                            .padding(start = 60.dp)
                            .align(Alignment.CenterStart),
                )
                Box(
                    modifier =
                        Modifier
                            .padding(end = 15.dp)
                            .align(Alignment.CenterEnd)
                            .border(2.dp, ReDriveColors.AccentAppColor, RoundedCornerShape(30.dp))
                            .width(65.dp)
                            .clip(RoundedCornerShape(30.dp))
                            .height(40.dp),
                ) {
                    Box(
                        modifier =
                            Modifier
                                .padding(end = animatedPadding)
                                .align(Alignment.CenterEnd)
                                .size(circleSizeAnimation)
                                .background(backgroundColor, CircleShape)
                                .clip(CircleShape),
                    )
                }
            }
        }

        // row 1
        Row(
            modifier =
                Modifier
                    .fillMaxWidth()
                    .height(200.dp)
                    .padding(start = 10.dp, end = 10.dp, top = 10.dp)
                    .clip(RoundedCornerShape(30.dp)),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Box(
                modifier =
                    Modifier
                        .weight(1f)
                        .height(200.dp)
                        .clip(RoundedCornerShape(30.dp))
                        .background(ReDriveColors.BackgroundToMain),
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Box(
                        modifier =
                            Modifier
                                .width(60.dp)
                                .height(60.dp)
                                .padding(start = 20.dp, top = 20.dp)
                                .clip(RoundedCornerShape(50.dp))
                                .background(ReDriveColors.RoundedCorner262A32),
                    ) {
                        Image(
                            painter = painterResource(id = R.drawable.fuel),
                            contentDescription = null,
                            contentScale = ContentScale.Fit,
                            modifier =
                                Modifier
                                    .size(28.dp)
                                    .align(Alignment.Center)
                                    .zIndex(1f),
                        )
                    }

                    Text(
                        text = "Уровень\nтоплива",
                        fontSize = fixedSp(17),
                        fontWeight = FontWeight.Bold,
                        color = Color.White,
                        lineHeight = 20.sp,
                        modifier =
                            Modifier
                                .padding(start = 13.dp, top = 15.dp),
                    )
                }

                var fuelLevel by remember { mutableStateOf(0) }

                LaunchedEffect(isToggled) {
                    while (true) {
                        fuelLevel = if (isToggled) Random.nextInt(0, 101) else 0
                        delay(1000)
                    }
                }

                val animatedFuel by animateFloatAsState(
                    targetValue = fuelLevel.toFloat(),
                    animationSpec = tween(durationMillis = 300, easing = LinearEasing),
                    label = "fuelLevelAnimation",
                )

                Text(
                    text = "${animatedFuel.toInt()}%",
                    fontSize = fixedSp(30),
                    fontWeight = FontWeight.Bold,
                    color = ReDriveColors.AccentAppColor,
                    lineHeight = 20.sp,
                    modifier =
                        Modifier
                            .padding(bottom = 20.dp, start = 25.dp)
                            .align(Alignment.BottomStart),
                )
            }

            Spacer(modifier = Modifier.width(10.dp))

            Box(
                modifier =
                    Modifier
                        .weight(1f)
                        .height(200.dp)
                        .clip(RoundedCornerShape(30.dp))
                        .background(ReDriveColors.BackgroundToMain),
            ) {
                // Speedometer
                val obd2Data by viewModel.obd2Data.collectAsState()
                var speed = obd2Data.speed

                Box(
                    modifier =
                        Modifier
                            .fillMaxSize()
                            .offset(x = -2.5.dp, y = 10.dp),
                ) {
                    SpeedometerMini(
                        speed = speed.toFloat(),
                        sizeDp = 130.dp,
                        modifier = Modifier.align(Alignment.Center),
                    )
                }
            }
        }

        // row 2
        Row(
            modifier =
                Modifier
                    .fillMaxWidth()
                    .height(200.dp)
                    .padding(start = 10.dp, end = 10.dp, top = 10.dp)
                    .clip(RoundedCornerShape(30.dp)),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Box(
                modifier =
                    Modifier
                        .weight(1f)
                        .height(200.dp)
                        .clip(RoundedCornerShape(30.dp))
                        .background(ReDriveColors.BackgroundToMain),
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Box(
                        modifier =
                            Modifier
                                .width(60.dp)
                                .height(60.dp)
                                .padding(start = 20.dp, top = 20.dp)
                                .clip(RoundedCornerShape(50.dp))
                                .background(ReDriveColors.RoundedCorner262A32),
                    ) {
                        Image(
                            painter = painterResource(id = R.drawable.engine),
                            contentDescription = null,
                            contentScale = ContentScale.Fit,
                            modifier =
                                Modifier
                                    .size(30.dp)
                                    .align(Alignment.Center)
                                    .zIndex(1f),
                        )
                    }

                    Text(
                        text = "Обороты\nдвигателя",
                        fontSize = fixedSp(17),
                        fontWeight = FontWeight.Bold,
                        color = Color.White,
                        lineHeight = 20.sp,
                        modifier =
                            Modifier
                                .padding(start = 13.dp, top = 15.dp),
                    )
                }

                var engineRPM by remember { mutableStateOf(0) }

                LaunchedEffect(isToggled) {
                    while (true) {
                        engineRPM = if (isToggled) Random.nextInt(0, 15001) else 0
                        delay(1000)
                    }
                }

                val animatedEngineRpm by animateFloatAsState(
                    targetValue = engineRPM.toFloat(),
                    animationSpec = tween(durationMillis = 300, easing = LinearEasing),
                    label = "fuelLevelAnimation",
                )

                Text(
                    text = "${animatedEngineRpm.toInt()} Rpm",
                    fontSize = fixedSp(28),
                    fontWeight = FontWeight.Bold,
                    color = ReDriveColors.AccentAppColor,
                    lineHeight = 20.sp,
                    modifier =
                        Modifier
                            .padding(
                                bottom = 20.dp,
                                start = if (animatedEngineRpm.toInt() > 9999) 15.dp else 25.dp,
                            ).align(Alignment.BottomStart),
                )
            }

            Spacer(modifier = Modifier.width(10.dp))

            Box(
                modifier =
                    Modifier
                        .weight(1f)
                        .height(200.dp)
                        .clip(RoundedCornerShape(30.dp))
                        .background(ReDriveColors.BackgroundToMain),
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Box(
                        modifier =
                            Modifier
                                .width(60.dp)
                                .height(60.dp)
                                .padding(start = 20.dp, top = 20.dp)
                                .clip(RoundedCornerShape(50.dp))
                                .background(ReDriveColors.RoundedCorner262A32),
                    ) {
                        Image(
                            painter = painterResource(id = R.drawable.temp),
                            contentDescription = null,
                            contentScale = ContentScale.Fit,
                            modifier =
                                Modifier
                                    .size(35.dp)
                                    .align(Alignment.Center)
                                    .zIndex(1f),
                        )
                    }

                    Text(
                        text = "Температура\nдвигателя",
                        fontSize = fixedSp(16),
                        fontWeight = FontWeight.Bold,
                        color = Color.White,
                        lineHeight = 20.sp,
                        modifier =
                            Modifier
                                .padding(start = 5.dp, top = 15.dp),
                    )
                }

                var engineTemp by remember { mutableStateOf(0) }

                LaunchedEffect(isToggled) {
                    while (true) {
                        engineTemp = if (isToggled) Random.nextInt(-50, 151) else 0
                        delay(1000)
                    }
                }

                val animatedEngineTemp by animateFloatAsState(
                    targetValue = engineTemp.toFloat(),
                    animationSpec = tween(durationMillis = 300, easing = LinearEasing),
                    label = "fuelLevelAnimation",
                )

                Text(
                    text = "${animatedEngineTemp.toInt()}°C",
                    fontSize = fixedSp(28),
                    fontWeight = FontWeight.Bold,
                    color = ReDriveColors.AccentAppColor,
                    lineHeight = 20.sp,
                    modifier =
                        Modifier
                            .padding(
                                bottom = 20.dp,
                                start = 25.dp,
                            ).align(Alignment.BottomStart),
                )
            }
        }
    }
}
