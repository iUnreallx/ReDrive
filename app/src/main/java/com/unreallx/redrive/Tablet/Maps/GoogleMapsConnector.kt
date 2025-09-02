package com.unreallx.redrive.Tablet.Maps

import android.content.Context
import android.net.ConnectivityManager
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.google.android.gms.maps.model.CameraPosition
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.MapStyleOptions
import com.google.maps.android.compose.GoogleMap
import com.google.maps.android.compose.MapProperties
import com.google.maps.android.compose.MapUiSettings
import com.google.maps.android.compose.Marker
import com.google.maps.android.compose.MarkerState
import com.google.maps.android.compose.rememberCameraPositionState


fun isNetworkAvailable(context: Context): Boolean {
    val cm = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
    return cm.activeNetworkInfo?.isConnectedOrConnecting == true
}

@Composable
fun googleMapsConnector() {
    val context = LocalContext.current
    val isOnline = remember { mutableStateOf(isNetworkAvailable(context)) }
    LaunchedEffect(Unit) {
        isOnline.value = isNetworkAvailable(context)
    }

    Box(
        Modifier
            .padding(top = 50.dp, start = 415.dp)
            .width(845.dp)
            .height(405.dp)
            .fillMaxSize()
            .clip(RoundedCornerShape(25.dp))
            .background(Color(0xFF1E1E1E)),
        contentAlignment = Alignment.Center
    ) {
        if (!isOnline.value) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(Color.Black),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = "Нет подключения к интернету",
                    color = Color.White,
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold
                )
            }
        } else {
            val crimea = LatLng(44.9521, 34.1024)
            val cameraPositionState = rememberCameraPositionState {
                position = CameraPosition.fromLatLngZoom(crimea, 10f)
            }

            val context = LocalContext.current

            val darkMapStyle = remember {
                MapStyleOptions(
                    """
                [
                  {
                    "elementType": "geometry",
                    "stylers": [
                      { "color": "#212121" }
                    ]
                  },
                  {
                    "elementType": "labels.icon",
                    "stylers": [
                      { "visibility": "off" }
                    ]
                  },
                  {
                    "elementType": "labels.text.fill",
                    "stylers": [
                      { "color": "#757575" }
                    ]
                  },
                  {
                    "elementType": "labels.text.stroke",
                    "stylers": [
                      { "color": "#212121" }
                    ]
                  },
                  {
                    "featureType": "administrative",
                    "elementType": "geometry",
                    "stylers": [
                      { "color": "#757575" }
                    ]
                  },
                  {
                    "featureType": "poi",
                    "elementType": "geometry",
                    "stylers": [
                      { "color": "#181818" }
                    ]
                  },
                  {
                    "featureType": "poi.park",
                    "elementType": "geometry",
                    "stylers": [
                      { "color": "#1b1b1b" }
                    ]
                  },
                  {
                    "featureType": "road",
                    "elementType": "geometry.fill",
                    "stylers": [
                      { "color": "#2c2c2c" }
                    ]
                  },
                  {
                    "featureType": "road",
                    "elementType": "geometry.stroke",
                    "stylers": [
                      { "color": "#212121" }
                    ]
                  },
                  {
                    "featureType": "road.highway",
                    "elementType": "geometry",
                    "stylers": [
                      { "color": "#3c3c3c" }
                    ]
                  },
                  {
                    "featureType": "transit",
                    "elementType": "geometry",
                    "stylers": [
                      { "color": "#2f2f2f" }
                    ]
                  },
                  {
                    "featureType": "water",
                    "elementType": "geometry",
                    "stylers": [
                      { "color": "#000000" }
                    ]
                  },
                  {
                    "featureType": "water",
                    "elementType": "labels.text.fill",
                    "stylers": [
                      { "color": "#3d3d3d" }
                    ]
                  }
                ]
            """.trimIndent()
                )
            }


            GoogleMap(
                modifier = Modifier.fillMaxSize(),
                cameraPositionState = cameraPositionState,
                properties = MapProperties(mapStyleOptions = darkMapStyle),
                uiSettings = MapUiSettings(zoomControlsEnabled = false)
            ) {
                Marker(
                    state = MarkerState(position = crimea),
                    title = "Crimea",
                    snippet = "Marker in Crimea"
                )
            }
        }
    }
}