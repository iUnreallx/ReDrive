package com.unreallx.redrive.Mobile.Components

import androidx.annotation.DrawableRes
import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.indication
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.ripple
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.zIndex
import com.unreallx.redrive.R
import com.unreallx.redrive.ui.theme.ReDriveColors


@Composable
fun IconWithRipple(
    @DrawableRes iconRes: Int,
    iconSize: Dp,
    rippleSize: Dp = iconSize * 4,
    rotation: Float = 0f,
    rippleColor: Color = Color.White,
    isSelected: Boolean = false,
    onSelected: () -> Unit,
    defaultIconColor: Color = Color(0xFF4178F6),
) {
    val animatedColor by animateColorAsState(
        targetValue = if (isSelected) defaultIconColor else Color.White,
        animationSpec = tween(350),
        label = "iconColor"
    )

    val animatedIconSize by animateDpAsState(
        targetValue = if (isSelected) iconSize + 7.dp else iconSize,
        animationSpec = tween(durationMillis = 300),
        label = "iconSize"
    )

//    val animatedOffsetY by animateDpAsState(
//        targetValue = if (isSelected) (-3).dp else 0.dp,
//        animationSpec = tween(durationMillis = 300),
//        label = "iconOffset"
//    )

    val interactionSource = remember { MutableInteractionSource() }

    Box(
        modifier = Modifier
            .size(rippleSize)
            .clip(CircleShape)
//            .offset(y = animatedOffsetY)
            .indication(
                interactionSource = interactionSource,
                indication = ripple(
                    bounded = false,
                    color = rippleColor
                )
            )
            .clickable(
                interactionSource = interactionSource,
                indication = null,
                onClick = onSelected
            ),
        contentAlignment = Alignment.Center
    ) {
        Image(
            painter = painterResource(id = iconRes),
            contentDescription = null,
            modifier = Modifier
                .size(animatedIconSize)
                .graphicsLayer(rotationZ = rotation),
            colorFilter = ColorFilter.tint(animatedColor),
            contentScale = ContentScale.Fit
        )
    }
}










