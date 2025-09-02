package com.unreallx.redrive.Utils

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.runtime.Composable
import androidx.compose.runtime.MutableState
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.withFrameNanos
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clipToBounds
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.isSpecified
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.zIndex
import kotlinx.coroutines.launch

data class RippleData(
    val offset: Offset,
    val targetRadius: Float,
    val id: Long = System.currentTimeMillis()
)

@Composable
fun CustomRippleBox(
    modifier: Modifier = Modifier,
    rippleColor: Color = Color(0xFFF8F8F8),
    onClick: () -> Unit,
    content: @Composable BoxScope.() -> Unit
) {
    val ripples = remember { mutableStateListOf<Pair<RippleData, MutableState<Float>>>() }
    val scope = rememberCoroutineScope()

    Box(
        modifier = modifier
            .clipToBounds()
            .pointerInput(Unit) {
                detectTapGestures(
                    onTap = { offset ->
                        val size = this.size
                        val corners = listOf(
                            Offset(0f, 0f),
                            Offset(size.width.toFloat(), 0f),
                            Offset(0f, size.height.toFloat()),
                            Offset(size.width.toFloat(), size.height.toFloat())
                        )
                        val maxDistance = corners.maxOf { (it - offset).getDistance() }

                        val ripple = RippleData(offset = offset, targetRadius = maxDistance)
                        val progress = mutableStateOf(0f)
                        ripples.add(ripple to progress)

                        onClick()

                        scope.launch {
                            val duration = 500
                            val startTime = withFrameNanos { it }
                            var elapsed: Long
                            do {
                                elapsed = withFrameNanos { frameTimeNanos ->
                                    val t = (frameTimeNanos - startTime) / 1_000_000f
                                    progress.value = (t / duration).coerceIn(0f, 1f)
                                    t.toLong()
                                }
                            } while (elapsed < duration)
                            ripples.removeAll { it.first.id == ripple.id }
                        }
                    }
                )
            }
    ) {
        content()

        ripples.forEach { (ripple, progress) ->
            if (ripple.offset.isSpecified) {
                Canvas(
                    modifier = Modifier
                        .matchParentSize()
                        .zIndex(1f)
                ) {
                    val radius = progress.value * ripple.targetRadius
                    val alpha = 1f - progress.value.coerceIn(0f, 0.95f)

                    if (radius > 0f) {
                        drawCircle(
                            brush = Brush.radialGradient(
                                colors = listOf(
                                    rippleColor.copy(alpha = alpha * 0.8f),
                                    rippleColor.copy(alpha = alpha * 0.2f)
                                ),
                                center = ripple.offset,
                                radius = radius
                            ),
                            center = ripple.offset,
                            radius = radius
                        )
                    }
                }
            }
        }
    }
}