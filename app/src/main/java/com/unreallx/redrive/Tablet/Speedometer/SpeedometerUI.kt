package com.unreallx.redrive.Tablet.Speedometer

import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.nativeCanvas
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.unreallx.redrive.ui.theme.ReDriveColors
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.roundToInt
import kotlin.math.sin
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.Dp

//@Preview
//@Composable
//fun SpeedometerController() {
//    var speed by remember { mutableStateOf(0f) }
//    var accelerating by remember { mutableStateOf(false) }
//
////    LaunchedEffect(accelerating) {
////        while (true) {
////            if (accelerating) {
////                speed = (speed + 1).coerceAtMost(280f)
////            } else {
////                speed = (speed - 1).coerceAtLeast(0f)
////            }
////            kotlinx.coroutines.delay(30L)
////        }
////    }
//
//    Column(horizontalAlignment = Alignment.CenterHorizontally) {
//        Speedometer(speed = speed)
//        Spacer(modifier = Modifier.height(20.dp))
//        Column(
//            modifier = Modifier
////                .padding(horizontal = 32.dp, vertical = 16.dp)
//                .background(ReDriveColors.Button),
////                .padding(16.dp),
//            horizontalAlignment = Alignment.CenterHorizontally
//        ) {
//            Text("${speed.toInt()}", fontSize = 20.sp, color = ReDriveColors.MainText)
//
//            Slider(
//                value = speed,
//                onValueChange = { newValue ->
//                    speed = newValue
//                },
//                valueRange = 0f..280f,
//                modifier = Modifier
//                    .width(150.dp)
//            )
//        }
//    }
//}