@Preview
@Composable
fun BottomPanel(
    width: Dp = 350.dp,
    height: Dp = 60.dp,
    endRadius: Dp = 40.dp,
    onIconSelected: (Int) -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize(),
//            .padding(bottom = 20.dp),
        verticalArrangement = Arrangement.Bottom,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Box(
            contentAlignment = Alignment.Center
        ) {

            //oval bottom menu panel
            Box(
                modifier = Modifier
                    .width(150.dp)
                    .height(75.dp)
                    .offset(y = (3).dp, x = 3.dp)
                    .zIndex(1f)
                    .align(Alignment.BottomCenter)
            ) {
                Canvas (modifier = Modifier
                    .fillMaxSize()
                    .offset(y = (5).dp)
                ) {
                    drawOval(
                        color = ReDriveColors.BackgroundToMain,
                        size =  Size(size.width - 20f, size.height - 20f)
                    )
                }
            }


//            //gradient oval around bottom panel
//            Image(
//                painter = painterResource(id = R.drawable.gradient_to_menu),
//                contentDescription = null,
//                contentScale = ContentScale.FillBounds,
//                modifier = Modifier
//                    .width(width + 360.dp)
//                    .height(170.dp)
//                    .align(Alignment.Center)
//                    .offset(y = (50).dp)
////                    .zIndex(0f)
//            )

            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(height)
                    .background(ReDriveColors.BackgroundToMain)
                    .align(Alignment.BottomCenter)
                    .zIndex(1f)
            )


            //ALL ICONS BTW
            var selectedIconId by remember { mutableStateOf(R.drawable.home) }

            val our_height = 7.5.dp


            fun selectIcon(id: Int) {
                selectedIconId = id
                onIconSelected(id)
            }

            Box(Modifier.width(75.dp).height(75.dp).offset(x = (-160).dp, y = our_height).zIndex(5f)) {
                IconWithRipple(
                    iconRes = R.drawable.home, iconSize = 50.dp,
                    isSelected = selectedIconId == R.drawable.home,
                    onSelected = { selectIcon(R.drawable.home) }
                )
            }

            Box(Modifier.width(75.dp).height(75.dp).offset(x = (-103.67).dp, y = our_height).zIndex(5f)) {
                IconWithRipple(
                    iconRes = R.drawable.car, iconSize = 47.dp,
                    isSelected = selectedIconId == R.drawable.car,
                    onSelected = { selectIcon(R.drawable.car) }
                )
            }

            Box(Modifier.width(75.dp).height(75.dp).offset(x = (-48.33).dp, y = our_height).zIndex(5f)) {
                IconWithRipple(
                    iconRes = R.drawable.ai, iconSize = 50.dp,
                    isSelected = selectedIconId == R.drawable.ai,
                    onSelected = { selectIcon(R.drawable.ai) }
                )
            }

            Box(Modifier.width(75.dp).height(75.dp).offset(x = (0).dp, y = our_height).zIndex(5f)) {
                IconWithRipple(
                    iconRes = R.drawable.connect, iconSize = 47.dp, rotation = 5f,
                    isSelected = selectedIconId == R.drawable.connect,
                    onSelected = { selectIcon(R.drawable.connect) }
                )
            }

            Box(
                Modifier
                    .width(75.dp)
                    .height(75.dp)
                    .offset(x = (53.33).dp, y = our_height - 5.dp)
                    .zIndex(5f)
            ) {
                IconWithRipple(
                    R.drawable.map, 47.dp,
                    isSelected = selectedIconId == R.drawable.map,
                    onSelected = { selectedIconId = R.drawable.map }
                )
            }

            Box(
                Modifier
                    .width(75.dp)
                    .height(75.dp)
                    .offset(x = (106.67).dp, y = our_height - 3.dp)
                    .zIndex(5f)
            ) {
                IconWithRipple(
                    R.drawable.music, 48.dp,
                    isSelected = selectedIconId == R.drawable.music,
                    onSelected = { selectedIconId = R.drawable.music }
                )
            }

            Box(
                Modifier
                    .width(75.dp)
                    .height(75.dp)
                    .offset(x = (160).dp, y = our_height -3.dp)
                    .zIndex(5f)
            ) {
                IconWithRipple(
                    R.drawable.settings, 48.dp,
                    isSelected = selectedIconId == R.drawable.settings,
                    onSelected = { selectedIconId = R.drawable.settings }
                )
            }

            val iconOffsets = mapOf(
                R.drawable.home to (-160).dp,
                R.drawable.car to (-103.67).dp,
                R.drawable.ai to (-48.33).dp,
                R.drawable.connect to 0.dp,
                R.drawable.map to 53.33.dp,
                R.drawable.music to 106.67.dp,
                R.drawable.settings to 160.dp
            )

            val targetOffsetX = iconOffsets[selectedIconId] ?: (-160).dp
            val animatedOffsetX by animateDpAsState(
                targetValue = targetOffsetX,
                animationSpec = tween(durationMillis = 200, easing = FastOutSlowInEasing),
                label = "indicatorOffset"
            )

            //current panel
            Canvas(
                modifier = Modifier
                    .width(50.dp)
                    .height(3.dp)
                    .align(Alignment.Center)
                    .offset(x = animatedOffsetX, y = 32.5.dp)
                    .zIndex(10f)
            ) {
                drawOval(
                    brush = Brush.radialGradient(
                        colors = listOf(
                            ReDriveColors.RadialGradient.copy(alpha = 0.8f),
                            Color(0xFF14171D)
                        ),
                        center = Offset(size.width / 2, size.height / 2),
                        radius = size.width / 2
                    ),
                    topLeft = Offset.Zero,
                    size = size
                )
            }


            //chevron icon
            Image(
                painter = painterResource(id = R.drawable.chevron),
                contentDescription = null,
                contentScale = ContentScale.FillBounds,
                modifier = Modifier
                    .width(28.dp)
                    .height(3.dp)
                    .align(Alignment.Center)
                    .offset(y = (-26).dp)
                    .zIndex(3f)
            )

        }
    }
}
