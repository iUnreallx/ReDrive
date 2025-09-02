package com.unreallx.redrive.Tablet.Components


import androidx.compose.foundation.Canvas
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
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
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.zIndex
import com.unreallx.redrive.R
import com.unreallx.redrive.ui.theme.ReDriveColors

@Preview
@Composable
fun BottomPanel(
    width: Dp = 594.dp,
    height: Dp = 75.dp,
    endRadius: Dp = 40.dp
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(bottom = 20.dp),
        verticalArrangement = Arrangement.Bottom,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Box(
            contentAlignment = Alignment.Center
        ) {

            //oval bottom menu panel
            Box(
                modifier = Modifier
                    .width(200.dp)
                    .height(103.dp)
//                    .offset(y = (0).dp)
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

            //current bottom bar selected
            Canvas(
                modifier = Modifier
                    .width(75.dp)
                    .height(5.dp)
                    .align(Alignment.Center)
                    .offset(x = (-248).dp, y = (72).dp)
                    .zIndex(3f)
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

            //gradient oval around bottom panel
            Image(
                painter = painterResource(id = R.drawable.gradient_to_menu),
                contentDescription = null,
                contentScale = ContentScale.FillBounds,
                modifier = Modifier
                    .width(width + 360.dp)
                    .height(170.dp)
                    .align(Alignment.Center)
                    .offset(y = (50).dp)
                    .zIndex(0f)
            )

                Box(
                    modifier = Modifier
                        .width(width)
                        .height(height)
                        .clip(RoundedCornerShape(30.dp))
                        .background(ReDriveColors.BackgroundToMain)
                        .align(Alignment.BottomCenter)
                        .zIndex(1f)
                )

            //all icons
            Row (
                modifier = Modifier
                    .fillMaxWidth()
                    .offset(x = (0).dp, y = (48).dp)
                    .zIndex(3f),
                horizontalArrangement = Arrangement.Center,
                verticalAlignment = Alignment.CenterVertically
            ) {
                //home icon
                Image(
                    painter = painterResource(id = R.drawable.home),
                    contentDescription = null,
                    contentScale = ContentScale.FillBounds,
                    modifier = Modifier.size(55.dp)
                )

                Spacer(modifier = Modifier.width(30.dp))


                //car icon
                Image(
                    painter = painterResource(id = R.drawable.car),
                    contentDescription = null,
                    contentScale = ContentScale.FillBounds,
                    modifier = Modifier.size(50.dp)
                )

                Spacer(modifier = Modifier.width(35.dp))

                //ai icon
                Image(
                    painter = painterResource(id = R.drawable.ai),
                    contentDescription = null,
                    contentScale = ContentScale.FillBounds,
                    modifier = Modifier.size(50.dp)
                )

                Spacer(modifier = Modifier.width(30.dp))

                //connect ico
                Image(
                    painter = painterResource(id = R.drawable.connect),
                    contentDescription = null,
                    contentScale = ContentScale.FillBounds,
                    modifier = Modifier
                        .size(53.dp)
                        .graphicsLayer(
                            rotationZ = 5f
                        )
                )


                Spacer(modifier = Modifier.width(30.dp))

                //map icon
                Image(
                    painter = painterResource(id = R.drawable.map),
                    contentDescription = null,
                    contentScale = ContentScale.FillBounds,
                    modifier = Modifier.size(53.dp)
                )


                Spacer(modifier = Modifier.width(30.dp))

                //music icon
                Image(
                    painter = painterResource(id = R.drawable.music),
                    contentDescription = null,
                    contentScale = ContentScale.FillBounds,
                    modifier = Modifier.size(53.dp)
                )


                Spacer(modifier = Modifier.width(30.dp))

                //settings icon
                Image(
                    painter = painterResource(id = R.drawable.settings),
                    contentDescription = null,
                    contentScale = ContentScale.FillBounds,
                    modifier = Modifier.size(53.dp)
                )
            }



            //chevron icon
            Image(
                painter = painterResource(id = R.drawable.chevron),
                contentDescription = null,
                contentScale = ContentScale.FillBounds,
                modifier = Modifier
                    .width(35.dp)
                    .height(35.dp)
                    .align(Alignment.Center)
                    .offset(y = (0).dp)
                    .zIndex(3f)
            )

        }
    }
}
