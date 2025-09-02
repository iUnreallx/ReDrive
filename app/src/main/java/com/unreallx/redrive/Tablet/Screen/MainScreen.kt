package com.unreallx.redrive.Tablet.Screen

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.withTransform
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.zIndex
import com.unreallx.redrive.R
import com.unreallx.redrive.Tablet.Components.BottomPanel
import com.unreallx.redrive.Tablet.Maps.googleMapsConnector
import com.unreallx.redrive.Tablet.Speedometer.Speedometer


@Composable
fun tabletMainScreen() {
    BottomPanel()
    googleMapsConnector()

    Box(
        Modifier
            .padding(top = 50.dp, start = 25.dp)
            .width(370.dp)
            .height(570.dp)
            .clip(RoundedCornerShape(25.dp))
            .background(Color(0xFF1E1E1E)),
        contentAlignment = Alignment.Center
    ) {

        //speedometer
        Speedometer(
            speed = 200.0f,
            sizeDp = 225.dp,
            modifier = Modifier.offset(y = 180.dp)
                .zIndex(4f)
        )

        //oval back speedometer
        Canvas(
            modifier = Modifier
                .width(400.dp)
                .height(200.dp)
                .align(Alignment.Center)
                .offset(y = 90.dp)
                .zIndex(3f)
        ) {
            drawOval(
                color = Color(0xFF171717),
                topLeft = Offset.Zero,
                size = size
            )
        }


        //back speedometer
        Box(
            modifier = Modifier
                .width(395.dp)
                .height(250.dp)
                .align(Alignment.BottomCenter)
                .clip(RoundedCornerShape(topStart = 50.dp, topEnd = 50.dp))
                .background(Color(0xFF171717))
                .zIndex(3f)
        )


        // car img
        val configuration = LocalConfiguration.current
        val screenWidth = configuration.screenWidthDp.dp

        Image(
            painter = painterResource(id = R.drawable.car_menu1),
            contentDescription = null,
            contentScale = ContentScale.FillWidth,
            modifier = Modifier
                .width(screenWidth * 0.65f)
                .align(Alignment.Center)
                .offset(y = (-140).dp)
                .zIndex(1f)
        )



        //car shadows
        Canvas(
            modifier = Modifier
                .width(250.dp)
                .height(50.dp)
                .align(Alignment.Center)
                .offset(y = (-35).dp)
                .zIndex(0f)
        ) {
            val center = Offset(size.width / 2, size.height / 2)
            val radius = size.width / 2
            val scaleY = size.height / size.width

            withTransform({
                scale(1f, scaleY, pivot = center)
            }) {
                drawCircle(
                    brush = Brush.radialGradient(
                        colors = listOf(
                            Color(0xFF070906),
                            Color(0xFF1E1E1E)
                        ),
                        center = center,
                        radius = radius
                    ),
                    center = center,
                    radius = radius
                )
            }
        }


        //Car naming
        Text(
            text = "Mitsubishi Lancer IX",
            fontSize = 25.sp,
            letterSpacing = 2.sp,
            fontWeight = FontWeight.Bold,
            modifier = Modifier
                .offset(y = (-250).dp),
            style = TextStyle(
                brush = Brush.linearGradient(
                    colors = listOf(
                        Color(0xFFFFFFFF),
                        Color(0xFF999999)
                    )
                )
            )
        )

        //Text Shadows
        Canvas(
            modifier = Modifier
                .width(225.dp)
                .height(10.dp)
                .align(Alignment.Center)
                .offset(y = (-230).dp)
                .zIndex(3f)
        ) {
            val center = Offset(size.width / 2, size.height / 2)
            val radius = size.width / 2
            val scaleY = size.height / size.width

            withTransform({
                scale(1f, scaleY, pivot = center)
            }) {
                drawCircle(
                    brush = Brush.radialGradient(
                        colors = listOf(
                            Color(0xFF261F97),
                            Color(0xFF1E1E1E)
                        ),
                        center = center,
                        radius = radius
                    ),
                    center = center,
                    radius = radius
                )
            }
        }
    }






    //music
    Box(
        Modifier
            .padding(top = 475.dp, start = 415.dp)
            .width(415.dp)
            .height(125.dp)
            .clip(RoundedCornerShape(36.dp))
            .background(Color(0xFF1E1E1E)),
        contentAlignment = Alignment.Center
    ) {

    }



    //weather
    Box(
        Modifier
            .padding(top = 475.dp, start = 845.dp)
            .width(415.dp)
            .height(125.dp)
            .clip(RoundedCornerShape(36.dp))
            .background(Color(0xFF1E1E1E)),
        contentAlignment = Alignment.Center
    ) {

    }
}