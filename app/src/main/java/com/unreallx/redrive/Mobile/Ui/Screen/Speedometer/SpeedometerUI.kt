package com.unreallx.redrive.Mobile.Ui.Screen.Speedometer

//import androidx.compose.ui.graphics.Brush
import android.graphics.BlurMaskFilter
import android.graphics.RectF
import android.graphics.SweepGradient
import android.graphics.Typeface
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
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.DrawStyle
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.drawscope.drawIntoCanvas
import androidx.compose.ui.graphics.drawscope.rotate
import androidx.compose.ui.graphics.nativeCanvas
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.unreallx.redrive.Utils.fixedSp
import com.unreallx.redrive.ui.theme.ReDriveColors
import kotlin.math.cos
import kotlin.math.roundToInt
import kotlin.math.sin
import kotlin.math.sqrt


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

private object SpeedometerConstants {
    const val SPEED_MIN = 0f
    const val SPEED_MAX = 280f
}

@Composable
fun Speedometer(
    modifier: Modifier = Modifier,
    speedMin: Float = SpeedometerConstants.SPEED_MIN,
    speedMax: Float = SpeedometerConstants.SPEED_MAX,
    sizeDp: Dp,
    speed: Float
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

            val speedMax = 280f
            val fraction_40 = 40f / speedMax
            val angle_40 = angleStart + fraction_40 * sweepAngle

            val fraction_240 = 240f / speedMax
            val angle_240 = angleStart + fraction_240 * sweepAngle

            val fraction_middle = 140f / speedMax
            val angle_middle = angleStart + fraction_middle * sweepAngle

            val arcRadius = radius + 60f
            val arcWidth = 40f

            val posStart = angle_40 / 360f
            val posMiddle = angle_middle / 360f
            val posEnd = angle_240 / 360f

            // gradient shadows
            val nativePaint = android.graphics.Paint().apply {
                style = android.graphics.Paint.Style.STROKE
                strokeWidth = arcWidth - 15f
                shader = SweepGradient(
                    center.x + 10, center.y,
                    intArrayOf(
                        ReDriveColors.BackgroundToMain.toArgb(),
                        ReDriveColors.AccentAppColor.toArgb(),
                        ReDriveColors.BackgroundToMain.toArgb()
                    ),
                    floatArrayOf(posStart, posMiddle, posEnd)
                )
                val blurRadius = 0.15f * arcRadius
                maskFilter = BlurMaskFilter(blurRadius, BlurMaskFilter.Blur.NORMAL)
            }

            drawIntoCanvas { canvas ->
                val rectF = RectF(
                    center.x + 10 - arcRadius,
                    center.y - arcRadius,
                    center.x + 10 + arcRadius,
                    center.y + arcRadius
                )

                canvas.nativeCanvas.drawArc(
                    rectF,
                    angle_40,
                    (fraction_240 - fraction_40) * sweepAngle,
                    false,
                    nativePaint
                )
            }

            //angle captaion
            val arcRadius2 = radius + 80f
            val arcWidth2 = 15f
            val gradient = Brush.sweepGradient(
                colorStops = arrayOf(
                    posStart to ReDriveColors.BackgroundToMain,
                    posMiddle to ReDriveColors.AccentAppColor,
                    posEnd to ReDriveColors.BackgroundToMain
                ),
                center = Offset(center.x + 10, center.y)
            )

            drawArc(
                brush = gradient,
                startAngle = angle_40,
                sweepAngle = (fraction_240 - fraction_40) * sweepAngle,
                useCenter = false,
                topLeft = Offset(center.x + 10 - arcRadius2, center.y - arcRadius2),
                size = Size(arcRadius2 * 2, arcRadius2 * 2),
                style = Stroke(width = arcWidth2, cap = StrokeCap.Round)
            )

            //angle inside
            val arcRadius3 = radius - 230f
            val arcWidth3 = 3f

            val gradient3 = Brush.sweepGradient(
                colorStops = arrayOf(
                    posStart to ReDriveColors.BackgroundToMain,
                    posMiddle to ReDriveColors.AccentAppColor,
                    posEnd to ReDriveColors.BackgroundToMain
                ),
                center = Offset(center.x, center.y)
            )


            rotate(degrees = needleAngle + 95) {
                drawArc(
                    brush = gradient3,
                    startAngle = angle_40,
                    sweepAngle = (fraction_240 - fraction_40) * sweepAngle,
                    useCenter = false,
                    topLeft = Offset(center.x - arcRadius3, center.y - arcRadius3),
                    size = Size(arcRadius3 * 2, arcRadius3 * 2),
                    style = Stroke(width = arcWidth3, cap = StrokeCap.Round)
                )
            }


            //FOURTH ANGLE inside
            val arcRadius4 =  radius - 170f
            val arcWidth4 = 7f

            val fraction1_40 = 0f / speedMax
            val angle1_40 = angleStart + fraction1_40 * sweepAngle

            val fraction1_240 = 360f / speedMax
            val angle1_240 = angleStart + fraction1_240 * sweepAngle

            val fraction1_middle = 140f / speedMax
            val angle1_middle = angleStart + fraction1_middle * sweepAngle

            val posStart1 = angle1_40 / 360f
            val posMiddle1 = angle1_middle / 360f
            val posEnd1 = angle1_240 / 360f

            val gradient4 = Brush.sweepGradient(
                colorStops = arrayOf(
                    posStart1 to ReDriveColors.BackgroundToMain,
                    posMiddle1 to ReDriveColors.AccentAppColorMoreDark,
                    posEnd1 to ReDriveColors.BackgroundToMain
                ),
                center = Offset(center.x, center.y)
            )

            rotate(degrees = needleAngle + 115) {
                drawArc(
                    brush = gradient4,
                    startAngle = angle1_40,
                    sweepAngle = (fraction1_240 - fraction1_40) * sweepAngle,
                    useCenter = false,
                    topLeft = Offset(center.x - arcRadius4, center.y - arcRadius4),
                    size = Size(arcRadius4 * 2, arcRadius4 * 2),
                    style = Stroke(width = arcWidth4, cap = StrokeCap.Round)
                )
            }


            //text + ticks
            val bigTickStep = 20f
            val smallDivisions = 2
            val smallTickStep = bigTickStep / smallDivisions
            val totalSteps = (speedMax / smallTickStep).toInt()

            val tickOuterRadiusBig = radius - 30f
            val tickOuterRadiusSmall = radius - 35f
            val tickLengthBig = 20f
            val tickLengthSmall = 10f

            for (i in 0..totalSteps) {
                val value = i * smallTickStep
                val fraction = value / speedMax
                val angle = angleStart + fraction * sweepAngle
                val rad = Math.toRadians(angle.toDouble())

                val angleColorTick = if (angle <= needleAngle) {
                    ReDriveColors.AccentAppColorDark
                } else {
                    ReDriveColors.AccentAppColorMoreDark
                }

                val angleColorBig = if (angle <= needleAngle) {
                    ReDriveColors.AccentAppColor
                } else {
                    ReDriveColors.AccentAppColorDark
                }

                val isBigTick = value % bigTickStep == 0f
                val tickColor = if (isBigTick) angleColorBig else angleColorTick
                val tickWidth = if (isBigTick) 14f else 10f
                val tickOuterRadius = if (isBigTick) tickOuterRadiusBig else tickOuterRadiusSmall
                val tickLength = if (isBigTick) tickLengthBig else tickLengthSmall

                val startRadius = tickOuterRadius - tickLength
                val endRadius = tickOuterRadius

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
                    strokeWidth = tickWidth,
                    cap = StrokeCap.Round
                )

                if (isBigTick) {
                    val textRadius = radius + 20f
                    var textX = (center.x + cos(rad) * textRadius).toFloat()
                    var textY = (center.y + sin(rad) * textRadius).toFloat() + 5f

                    if ((value in 200f..240f) || (value == 260f)) {
                        textX += 15f
                    }

                    val textColor = if (angle <= needleAngle) {
                        ReDriveColors.AccentAppColorLight
                    } else {
                        ReDriveColors.AccentLessWhite
                    }

                    drawContext.canvas.nativeCanvas.apply {
                        drawText(
                            "${value.toInt()}",
                            textX,
                            textY + 8,
                            android.graphics.Paint().apply {
                                color = textColor.toArgb()
                                textSize = if (value.toInt() % 40 == 0) textSizeMini.toPx() else 0f
                                Typeface.DEFAULT_BOLD
                                textAlign = android.graphics.Paint.Align.CENTER
                            }
                        )
                    }
                }
            }

            //arrow angle
            val needleRad = Math.toRadians(needleAngle.toDouble())
            val direction = Offset(cos(needleRad).toFloat(), sin(needleRad).toFloat())
            val needleLength = radius - 100f
            val needleBaseWidth = 16f
            val pivotOffset = 15f
            val pivotRadius = radius - 240f - pivotOffset
            val pivot = Offset(
                center.x + cos(needleRad).toFloat() * pivotRadius,
                center.y + sin(needleRad).toFloat() * pivotRadius
            )
            val tip = Offset(
                center.x + cos(needleRad).toFloat() * needleLength,
                center.y + sin(needleRad).toFloat() * needleLength
            )
            val perpendicular = Offset(-direction.y, direction.x)
            val basePoint1 = pivot + perpendicular * needleBaseWidth
            val basePoint2 = pivot - perpendicular * needleBaseWidth

            val r = 15f

            fun Offset.normalize(): Offset {
                val length = sqrt(x * x + y * y)
                return if (length > 0) Offset(x / length, y / length) else Offset(0f, 0f)
            }

            val dirTipToBase1 = (basePoint1 - tip).normalize()
            val dirBase1ToBase2 = (basePoint2 - basePoint1).normalize()
            val dirBase2ToTip = (tip - basePoint2).normalize()

            val P1 = tip + dirTipToBase1 * r
            val P2 = basePoint1 - dirTipToBase1 * r
            val P3 = basePoint1 + dirBase1ToBase2 * r
            val P4 = basePoint2 - dirBase1ToBase2 * r
            val P5 = basePoint2 + dirBase2ToTip * r
            val P6 = tip - dirBase2ToTip * r

            val needlePath = Path().apply {
                moveTo(P1.x, P1.y)
                lineTo(P2.x, P2.y)
                quadraticTo(basePoint1.x, basePoint1.y, P3.x, P3.y)
                lineTo(P4.x, P4.y)
                quadraticTo(basePoint2.x, basePoint2.y, P5.x, P5.y)
                lineTo(P6.x, P6.y)
                quadraticTo(tip.x, tip.y, P1.x, P1.y)
                close()
            }
            drawPath(color = Color.White, path = needlePath)
        }

        Text(
            text = "${animatedSpeed.roundToInt()}",
            fontSize = fixedSp(sizeDp.value / 7),
            fontWeight = FontWeight.Bold,
            color = ReDriveColors.MainText,
            modifier = Modifier
                .align(Alignment.Center)
        )

        Text(
            text = "Km/h",
            fontSize = fixedSp(sizeDp.value / 18),
            fontWeight = FontWeight.Bold,
            color = ReDriveColors.MainText,
            modifier = Modifier
                .align(Alignment.Center)
                .offset(y = 30.dp)
        )
    }
}










































