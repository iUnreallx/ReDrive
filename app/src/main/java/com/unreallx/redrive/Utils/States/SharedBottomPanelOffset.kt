package com.unreallx.redrive.Utils.States

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.unit.dp

object SharedState {
    var offsetY by mutableStateOf(0.dp)
}