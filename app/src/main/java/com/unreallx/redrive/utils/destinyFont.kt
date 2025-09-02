package com.unreallx.redrive.utils

import androidx.compose.runtime.Composable
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.TextUnit
import androidx.compose.ui.unit.dp

@Composable
fun fixedSp(value: Int): TextUnit {
    val density = LocalDensity.current
    return with(density) { value.dp.toSp() }
}

@Composable
fun fixedSp(value: Float): TextUnit {
    val density = LocalDensity.current
    return with(density) { value.dp.toSp() }
}