@Composable
fun Speedometer(
    speed: Float,
    speedMin: Float = 0f,
    speedMax: Float = 280f,
    sizeDp: Dp = 250.dp,
    modifier: Modifier = Modifier
) {
    val angleStart = 135f
    val angleEnd = 405f
    val sweepAngle = angleEnd - angleStart

    val animatedSpeed by animateFloatAsState(
        targetValue = speed.coerceIn(speedMin, speedMax),
        animationSpec = tween(durationMillis = 300, easing = LinearEasing),
        label = "speed"
    )

    val needleAngle = angleStart + (animatedSpeed - speedMin) / (speedMax - speedMin) * sweepAngle
    Box(
        modifier
            .size(sizeDp),
        contentAlignment = Alignment.BottomCenter
    ) {
        val textSizeMini = with(LocalDensity.current) {
            (sizeDp.toPx() / 18).toSp()
        }
        Canvas(modifier = Modifier.fillMaxSize()) {
            val canvasSize = size.minDimension
            val radius = canvasSize / 2.2f
            val center = Offset(size.width / 2f, size.height / 2f)

            drawCircle(
                brush = Brush.radialGradient(
                    colors = listOf(
                        ReDriveColors.RadialGradient.copy(alpha = 0.5f),
                        Color.Transparent
                    ),
                    center = center,
                    radius = radius
                ),
                radius = radius,
                center = center
            )

            drawArc(
                color = Color.Gray.copy(alpha = 0.4f),
                startAngle = angleStart,
                sweepAngle = sweepAngle,
                useCenter = false,
                style = Stroke(width = 40f, cap = StrokeCap.Round),
                topLeft = Offset(center.x - radius, center.y - radius),
                size = Size(radius * 2, radius * 2)
            )


            //angle design
            val activeSweep = (needleAngle - angleStart).coerceIn(0f, sweepAngle)

            val sweepPath = Path().apply {
                arcTo(
                    rect = Rect(center - Offset(radius, radius), Size(radius * 2, radius * 2)),
                    startAngleDegrees = angleStart,
                    sweepAngleDegrees = activeSweep,
                    forceMoveTo = false
                )
            }

            val startOffset = Offset(
                center.x + radius * cos(angleStart * PI / 180).toFloat(),
                center.y + radius * sin(angleStart * PI / 180).toFloat()
            )

            val effectiveAngle = if (activeSweep < 10f) angleStart + 10f else needleAngle

            val endOffset = Offset(
                center.x + radius * cos(effectiveAngle * PI / 180).toFloat(),
                center.y + radius * sin(effectiveAngle * PI / 180).toFloat()
            )
            drawPath(
                path = sweepPath,
                brush = Brush.linearGradient(
                    colors = listOf(
                        ReDriveColors.SpeedometerShape,
                        ReDriveColors.SpeedometerMiddle,
                        ReDriveColors.SpeedometerEnd
                    ),
                    start = startOffset,
                    end = endOffset
                ),
                style = Stroke(width = 40f, cap = StrokeCap.Round)
            )

            val speedMax = 280f
            val bigTickStep = 20f
            val smallDivisions = 4
            val smallTickStep = bigTickStep / smallDivisions

            val totalSteps = (speedMax / smallTickStep).toInt()

            for (i in 0..totalSteps) {
                val value = i * smallTickStep
                val fraction = value / speedMax
                val angle = angleStart + fraction * sweepAngle
                val rad = Math.toRadians(angle.toDouble())

                val isBigTick = value % bigTickStep == 0f
                val tickColor = if (isBigTick) Color.White else Color.Gray
                val tickWidth = if (isBigTick) 4f else 2f
                val tickLength = if (isBigTick) 12f else 1f

                val startRadius = radius - tickLength - 50
                val endRadius = radius - 30

                val start = Offset(
                    x = (center.x + cos(rad) * startRadius).toFloat(),
                    y = (center.y + sin(rad) * startRadius).toFloat()
                )
                val end = Offset(
                    x = (center.x + cos(rad) * endRadius).toFloat(),
                    y = (center.y + sin(rad) * endRadius).toFloat()
                )

                drawLine(
                    color = tickColor,
                    start = start,
                    end = end,
                    strokeWidth = tickWidth
                )

                if (isBigTick) {
                    val textRadius = radius - 83
                    var textX = (center.x + cos(rad) * textRadius).toFloat()
                    val textY = (center.y + sin(rad) * textRadius).toFloat()

                    if (value >= 200f) {
                        textX -= 10f
                    }

                    drawContext.canvas.nativeCanvas.apply {
                        drawText(
                            "${value.toInt()}",
                            textX,
                            textY + 8,
                            android.graphics.Paint().apply {
                                color = android.graphics.Color.WHITE
                                textSize = if (value.toInt() % 40 == 0) textSizeMini.toPx() else 0f
                                typeface = android.graphics.Typeface.DEFAULT_BOLD
                                textAlign = android.graphics.Paint.Align.CENTER
                            }
                        )
                    }
                }
            }

            // arrow design
            val needleLength = radius - 100f
            val needleBaseWidth = 18f
            val needleRad = Math.toRadians(needleAngle.toDouble())

            val needleEnd = Offset(
                x = (center.x + cos(needleRad) * needleLength).toFloat(),
                y = (center.y + sin(needleRad) * needleLength).toFloat()
            )

            val baseLeft = Offset(
                x = (center.x + cos(needleRad - Math.PI / 2) * needleBaseWidth).toFloat(),
                y = (center.y + sin(needleRad - Math.PI / 2) * needleBaseWidth).toFloat()
            )

            val baseRight = Offset(
                x = (center.x + cos(needleRad + Math.PI / 2) * needleBaseWidth).toFloat(),
                y = (center.y + sin(needleRad + Math.PI / 2) * needleBaseWidth).toFloat()
            )

            val needlePath = Path().apply {
                moveTo(needleEnd.x, needleEnd.y)
                lineTo(baseLeft.x, baseLeft.y)
                lineTo(baseRight.x, baseRight.y)
                close()
            }

            drawPath(
                color = Color.White,
                path = needlePath
            )
            drawCircle(Color.White, 24f, center)
            drawCircle(Color.Black, 16f, center)

        }

        val textSize = with(LocalDensity.current) {
            (sizeDp.toPx() / 7).toSp()
        }
        Text(
            text = "${animatedSpeed.roundToInt()}",
            fontSize = textSize,
            fontWeight = FontWeight.Bold,
            color = ReDriveColors.MainText,
            modifier = Modifier
                .offset(y = -38.dp)
        )
    }
}