//            drawCircle(
//                brush = Brush.radialGradient(
//                    colors = listOf(
//                        ReDriveColors.RadialGradient.copy(alpha = 0.5f),
//                        Color.Transparent
//                    ),
//                    center = center,
//                    radius = radius
//                ),
//                radius = radius,
//                center = center
//            )

val arcStrokeWidth = 50f
//            val arcRadius = radius + arcStrokeWidth / 15f

//            drawArc(
//                color = Color.Gray.copy(alpha = 0.4f),
//                startAngle = angleStart,
//                sweepAngle = sweepAngle,
//                useCenter = false,
//                style = Stroke(width = arcStrokeWidth, cap = StrokeCap.Round),
//                topLeft = Offset(center.x - arcRadius, center.y - arcRadius),
//                size = Size(arcRadius * 2, arcRadius * 2)
//            )


//angle design
//            val sweepStrokeWidth = 50f
//            val sweepRadius = radius + sweepStrokeWidth / 15f
//
//            val activeSweep = (needleAngle - angleStart).coerceIn(0f, sweepAngle)
//
//            val sweepPath = Path().apply {
//                arcTo(
//                    rect = Rect(
//                        center - Offset(sweepRadius, sweepRadius),
//                        Size(sweepRadius * 2, sweepRadius * 2)
//                    ),
//                    startAngleDegrees = angleStart,
//                    sweepAngleDegrees = activeSweep,
//                    forceMoveTo = false
//                )
//            }
//
//            val startOffset = Offset(
//                center.x + sweepRadius * cos(angleStart * PI / 180).toFloat(),
//                center.y + sweepRadius * sin(angleStart * PI / 180).toFloat()
//            )
//
//            val effectiveAngle = if (activeSweep < 10f) angleStart + 10f else needleAngle
//
//            val endOffset = Offset(
//                center.x + sweepRadius * cos(effectiveAngle * PI / 180).toFloat(),
//                center.y + sweepRadius * sin(effectiveAngle * PI / 180).toFloat()
//            )
//
//            drawPath(
//                path = sweepPath,
//                brush = Brush.linearGradient(
//                    colors = listOf(
//                        ReDriveColors.SpeedometerShape,
//                        ReDriveColors.SpeedometerMiddle,
//                        ReDriveColors.SpeedometerEnd
//                    ),
//                    start = startOffset,
//                    end = endOffset
//                ),
//                style = Stroke(width = sweepStrokeWidth, cap = StrokeCap.Round)
//            )

